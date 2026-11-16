import 'package:flutter/material.dart';

import 'database/database_helper.dart';

/// Thống kê thu chi từ SQLite hiện có. Không tạo hoặc thay đổi database.
class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen({super.key});

  @override
  State<StatisticsScreen> createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> {
  static const _blue = Color(0xFF2169E8);
  static const _green = Color(0xFF159C68);
  static const _red = Color(0xFFF05A67);

  late Future<List<Map<String, Object?>>> _future;
  bool _thisMonth = false; // Mặc định tất cả để dữ liệu cũ vẫn hiển thị.

  @override
  void initState() {
    super.initState();
    _future = DatabaseHelper.instance.getTransactions();
  }

  Future<void> _reload() async {
    final next = DatabaseHelper.instance.getTransactions();
    if (mounted) {
      setState(() {
        _future = next;
      });
    }
    await next;
  }

  String _money(int amount) {
    final digits = amount.abs().toString();
    final groups = digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (_) => '.',
    );
    return '${amount < 0 ? '-' : ''}$groups đ';
  }

  int _amount(Map<String, Object?> item) {
    final value = item['amount'];
    return value is num ? value.toInt() : int.tryParse('$value') ?? 0;
  }

  DateTime? _date(Map<String, Object?> item) =>
      DateTime.tryParse('${item['date'] ?? ''}');

  List<Map<String, Object?>> _filter(List<Map<String, Object?>> rows) {
    if (!_thisMonth) return rows;
    final now = DateTime.now();
    return rows.where((row) {
      final day = _date(row);
      return day != null && day.year == now.year && day.month == now.month;
    }).toList();
  }

  Widget _card({required Widget child, EdgeInsetsGeometry? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFE8EDF5)),
      ),
      child: child,
    );
  }

  Widget _metric({
    required String label,
    required int value,
    required IconData icon,
    required Color color,
  }) {
    return Expanded(
      child: _card(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 9),
            Text(
              label,
              style: const TextStyle(fontSize: 12, color: Color(0xFF66758F)),
            ),
            const SizedBox(height: 5),
            FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.centerLeft,
              child: Text(
                _money(value),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _monthlyChart(List<Map<String, Object?>> rows) {
    // Lấy 6 tháng kết thúc tại tháng có giao dịch mới nhất; nếu chưa có
    // giao dịch thì kết thúc tại tháng hiện tại.
    var anchor = DateTime(DateTime.now().year, DateTime.now().month);
    for (final row in rows) {
      final date = _date(row);
      if (date != null && date.isAfter(anchor)) {
        anchor = DateTime(date.year, date.month);
      }
    }
    // Dữ liệu từ năm cũ vẫn được hiện trên biểu đồ khi mở app lần đầu.
    if (rows.isNotEmpty) {
      final dates = rows.map(_date).whereType<DateTime>().toList();
      if (dates.isNotEmpty) {
        dates.sort();
        anchor = DateTime(dates.last.year, dates.last.month);
      }
    }

    final months = List.generate(6, (index) {
      final date = DateTime(anchor.year, anchor.month - 5 + index);
      var income = 0;
      var expense = 0;
      for (final row in rows) {
        final d = _date(row);
        if (d?.year != date.year || d?.month != date.month) continue;
        if (row['type'] == 'Thu nhập') income += _amount(row);
        if (row['type'] == 'Chi tiêu') expense += _amount(row);
      }
      return (date: date, income: income, expense: expense);
    });
    final maxAmount = months.fold<int>(1, (max, month) {
      final best = month.income > month.expense ? month.income : month.expense;
      return best > max ? best : max;
    });

    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Thu nhập và chi tiêu theo tháng',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 9),
          Row(
            children: [
              _legend(_green, 'Thu nhập'),
              const SizedBox(width: 16),
              _legend(_red, 'Chi tiêu'),
            ],
          ),
          const SizedBox(height: 22),
          SizedBox(
            height: 160,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                for (final month in months)
                  Expanded(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        SizedBox(
                          height: 125,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              _bar(month.income, maxAmount, _green),
                              const SizedBox(width: 3),
                              _bar(month.expense, maxAmount, _red),
                            ],
                          ),
                        ),
                        const SizedBox(height: 7),
                        Text(
                          '${month.date.month}/${month.date.year % 100}',
                          style: const TextStyle(
                            fontSize: 10,
                            color: Color(0xFF66758F),
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(Color color, String label) => Row(
    children: [
      Container(
        width: 9,
        height: 9,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 12, color: Color(0xFF66758F)),
      ),
    ],
  );

  Widget _bar(int amount, int maxAmount, Color color) {
    final height = amount <= 0
        ? 2.0
        : (amount / maxAmount * 120).clamp(3.0, 120.0);
    return Container(
      width: 12,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
      ),
    );
  }

  Widget _categoryBreakdown(List<Map<String, Object?>> rows) {
    final totals = <String, int>{};
    for (final row in rows) {
      if (row['type'] != 'Chi tiêu') continue;
      final raw = '${row['category_name'] ?? ''}'.trim();
      final name = raw.isEmpty ? 'Khác' : raw;
      totals.update(
        name,
        (n) => n + _amount(row),
        ifAbsent: () => _amount(row),
      );
    }
    final sorted = totals.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final total = sorted.fold<int>(0, (sum, entry) => sum + entry.value);
    return _card(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chi tiêu theo danh mục',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 14),
          if (sorted.isEmpty)
            const Text(
              'Chưa có giao dịch chi tiêu trong khoảng thời gian này.',
              style: TextStyle(color: Color(0xFF66758F)),
            )
          else
            for (final entry in sorted) ...[
              Row(
                children: [
                  Expanded(
                    child: Text(entry.key, overflow: TextOverflow.ellipsis),
                  ),
                  Text(
                    _money(entry.value),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: total == 0 ? 0 : entry.value / total,
                  minHeight: 9,
                  backgroundColor: const Color(0xFFEDF1F8),
                  color: _red,
                ),
              ),
              const SizedBox(height: 14),
            ],
        ],
      ),
    );
  }

  Widget _content(List<Map<String, Object?>> allRows) {
    final rows = _filter(allRows);
    var income = 0;
    var expense = 0;
    for (final item in rows) {
      if (item['type'] == 'Thu nhập') income += _amount(item);
      if (item['type'] == 'Chi tiêu') expense += _amount(item);
    }

    return RefreshIndicator(
      onRefresh: _reload,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
        children: [
          _card(
            child: Row(
              children: [
                const Icon(Icons.date_range_outlined, color: _blue),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Khoảng thời gian',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
                DropdownButton<bool>(
                  value: _thisMonth,
                  underline: const SizedBox.shrink(),
                  items: const [
                    DropdownMenuItem(value: false, child: Text('Tất cả')),
                    DropdownMenuItem(value: true, child: Text('Tháng này')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _thisMonth = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _card(
            child: Row(
              children: [
                const CircleAvatar(
                  backgroundColor: Color(0xFFE9F0FF),
                  child: Icon(
                    Icons.account_balance_wallet_outlined,
                    color: _blue,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số dư',
                        style: TextStyle(color: Color(0xFF66758F)),
                      ),
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        alignment: Alignment.centerLeft,
                        child: Text(
                          _money(income - expense),
                          style: const TextStyle(
                            fontSize: 25,
                            fontWeight: FontWeight.bold,
                            color: _blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _metric(
                label: 'Tổng thu nhập',
                value: income,
                icon: Icons.arrow_downward,
                color: _green,
              ),
              const SizedBox(width: 10),
              _metric(
                label: 'Tổng chi tiêu',
                value: expense,
                icon: Icons.arrow_upward,
                color: _red,
              ),
            ],
          ),
          const SizedBox(height: 12),
          _card(
            child: Row(
              children: [
                const Icon(Icons.receipt_long_outlined, color: _blue),
                const SizedBox(width: 12),
                const Text(
                  'Số giao dịch',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Text(
                  '${rows.length}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          _monthlyChart(allRows),
          const SizedBox(height: 16),
          _categoryBreakdown(rows),
          if (rows.isEmpty)
            const Padding(
              padding: EdgeInsets.only(top: 24),
              child: Text(
                'Chưa có giao dịch trong khoảng thời gian này.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF66758F)),
              ),
            ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FF),
      appBar: AppBar(
        title: const Text(
          'Thống kê thu chi',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: const Color(0xFFF7F9FF),
        actions: [
          IconButton(
            tooltip: 'Làm mới',
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _reload();
            },
          ),
        ],
      ),
      body: FutureBuilder<List<Map<String, Object?>>>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.error_outline, size: 42, color: _red),
                    const SizedBox(height: 12),
                    Text(
                      'Không tải được thống kê: ${snapshot.error}',
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    ElevatedButton(
                      onPressed: () {
                        _reload();
                      },
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            );
          }
          return _content(snapshot.data ?? []);
        },
      ),
    );
  }
}

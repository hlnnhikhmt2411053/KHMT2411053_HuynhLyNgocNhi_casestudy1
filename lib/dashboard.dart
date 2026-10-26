import 'package:flutter/material.dart';
import 'database/database_helper.dart';
import 'main.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final _db = DatabaseHelper.instance;
  List<Map<String, Object?>> _transactions = [];
  int _balance = 0;
  int _income = 0;
  int _expense = 0;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _refresh();
  }

  Future<void> _refresh() async {
    try {
      final summary = await _db.getSummary();
      final transactions = await _db.getTransactions();
      if (!mounted) return;
      setState(() {
        _balance = summary['balance'] ?? 0;
        _income = summary['income'] ?? 0;
        _expense = summary['expense'] ?? 0;
        _transactions = transactions;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi đọc SQLite: $e')));
    }
  }

  Future<void> _openForm([int? id]) async {
    final changed = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => TransactionScreen(transactionId: id)),
    );
    if (changed == true) await _refresh();
  }

  String _money(int value) {
    final sign = value < 0 ? '-' : '';
    final digits = value.abs().toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
      buffer.write(digits[i]);
    }
    return '$sign${buffer.toString()} đ';
  }

  String _displayDate(Object? iso) {
    final date = DateTime.tryParse(iso?.toString() ?? '');
    if (date == null) return '';
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  IconData _icon(String category, bool income) {
    if (income) return Icons.payments;
    switch (category) {
      case 'Ăn uống': return Icons.restaurant;
      case 'Di chuyển': return Icons.directions_car;
      case 'Mua sắm': return Icons.shopping_cart;
      case 'Giáo dục': return Icons.school;
      case 'Giải trí': return Icons.movie;
      default: return Icons.receipt_long;
    }
  }

  Widget _totalsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF4687F7), Color(0xFF1260DF)]),
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        children: [
          const Text('SỐ DƯ HIỆN TẠI', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 10),
          FittedBox(
            child: Text(_money(_balance), style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          ),
          const SizedBox(height: 22),
          Row(children: [
            Expanded(child: _summaryMini('Thu nhập', _income, Icons.arrow_downward)),
            const SizedBox(width: 12),
            Expanded(child: _summaryMini('Chi tiêu', _expense, Icons.arrow_upward)),
          ]),
        ],
      ),
    );
  }

  Widget _summaryMini(String label, int amount, IconData icon) => Row(
    children: [
      CircleAvatar(radius: 17, backgroundColor: Colors.white24, child: Icon(icon, color: Colors.white, size: 18)),
      const SizedBox(width: 7),
      Expanded(child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.white70, fontSize: 11)),
          FittedBox(alignment: Alignment.centerLeft, fit: BoxFit.scaleDown,
              child: Text(_money(amount), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13))),
        ],
      )),
    ],
  );

  Widget _summaryTiles() => Row(children: [
    Expanded(child: _tile('TỔNG THU NHẬP', _income, const Color(0xFF219447), const Color(0xFFE7F6E9), Icons.south)),
    const SizedBox(width: 10),
    Expanded(child: _tile('TỔNG CHI TIÊU', _expense, const Color(0xFFE93B4C), const Color(0xFFFFEAEC), Icons.north)),
  ]);

  Widget _tile(String title, int value, Color color, Color bg, IconData icon) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
    decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      CircleAvatar(radius: 17, backgroundColor: color.withValues(alpha: 0.18), child: Icon(icon, color: color)),
      const SizedBox(width: 7),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, maxLines: 1, style: const TextStyle(fontSize: 9, color: Color(0xFF526078))),
        FittedBox(fit: BoxFit.scaleDown, alignment: Alignment.centerLeft,
            child: Text(_money(value), style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.bold))),
      ])),
    ]),
  );

  Widget _transactionTile(Map<String, Object?> transaction) {
    final isIncome = transaction['type'] == 'Thu nhập';
    final amount = (transaction['amount'] as num).toInt();
    final category = (transaction['category_name'] as String?) ?? '';
    final note = (transaction['note'] as String?) ?? '';
    final label = note.trim().isEmpty ? category : note;
    final color = isIncome ? const Color(0xFF219447) : const Color(0xFFE93B4C);
    return InkWell(
      onTap: () => _openForm((transaction['id'] as num).toInt()),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        child: Row(children: [
          CircleAvatar(backgroundColor: color.withValues(alpha: 0.12), child: Icon(_icon(category, isIncome), color: color)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(label, maxLines: 1, overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF172542))),
            const SizedBox(height: 4),
            Text('$category  •  ${_displayDate(transaction['date'])}',
                style: const TextStyle(fontSize: 11, color: Color(0xFF8993A4))),
          ])),
          const SizedBox(width: 4),
          FittedBox(fit: BoxFit.scaleDown,
              child: Text('${isIncome ? '+' : '-'}${_money(amount)}',
                  style: TextStyle(fontWeight: FontWeight.bold, color: color, fontSize: 12))),
        ]),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF7F9FF),
        title: const Text('Quản lý thu chi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        actions: [IconButton(onPressed: _refresh, icon: const Icon(Icons.refresh))],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _refresh,
        child: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 96), children: [
          _totalsCard(),
          const SizedBox(height: 12),
          _summaryTiles(),
          if (_income == 0 && _expense > 0)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'Số dư âm vì bạn mới ghi nhận Chi tiêu, chưa có Thu nhập. Nhấn + và chọn Thu nhập để ghi khoản tiền nhận được.',
                style: TextStyle(color: Colors.deepOrange.shade700, fontSize: 12),
              ),
            ),
          const SizedBox(height: 24),
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            const Text('Giao dịch gần đây', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text('${_transactions.length} giao dịch', style: const TextStyle(color: Color(0xFF2169E8))),
          ]),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14)),
            child: _transactions.isEmpty
                ? const Padding(
              padding: EdgeInsets.all(25),
              child: Center(child: Text('Chưa có giao dịch. Nhấn + để thêm!')),
            )
                : Column(children: [
              for (var i = 0; i < _transactions.length; i++) ...[
                _transactionTile(_transactions[i]),
                if (i < _transactions.length - 1)
                  const Divider(height: 1, indent: 12, endIndent: 12),
              ],
            ]),
          ),
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF2169E8),
        foregroundColor: Colors.white,
        onPressed: () => _openForm(),
        child: const Icon(Icons.add),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) _openForm();
          if (index == 2) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Thống kê chi tiết sẽ được phát triển sau')),
            );
          }
        },
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_outlined), selectedIcon: Icon(Icons.home), label: 'Trang chủ'),
          NavigationDestination(icon: Icon(Icons.receipt_long_outlined), label: 'Giao dịch'),
          NavigationDestination(icon: Icon(Icons.pie_chart_outline), label: 'Thống kê'),
        ],
      ),
    );
  }
}

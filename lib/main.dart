import 'package:flutter/material.dart';
import 'dashboard.dart';
import 'database/database_helper.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await DatabaseHelper.instance.ensureCategories();
  runApp(const ExpenseManagerApp());
}

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Expense Manager',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2169E8)),
        scaffoldBackgroundColor: const Color(0xFFF7F9FF),
      ),
      home: const DashboardScreen(),
    );
  }
}

// Null = thêm giao dịch. Có id = sửa giao dịch.
class TransactionScreen extends StatefulWidget {
  final int? transactionId;
  const TransactionScreen({super.key, this.transactionId});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  final _db = DatabaseHelper.instance;
  String _type = 'Chi tiêu';
  int? _categoryId;
  DateTime _date = DateTime.now();
  List<Map<String, Object?>> _categories = [];
  bool _loading = true;
  bool _saving = false;

  String _money(int amount) {
    final digits = amount.toString();
    return digits.replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'), (match) => '.',
    );
  }

  int? get _enteredAmount => int.tryParse(
    _amountController.text.replaceAll(RegExp(r'[.,\s]'), ''),
  );

  bool get isEdit => widget.transactionId != null;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      if (isEdit) {
        final data = await _db.getTransactionById(widget.transactionId!);
        if (data == null) throw StateError('Không tìm thấy giao dịch');
        _type = data['type'] as String;
        _categoryId = (data['category_id'] as num).toInt();
        _amountController.text = (data['amount'] as num).toInt().toString();
        _noteController.text = (data['note'] as String?) ?? '';
        _date = DateTime.parse(data['date'] as String);
      }
      final categories = await _db.getCategories(_type);
      if (!mounted) return;
      setState(() {
        _categories = categories;
        if (!categories.any((c) => c['id'] == _categoryId)) {
          _categoryId = categories.isEmpty ? null : (categories.first['id'] as num).toInt();
        }
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lỗi tải dữ liệu: $e')));
    }
  }

  Future<void> _changeType(String type) async {
    if (_type == type) return;
    setState(() {
      _type = type;
      _categoryId = null;
    });
    final categories = await _db.getCategories(type);
    if (!mounted) return;
    setState(() {
      _categories = categories;
      _categoryId = categories.isEmpty ? null : (categories.first['id'] as num).toInt();
    });
  }

  Future<void> _chooseDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate() || _categoryId == null || _saving) return;
    final amount = _enteredAmount!;
    // Confirm before saving, to prevent accidentally recording huge expenses.
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(isEdit ? 'Xác nhận sửa giao dịch' : 'Xác nhận thêm giao dịch'),
        content: Text(
          'Loại: $_type\n'
              'Số tiền: ${_money(amount)} đ\n\n'
              '${amount >= 100000000 ? 'Lưu ý: Số tiền rất lớn. Hãy kiểm tra số chữ số trước khi lưu.' : 'Bạn có muốn lưu giao dịch này không?'}',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Kiểm tra lại')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Lưu giao dịch')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _saving = true);
    try {
      if (isEdit) {
        await _db.updateTransaction(
          id: widget.transactionId!, categoryId: _categoryId!, amount: amount,
          type: _type, date: _date, note: _noteController.text,
        );
      } else {
        await _db.insertTransaction(
          categoryId: _categoryId!, amount: amount,
          type: _type, date: _date, note: _noteController.text,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, true); // Báo Dashboard tải lại số liệu.
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể lưu: $e')));
      setState(() => _saving = false);
    }
  }

  Future<void> _delete() async {
    if (!isEdit) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa giao dịch?'),
        content: const Text('Giao dịch sẽ bị xóa khỏi SQLite.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Hủy')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Xóa')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await _db.deleteTransaction(widget.transactionId!);
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Không thể xóa: $e')));
    }
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  String get formattedDate =>
      '${_date.day.toString().padLeft(2, '0')}/${_date.month.toString().padLeft(2, '0')}/${_date.year}';

  InputDecoration _decoration({String? hint, Widget? suffix}) => InputDecoration(
    hintText: hint,
    suffixIcon: suffix,
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(9)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(9),
      borderSide: const BorderSide(color: Color(0xFFD7DFED)),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(top: 22, bottom: 9),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF1B2B49))),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [if (isEdit) IconButton(icon: const Icon(Icons.delete_outline), onPressed: _delete)],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Row(children: [
                        for (final type in ['Chi tiêu', 'Thu nhập'])
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.only(right: 4),
                              child: OutlinedButton(
                                onPressed: () => _changeType(type),
                                style: OutlinedButton.styleFrom(
                                  backgroundColor: _type == type
                                      ? (type == 'Chi tiêu' ? const Color(0xFFFF6069) : const Color(0xFF2169E8))
                                      : Colors.white,
                                  foregroundColor: _type == type ? Colors.white : const Color(0xFF172542),
                                  side: const BorderSide(color: Color(0xFFD7DFED)),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                child: Text(type),
                              ),
                            ),
                          ),
                      ]),
                      const SizedBox(height: 10),
                      Text(
                        _type == 'Thu nhập'
                            ? 'Khoản tiền được CỘNG vào số dư.'
                            : 'Khoản tiền bị TRỪ khỏi số dư.',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _type == 'Thu nhập'
                              ? const Color(0xFF198754)
                              : const Color(0xFFD64550),
                        ),
                      ),
                      _label('Danh mục'),
                      DropdownButtonFormField<int>(
                        initialValue: _categoryId,
                        decoration: _decoration(),
                        items: _categories.map((c) => DropdownMenuItem<int>(
                          value: (c['id'] as num).toInt(),
                          child: Text(c['name'] as String),
                        )).toList(),
                        onChanged: (value) => setState(() => _categoryId = value),
                        validator: (value) => value == null ? 'Hãy chọn danh mục' : null,
                      ),
                      _label('Số tiền'),
                      TextFormField(
                        controller: _amountController,
                        keyboardType: TextInputType.number,
                        onChanged: (_) => setState(() {}),
                        decoration: _decoration(hint: 'Nhập số tiền', suffix: const Center(widthFactor: 1, child: Text('đ'))),
                        validator: (value) {
                          final n = int.tryParse((value ?? '').replaceAll(RegExp(r'[.,\s]'), ''));
                          return n == null || n <= 0 ? 'Nhập số tiền lớn hơn 0' : null;
                        },
                      ),
                      if ((_enteredAmount ?? 0) > 0)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            '${_type == 'Thu nhập' ? '+' : '-'}${_money(_enteredAmount!)} đ sẽ ${_type == 'Thu nhập' ? 'cộng vào' : 'trừ khỏi'} số dư',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: _type == 'Thu nhập'
                                  ? const Color(0xFF198754)
                                  : const Color(0xFFD64550),
                            ),
                          ),
                        ),
                      _label('Ngày giao dịch'),
                      InkWell(
                        onTap: _chooseDate,
                        child: InputDecorator(
                          decoration: _decoration(suffix: const Icon(Icons.calendar_month_outlined)),
                          child: Text(formattedDate),
                        ),
                      ),
                      _label('Ghi chú'),
                      TextFormField(
                        controller: _noteController,
                        maxLines: 3,
                        decoration: _decoration(hint: 'Nhập ghi chú (tùy chọn)'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2169E8),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
                    ),
                    child: Text(_saving ? 'Đang lưu...' : 'Lưu', style: const TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

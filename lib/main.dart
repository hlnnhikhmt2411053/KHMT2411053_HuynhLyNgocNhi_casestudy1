import 'dashboard.dart';
import 'package:flutter/material.dart';

void main() => runApp(const ExpenseManagerApp());

class ExpenseManagerApp extends StatelessWidget {
  const ExpenseManagerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Expense Manager',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF2169E8)),
      ),
      home: const DashboardScreen(),
      routes: {
        '/add': (context) => const TransactionScreen(),
        '/edit': (context) =>
        const TransactionScreen(isEdit: true),
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Expense Manager'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.account_balance_wallet_rounded,
                size: 95, color: Color(0xFF1976D2)),
            const SizedBox(height: 18),
            const Text('Expense Manager',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            const Text('Quản lý chi tiêu cá nhân\nđơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(0xFF8190A5))),
            const SizedBox(height: 45),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionScreen())),
                child: const Text('Thêm giao dịch'),
              ),
            ),
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: OutlinedButton(
                onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const TransactionScreen(isEdit: true))),
                child: const Text('Sửa giao dịch'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TransactionScreen extends StatefulWidget {
  final bool isEdit;

  const TransactionScreen({super.key, this.isEdit = false});

  @override
  State<TransactionScreen> createState() => _TransactionScreenState();
}

class _TransactionScreenState extends State<TransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController amountController;
  late final TextEditingController noteController;
  String transactionType = 'Chi tiêu';
  String category = 'Ăn uống';
  DateTime selectedDate = DateTime(2025, 4, 12);

  static const red = Color(0xFFFF626B);
  static const blue = Color(0xFF2169E8);
  static const navy = Color(0xFF1B2B49);
  static const borderColor = Color(0xFFD9E1ED);

  final List<String> categories = const [
    'Ăn uống', 'Mua sắm', 'Di chuyển', 'Giải trí', 'Lương', 'Khác'
  ];

  @override
  void initState() {
    super.initState();
    amountController = TextEditingController(text: widget.isEdit ? '100.000' : '');
    noteController = TextEditingController(text: widget.isEdit ? 'Ăn trưa' : '');
  }

  @override
  void dispose() {
    amountController.dispose();
    noteController.dispose();
    super.dispose();
  }

  String dateText(DateTime d) =>
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';

  Future<void> selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (date != null && mounted) setState(() => selectedDate = date);
  }

  InputDecoration inputStyle({String? hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Color(0xFF94A3B8), fontSize: 14),
      suffixIcon: suffix,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: borderColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: blue, width: 1.5),
      ),
    );
  }

  Widget fieldLabel(String label) => Padding(
    padding: const EdgeInsets.only(top: 20, bottom: 9),
    child: Text(label,
        style: const TextStyle(
            color: navy, fontSize: 14, fontWeight: FontWeight.bold)),
  );

  Widget typeButton(String type) {
    final selected = transactionType == type;
    return Expanded(
      child: InkWell(
        onTap: () => setState(() => transactionType = type),
        borderRadius: BorderRadius.circular(8),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: selected ? (type == 'Chi tiêu' ? red : blue) : Colors.white,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: selected ? Colors.transparent : borderColor),
          ),
          child: Text(type,
              style: TextStyle(
                  color: selected ? Colors.white : navy,
                  fontWeight: FontWeight.w600)),
        ),
      ),
    );
  }

  void saveTransaction() {
    if (!_formKey.currentState!.validate()) return;
    final money = int.tryParse(
        amountController.text.replaceAll(RegExp(r'[.,\s]'), ''));
    if (money == null || money <= 0) return;

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(widget.isEdit
          ? 'Cập nhật giao dịch thành công (bản demo)!'
          : 'Thêm giao dịch thành công (bản demo)!'),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: Text(widget.isEdit ? 'Sửa giao dịch' : 'Thêm giao dịch',
            style: const TextStyle(
                color: navy, fontSize: 17, fontWeight: FontWeight.bold)),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    children: [
                      Row(children: [
                        typeButton('Chi tiêu'),
                        const SizedBox(width: 5),
                        typeButton('Thu nhập'),
                      ]),
                      fieldLabel('Danh mục'),
                      DropdownButtonFormField<String>(
                        value: category,
                        decoration: inputStyle(),
                        items: categories
                            .map((item) => DropdownMenuItem<String>(
                          value: item,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.restaurant,
                                  color: red, size: 20),
                              const SizedBox(width: 12),
                              Text(item),
                            ],
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          if (value != null) setState(() => category = value);
                        },
                      ),
                      fieldLabel('Số tiền'),
                      TextFormField(
                        controller: amountController,
                        keyboardType: TextInputType.number,
                        decoration: inputStyle(
                          hint: 'Nhập số tiền',
                          suffix: const Center(
                            widthFactor: 1,
                            child: Text('đ',
                                style: TextStyle(color: Color(0xFF64748B))),
                          ),
                        ),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Vui lòng nhập số tiền';
                          }
                          final amount = int.tryParse(
                              value.replaceAll(RegExp(r'[.,\s]'), ''));
                          if (amount == null || amount <= 0) {
                            return 'Số tiền không hợp lệ';
                          }
                          return null;
                        },
                      ),
                      fieldLabel('Ngày giao dịch'),
                      InkWell(
                        onTap: selectDate,
                        child: InputDecorator(
                          decoration: inputStyle(
                            suffix: const Icon(Icons.calendar_month_outlined,
                                color: Color(0xFF64748B)),
                          ),
                          child: Text(dateText(selectedDate),
                              style: const TextStyle(
                                  color: navy, fontWeight: FontWeight.w500)),
                        ),
                      ),
                      fieldLabel('Ghi chú'),
                      TextFormField(
                        controller: noteController,
                        maxLines: 3,
                        decoration: inputStyle(hint: 'Nhập ghi chú (tùy chọn)'),
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: saveTransaction,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: blue,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text('Lưu',
                        style: TextStyle(
                            fontSize: 16, fontWeight: FontWeight.bold)),
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

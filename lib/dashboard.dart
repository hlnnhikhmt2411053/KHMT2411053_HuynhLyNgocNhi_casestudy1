
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  static const blue = Color(0xFF2169E8);
  static const dark = Color(0xFF172542);
  static const red = Color(0xFFFF626B);
  static const bg = Color(0xFFF5F8FF);

  // Du lieu mau cho bai thuc hanh buoi 4
  finalPlaceholder() {}

  void openAdd(BuildContext context) {
    Navigator.pushNamed(context, '/add');
  }

  void openEdit(BuildContext context) {
    Navigator.pushNamed(context, '/edit');
  }

  void showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Widget moneyCard() {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: blue,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: blue.withValues(alpha: 0.20),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tổng số dư',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '12.500.000 đ',
            style: TextStyle(
              color: Colors.white,
              fontSize: 29,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 26),
          Row(
            children: [
              Expanded(
                child: moneyInfo(
                  Icons.south_west,
                  'Thu nhập',
                  '18.000.000 đ',
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: moneyInfo(
                  Icons.north_east,
                  'Chi tiêu',
                  '5.500.000 đ',
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget moneyInfo(
      IconData icon,
      String label,
      String amount,
      ) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            color: Colors.white24,
            borderRadius: BorderRadius.circular(9),
          ),
          child: Icon(
            icon,
            color: Colors.white,
            size: 19,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 4),
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  amount,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget statisticsCard() {
    const income = 18000000.0;
    const expense = 5500000.0;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Thống kê thu chi',
                style: TextStyle(
                  color: dark,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Tháng này',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Row(
              children: [
                Expanded(
                  flex: income.toInt(),
                  child: Container(
                    color: blue,
                    height: 15,
                  ),
                ),
                Expanded(
                  flex: expense.toInt(),
                  child: Container(
                    color: red,
                    height: 15,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Icon(Icons.circle, size: 11, color: blue),
                  SizedBox(width: 6),
                  Text('Thu nhập'),
                ],
              ),
              Row(
                children: [
                  Icon(Icons.circle, size: 11, color: red),
                  SizedBox(width: 6),
                  Text('Chi tiêu'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget transactionItem({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String category,
    required String date,
    required String amount,
    required bool isIncome,
  }) {
    return InkWell(
      onTap: () => openEdit(context),
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: isIncome
                    ? const Color(0xFFE1F7E9)
                    : const Color(0xFFFFECEE),
                borderRadius: BorderRadius.circular(13),
              ),
              child: Icon(
                icon,
                color: isIncome
                    ? const Color(0xFF20A765)
                    : red,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: dark,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$category • $date',
                    style: const TextStyle(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Text(
              amount,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: isIncome
                    ? const Color(0xFF20A765)
                    : red,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget recentTransactions(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment:
            MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Giao dịch gần đây',
                style: TextStyle(
                  fontSize: 17,
                  color: dark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              TextButton(
                onPressed: () {
                  showMessage(
                    context,
                    'Danh sách giao dịch sẽ hoàn thiện sau',
                  );
                },
                child: const Text('Xem tất cả'),
              ),
            ],
          ),
          transactionItem(
            context: context,
            icon: Icons.restaurant,
            title: 'Ăn trưa',
            category: 'Ăn uống',
            date: '12/04/2025',
            amount: '-100.000 đ',
            isIncome: false,
          ),
          const Divider(height: 1),
          transactionItem(
            context: context,
            icon: Icons.shopping_bag,
            title: 'Mua sắm',
            category: 'Mua sắm',
            date: '11/04/2025',
            amount: '-250.000 đ',
            isIncome: false,
          ),
          const Divider(height: 1),
          transactionItem(
            context: context,
            icon: Icons.payments,
            title: 'Nhận lương',
            category: 'Thu nhập',
            date: '10/04/2025',
            amount: '+8.000.000 đ',
            isIncome: true,
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: bg,
        elevation: 0,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Xin chào!',
              style: TextStyle(
                fontSize: 13,
                color: Colors.grey,
              ),
            ),
            Text(
              'Expense Manager',
              style: TextStyle(
                color: dark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {
              showMessage(
                context,
                'Chưa có thông báo mới',
              );
            },
            icon: const Icon(
              Icons.notifications_none,
              color: dark,
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            moneyCard(),
            const SizedBox(height: 22),
            statisticsCard(),
            const SizedBox(height: 22),
            recentTransactions(context),
            const SizedBox(height: 24),
            SizedBox(
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () => openAdd(context),
                icon: const Icon(Icons.add),
                label: const Text(
                  'Thêm giao dịch',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius:
                    BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: 0,
        onDestinationSelected: (index) {
          if (index == 1) {
            openAdd(context);
          } else if (index != 0) {
            showMessage(
              context,
              'Chức năng đang được phát triển',
            );
          }
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Trang chủ',
          ),
          NavigationDestination(
            icon: Icon(Icons.add_circle_outline),
            label: 'Thêm',
          ),
          NavigationDestination(
            icon: Icon(Icons.bar_chart_outlined),
            label: 'Thống kê',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Cá nhân',
          ),
        ],
      ),
    );
  }
}

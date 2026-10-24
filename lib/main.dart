
import 'package:flutter/material.dart';

void main() {
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
        fontFamily: 'Roboto',
      ),
      home: const WelcomeScreen(),
    );
  }
}

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Column(
            children: [
              const Spacer(flex: 3),

              SizedBox(
                width: 110,
                height: 100,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Positioned(
                      top: 5,
                      left: 30,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF81C784),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 15,
                      left: 20,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF4CAF50),
                          borderRadius:
                          BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 30,
                      child: Container(
                        width: 105,
                        height: 65,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1976D2),
                          borderRadius:
                          BorderRadius.circular(14),
                        ),
                      ),
                    ),
                    Positioned(
                      top: 50,
                      right: 2,
                      child: Container(
                        width: 40,
                        height: 25,
                        decoration: BoxDecoration(
                          color: const Color(0xFF0D47A1),
                          borderRadius:
                          BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.circle,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'Expense Manager',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF152238),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Quản lý chi tiêu cá nhân\n'
                    'đơn giản và hiệu quả',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.5,
                  color: Color(0xFF8190A5),
                ),
              ),

              const Spacer(flex: 4),

              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Chào mừng đến Expense Manager!'),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                    const Color(0xFF1967C2),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius:
                      BorderRadius.circular(9),
                    ),
                  ),
                  child: const Text(
                    'Bắt đầu',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

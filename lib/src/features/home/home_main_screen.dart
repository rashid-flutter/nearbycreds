import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearbycreds/src/features/cart/cart_page.dart';
import 'package:nearbycreds/src/features/home/screens/home_screen.dart';
import 'package:nearbycreds/src/features/home/screens/redeem_history.dart';
import 'package:nearbycreds/src/features/profile/pages/Profile_screen.dart';
import 'package:nearbycreds/src/features/scanner/screen/scanner_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartPage(),
    ScannerScreen(),
    RedeemHistoryPage(),
    ProfileScreen(),
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBarItem(
      {required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],

      // Modern scanner button
      floatingActionButton: FloatingActionButton(
        onPressed: () => _onTabTapped(2),
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        elevation: 6,
        child: const Icon(Icons.qr_code_scanner, color: Colors.white, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,

      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        elevation: 8,
        color: Colors.white,
        child: SizedBox(
          height: 70,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Left side items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBarItem(icon: Icons.home, label: 'Home', index: 0),
                    _buildBarItem(
                        icon: Icons.shopping_cart, label: 'Cart', index: 1),
                  ],
                ),
              ),

              // Spacer for FAB in the center
              const SizedBox(width: 70), // Room for the FAB notch

              // Right side items
              Expanded(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _buildBarItem(
                        icon: Icons.history, label: 'History', index: 3),
                    _buildBarItem(
                        icon: Icons.person, label: 'Profile', index: 4),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

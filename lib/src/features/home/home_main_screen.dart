import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:nearbycreds/src/features/cart/cart_page.dart';
import 'package:nearbycreds/src/features/home/screens/home_screen.dart';
import 'package:nearbycreds/src/features/home/screens/redeem_history.dart';
import 'package:nearbycreds/src/features/profile/pages/Profile_screen.dart';

class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}


class _MainScreenState extends ConsumerState<MainScreen> with TickerProviderStateMixin {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    CartPage(),
    RedeemHistoryPage(), 
    ProfileScreen(),
    // Add this line for Redeem History screen
  ];

  void _onTabTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildBarItem({required IconData icon, required String label, required int index}) {
    final isSelected = _selectedIndex == index;

    return GestureDetector(
      onTap: () => _onTabTapped(index),
      child: AnimatedScale(
        scale: isSelected ? 1.2 : 1.0,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        child: Column(
          mainAxisSize: MainAxisSize.min,
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
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildBarItem(icon: Icons.home, label: 'Home', index: 0),
            _buildBarItem(icon: Icons.shopping_cart, label: 'Cart', index: 1),
             _buildBarItem(icon: Icons.history, label: 'History', index: 2),
            _buildBarItem(icon: Icons.person, label: 'Profile', index: 3), // Adjusted index for Profile
          ],
        ),
      ),
    );
  }
}

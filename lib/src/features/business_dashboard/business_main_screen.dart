import 'package:flutter/material.dart';
import 'package:nearbycreds/src/features/profile/pages/Profile_screen.dart';
import 'package:nearbycreds/src/features/business_dashboard/pages/add_edit_shops.dart';
import 'package:nearbycreds/src/features/business_dashboard/pages/bussiness_dashboard.dart';

class BusinessMainScreen extends StatefulWidget {
  const BusinessMainScreen({super.key});

  @override
  State<BusinessMainScreen> createState() => _BusinessMainScreenState();
}

class _BusinessMainScreenState extends State<BusinessMainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [];

  @override
  void initState() {
    super.initState();
    _pages.addAll([
      const BussinessDashboard(),
      AddEditShopScreen(
        onSubmitSuccess: () {
          setState(() => _selectedIndex = 0); // Back to dashboard
        },
      ),
      const ProfileScreen(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _selectedIndex, children: _pages),
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 8.0,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(Icons.store,
                    color: _selectedIndex == 0 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 0),
              ),
              IconButton(
                icon: Icon(Icons.person,
                    color: _selectedIndex == 2 ? Colors.blue : Colors.grey),
                onPressed: () => setState(() => _selectedIndex = 2),
              ),
            ],
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => setState(() => _selectedIndex = 1),
        shape: CircleBorder(side: BorderSide(color: Colors.white)),
        backgroundColor: Colors.blue, // Blue background for center button
        child: const Icon(
          Icons.add,
          color: Colors.white, // White icon for contrast
        ),
        elevation: 6.0, // Optional: Adds some shadow to the button for depth
      ),
    );
  }
}

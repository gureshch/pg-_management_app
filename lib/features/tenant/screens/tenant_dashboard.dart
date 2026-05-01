import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'tenant_home.dart';
import 'meal_screen.dart';
import 'profile_screen.dart';
import 'complaints_screen.dart';

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _selectedIndex = 0;

  // Screens corresponding to each BottomNavBar item
  final List<Widget> _screens = [
    const TenantHomeScreen(),
    const MealScreen(),
    const ComplaintsScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded), 
            activeIcon: Icon(Icons.home_filled),
            label: "Home"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_rounded), 
            label: "Meals"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.report_problem_rounded), 
            label: "Issues"
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_rounded), 
            label: "Profile"
          ),
        ],
      ),
    );
  }
}
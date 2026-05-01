import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/auth_service.dart';
import '../../auth/screens/login_screen.dart';
import 'meal_screen.dart'; // Ensure this matches your filename

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int _selectedIndex = 0;

  // The screens for the tenant tabs
  final List<Widget> _screens = [
    const Center(child: Text("Home / Announcements")), 
    const MealScreen(), // This matches the class name in your meal_screen.dart
    const Center(child: Text("My Complaints")),
    const Center(child: Text("Profile")),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_rounded), label: "Meals"),
          BottomNavigationBarItem(icon: Icon(Icons.report_problem_rounded), label: "Complaints"),
          BottomNavigationBarItem(icon: Icon(Icons.person_rounded), label: "Profile"),
        ],
      ),
      // Added a floating logout for convenience during testing
      floatingActionButton: _selectedIndex == 3 
          ? FloatingActionButton.extended(
              onPressed: () async {
                await AuthService().signOut();
                Navigator.pushAndRemoveUntil(
                  context, 
                  MaterialPageRoute(builder: (_) => const LoginScreen()), 
                  (route) => false
                );
              },
              label: const Text("Logout"),
              icon: const Icon(Icons.logout),
              backgroundColor: Colors.redAccent,
            )
          : null,
    );
  }
}
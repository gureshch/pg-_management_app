import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';
import '../../auth/screens/login_screen.dart';
import 'tenant_home.dart';
import 'meal_screen.dart';
import 'complaint_screen.dart';
import 'profile_screen.dart'; // ✅ new import

class TenantDashboard extends StatefulWidget {
  const TenantDashboard({super.key});

  @override
  State<TenantDashboard> createState() => _TenantDashboardState();
}

class _TenantDashboardState extends State<TenantDashboard> {
  int index = 0;

  final screens = const [
    TenantHome(),
    MealScreen(),
    TenantComplaintsScreen(),
    ProfileScreen(), // ✅ new tab
  ];

  void logout() async {
    await SessionService().clearSession();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF6C5DD3),
        selectedFontSize: 12,
        unselectedFontSize: 11,
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Home",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant_menu),
            label: "Meals",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.build),
            label: "Complaints",
          ),
          BottomNavigationBarItem( // ✅ new tab
            icon: Icon(Icons.person),
            label: "Profile",
          ),
        ],
      ),
    );
  }
}
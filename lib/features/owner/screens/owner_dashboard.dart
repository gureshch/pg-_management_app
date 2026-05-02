import 'package:flutter/material.dart';
import '../../../core/services/session_service.dart';
import '../../auth/screens/login_screen.dart';
import 'owner_home.dart';
import 'rooms_screen.dart';
import 'complaints_screen.dart';
import 'meals_count_screen.dart'; // ✅ new import

class OwnerDashboard extends StatefulWidget {
  const OwnerDashboard({super.key});

  @override
  State<OwnerDashboard> createState() => _OwnerDashboardState();
}

class _OwnerDashboardState extends State<OwnerDashboard> {
  int index = 0;

  final screens = const [
    OwnerHome(),
    RoomsScreen(),
    ComplaintsScreen(),
    MealsCountScreen(), // ✅ new tab
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
      appBar: AppBar(
        title: const Text("Owner Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
            onPressed: () {
              showDialog(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cancel"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                        logout();
                      },
                      child: const Text("Logout"),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: screens[index],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: index,
        showUnselectedLabels: true,
        selectedItemColor: const Color(0xFF6C5DD3),
        onTap: (i) => setState(() => index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.meeting_room), label: "Rooms"),
          BottomNavigationBarItem(icon: Icon(Icons.build), label: "Complaints"),
          BottomNavigationBarItem(icon: Icon(Icons.restaurant_menu), label: "Meals"), // ✅ new
        ],
      ),
    );
  }
}
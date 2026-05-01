import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import 'meal_screen.dart';
import 'complaints_screen.dart';

class TenantHomeScreen extends StatelessWidget {
  const TenantHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FD),
      appBar: AppBar(
        title: const Text("My PG", style: TextStyle(fontWeight: FontWeight.bold)),
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Colors.black,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column( // Fixed the 'children' error by adding a Column
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Room Information Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.primary,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const CircleAvatar(
                    radius: 30, 
                    backgroundColor: Colors.white24, 
                    child: Icon(Icons.person, color: Colors.white)
                  ),
                  const SizedBox(width: 15),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text("Room 204", style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      Text("Bed B | Rent Paid", style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            const Text("Quick Actions", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 15),
            
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 15,
              mainAxisSpacing: 15,
              children: [
                _buildMenuCard(
                  context, 
                  "Daily Meals", 
                  Icons.restaurant, 
                  Colors.orange,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const MealScreen()))
                ),
                _buildMenuCard(
                  context, 
                  "Raise Issue", 
                  Icons.report_problem, 
                  Colors.redAccent,
                  () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ComplaintsScreen()))
                ),
                _buildMenuCard(
                  context, 
                  "Payments", 
                  Icons.account_balance_wallet, 
                  Colors.blue,
                  () => {} // Future: Payment Screen
                ),
                _buildMenuCard(
                  context, 
                  "Notice Board", 
                  Icons.campaign, 
                  Colors.green,
                  () => {} // Future: Announcements
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 10)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: color.withOpacity(0.1), shape: BoxShape.circle),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
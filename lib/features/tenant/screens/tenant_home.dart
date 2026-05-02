import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/session_service.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import 'add_complaint_screen.dart';

class TenantHome extends StatefulWidget {
  const TenantHome({super.key});

  @override
  State<TenantHome> createState() => _TenantHomeState();
}

class _TenantHomeState extends State<TenantHome> {
  String name = "";
  String phone = "";
  bool breakfast = false;
  bool lunch = false;
  bool dinner = false;
  bool mealsLoaded = false;

  final String today = DateFormat('yyyy-MM-dd').format(DateTime.now());

  @override
  void initState() {
    super.initState();
    loadData();
  }

  Future<void> loadData() async {
    final user = await SessionService().getUser();
    if (user != null) {
      setState(() {
        name = user['name'] ?? "";
        phone = user['phone'] ?? "";
      });

      // ✅ Load today's meal status from Firestore
      final meal = await FirestoreService().getMeal(phone, today);
      if (meal != null) {
        setState(() {
          breakfast = meal['breakfast'] ?? false;
          lunch = meal['lunch'] ?? false;
          dinner = meal['dinner'] ?? false;
          mealsLoaded = true;
        });
      } else {
        setState(() => mealsLoaded = true);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              /// 🔔 Top Bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    "Dashboard",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        size: 20, color: Colors.black87),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              /// 👋 Greeting
              Text(
                "Hi, $name 👋",
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),

              const SizedBox(height: 6),

              /// 🏠 Room Info
              Row(
                children: [
                  const Icon(Icons.bed_outlined,
                      size: 16, color: Colors.grey),
                  const SizedBox(width: 6),
                  const Text(
                    "Room 101 - Bed 2",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              /// 🍽 Today's Meals Header Card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.primary.withOpacity(0.15),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Today's Meals",
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Mark your availability before\ncut-off time",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.black54,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.dining, size: 48, color: AppColors.primary),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              /// 🍳 Meal Tiles
              if (!mealsLoaded)
                const Center(child: CircularProgressIndicator())
              else ...[
                _mealTile(
                  meal: "Breakfast",
                  cutoff: "Before 8:30 AM",
                  selected: breakfast,
                ),
                _mealTile(
                  meal: "Lunch",
                  cutoff: "Before 10:00 AM",
                  selected: lunch,
                ),
                _mealTile(
                  meal: "Dinner",
                  cutoff: "Before 7:00 PM",
                  selected: dinner,
                ),
              ],

              const SizedBox(height: 24),

              /// ➕ Raise Complaint Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const AddComplaintScreen()),
                    );
                  },
                  icon: const Icon(Icons.add, color: AppColors.primary),
                  label: const Text(
                    "Raise a Complaint",
                    style: TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    side: const BorderSide(color: AppColors.primary),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  Widget _mealTile({
    required String meal,
    required String cutoff,
    required bool selected,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                meal,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                cutoff,
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),

          /// ✅ Green check / ❌ Red cross
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: selected ? AppColors.success : AppColors.danger,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              selected ? Icons.check : Icons.close,
              color: Colors.white,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }
}
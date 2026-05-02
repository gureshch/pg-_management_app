import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/stat_card.dart';
import '../../../core/services/firestore_service.dart';

class MealsCountScreen extends StatefulWidget {
  const MealsCountScreen({super.key});

  @override
  State<MealsCountScreen> createState() => _MealsCountScreenState();
}

class _MealsCountScreenState extends State<MealsCountScreen> {
  DateTime selectedDate = DateTime.now();
  final _firestore = FirestoreService();

  String get formattedDate => DateFormat('yyyy-MM-dd').format(selectedDate);
  String get displayDate => DateFormat('dd MMM yyyy').format(selectedDate);

  Future<void> pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate,
      firstDate: DateTime(2024),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Counts"),
      ),
      body: Column(
        children: [

          /// 📅 Date Picker Bar
          GestureDetector(
            onTap: pickDate,
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.primary.withOpacity(0.3)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.calendar_today,
                          color: AppColors.primary, size: 18),
                      const SizedBox(width: 10),
                      Text(
                        displayDate,
                        style: const TextStyle(
                          fontWeight: FontWeight.w600,
                          color: AppColors.primary,
                        ),
                      ),
                    ],
                  ),
                  const Icon(Icons.arrow_drop_down, color: AppColors.primary),
                ],
              ),
            ),
          ),

          /// 🔥 Live Stream from flat meal_logs collection
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.getMealsByDate(formattedDate), // ✅ fixed query
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No meal data for this date",
                      style: TextStyle(color: Colors.grey),
                    ),
                  );
                }

                final docs = snapshot.data!.docs;

                /// ✅ Counts calculated client-side from stream
                int breakfastCount = 0;
                int lunchCount = 0;
                int dinnerCount = 0;

                final List<Map<String, dynamic>> tenantMeals = [];

                for (final doc in docs) {
                  final data = doc.data() as Map<String, dynamic>? ?? {};

                  final b = data['breakfast'] == true;
                  final l = data['lunch'] == true;
                  final d = data['dinner'] == true;

                  if (b) breakfastCount++;
                  if (l) lunchCount++;
                  if (d) dinnerCount++;

                  tenantMeals.add({
                    'userId': data['userId'] ?? 'Unknown',
                    'breakfast': b,
                    'lunch': l,
                    'dinner': d,
                  });
                }

                return SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      /// 📊 Summary Stat Cards
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(
                            title: "Breakfast",
                            value: "$breakfastCount",
                            icon: Icons.free_breakfast,
                          ),
                          StatCard(
                            title: "Lunch",
                            value: "$lunchCount",
                            icon: Icons.lunch_dining,
                          ),
                          StatCard(
                            title: "Dinner",
                            value: "$dinnerCount",
                            icon: Icons.dinner_dining,
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      /// 👤 Per Tenant Breakdown
                      const Text(
                        "Tenant Breakdown",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 10),

                      ...tenantMeals.map((meal) {
                        return GlassCard(
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  meal['userId'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                              _mealDot("B", meal['breakfast']),
                              const SizedBox(width: 6),
                              _mealDot("L", meal['lunch']),
                              const SizedBox(width: 6),
                              _mealDot("D", meal['dinner']),
                            ],
                          ),
                        );
                      }),

                      const SizedBox(height: 20),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _mealDot(String label, bool active) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: active
            ? AppColors.success.withOpacity(0.15)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: active ? AppColors.success : Colors.grey.shade300,
        ),
      ),
      alignment: Alignment.center,
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: active ? AppColors.success : Colors.grey,
        ),
      ),
    );
  }
}
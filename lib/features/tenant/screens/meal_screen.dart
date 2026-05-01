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
      // Allowing owners to look ahead for planning
      lastDate: DateTime.now().add(const Duration(days: 30)), 
    );
    if (picked != null) {
      setState(() => selectedDate = picked);
    }
  }

  /// Helper to fetch User Name instead of just showing the UID
  Future<String> _getUserName(String uid) async {
    try {
      var doc = await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return doc.data()?['name'] ?? "Unknown Tenant";
    } catch (e) {
      return "User ($uid)";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Meal Overview"),
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
                      const Icon(Icons.calendar_today, color: AppColors.primary, size: 18),
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

          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore.getMealsByDate(formattedDate),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                
                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text("No meal records for this date", 
                      style: TextStyle(color: Colors.grey)),
                  );
                }

                final docs = snapshot.data!.docs;
                int breakfastCount = 0, lunchCount = 0, dinnerCount = 0;
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
                      /// 📊 Stat Grid
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                        physics: const NeverScrollableScrollPhysics(),
                        children: [
                          StatCard(title: "Breakfast", value: "$breakfastCount", icon: Icons.coffee),
                          StatCard(title: "Lunch", value: "$lunchCount", icon: Icons.lunch_dining),
                          StatCard(title: "Dinner", value: "$dinnerCount", icon: Icons.dinner_dining),
                        ],
                      ),

                      const SizedBox(height: 25),
                      const Text("Tenant Breakdown", 
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 12),

                      /// 👤 Tenant List
                      ...tenantMeals.map((meal) {
                        return GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 4),
                            child: Row(
                              children: [
                                Expanded(
                                  child: FutureBuilder<String>(
                                    future: _getUserName(meal['userId']),
                                    builder: (context, nameSnapshot) {
                                      return Text(
                                        nameSnapshot.data ?? "Loading...",
                                        style: const TextStyle(fontWeight: FontWeight.w600),
                                        overflow: TextOverflow.ellipsis,
                                      );
                                    },
                                  ),
                                ),
                                _mealDot("B", meal['breakfast']),
                                const SizedBox(width: 8),
                                _mealDot("L", meal['lunch']),
                                const SizedBox(width: 8),
                                _mealDot("D", meal['dinner']),
                              ],
                            ),
                          ),
                        );
                      }),
                      const SizedBox(height: 30),
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
      width: 35, height: 35,
      decoration: BoxDecoration(
        color: active ? AppColors.success.withOpacity(0.15) : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: active ? AppColors.success : Colors.grey.shade300),
      ),
      alignment: Alignment.center,
      child: Text(label, style: TextStyle(
        fontSize: 12, fontWeight: FontWeight.bold,
        color: active ? AppColors.success : Colors.grey)),
    );
  }
}
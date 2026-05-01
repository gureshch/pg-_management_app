import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/theme/app_colors.dart';

class MealScreen extends StatefulWidget {
  const MealScreen({super.key});

  @override
  State<MealScreen> createState() => _MealScreenState();
}

class _MealScreenState extends State<MealScreen> {
  bool breakfast = false, lunch = false, dinner = false;
  bool isLoading = true;
  String userId = "";
  DateTime selectedDate = DateTime.now();

  // Cutoff times
  final _breakfastCutoff = const TimeOfDay(hour: 8, minute: 30);
  final _lunchCutoff = const TimeOfDay(hour: 10, minute: 0);
  final _dinnerCutoff = const TimeOfDay(hour: 19, minute: 0);

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  bool _isLocked(TimeOfDay cutoff) {
    if (DateFormat('yyyy-MM-dd').format(selectedDate) != DateFormat('yyyy-MM-dd').format(DateTime.now())) {
      return false; 
    }
    final now = TimeOfDay.now();
    return (now.hour * 60 + now.minute) >= (cutoff.hour * 60 + cutoff.minute);
  }

  Future<void> _loadData() async {
    userId = await SessionService().getUserId();
    
    // 🛡️ Stop here if userId is not yet available to prevent crash
    if (userId.isEmpty) {
      if (mounted) setState(() => isLoading = false);
      return;
    }

    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate);
    final data = await FirestoreService().getMeal(userId, dateStr);
    
    if (mounted) {
      setState(() {
        breakfast = data?['breakfast'] ?? false;
        lunch = data?['lunch'] ?? false;
        dinner = data?['dinner'] ?? false;
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(title: const Text("Meal Attendance"), centerTitle: true),
      body: Column(
        children: [
          // 📅 Restored Week Strip
          Container(
            height: 90,
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: 7,
              itemBuilder: (context, i) {
                final date = DateTime.now().add(Duration(days: i));
                bool isSelected = DateFormat('yyyy-MM-dd').format(date) == DateFormat('yyyy-MM-dd').format(selectedDate);
                return GestureDetector(
                  onTap: () {
                    setState(() { selectedDate = date; isLoading = true; });
                    _loadData();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: 55,
                    margin: const EdgeInsets.only(right: 12),
                    decoration: BoxDecoration(
                      color: isSelected ? AppColors.primary : Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: isSelected ? [BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))] : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(DateFormat('E').format(date), style: TextStyle(color: isSelected ? Colors.white70 : Colors.grey, fontSize: 12)),
                        Text(DateFormat('d').format(date), style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
          
          Expanded(
            child: isLoading 
              ? const Center(child: CircularProgressIndicator())
              : ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    _mealTile("Breakfast", "Cutoff: 08:30 AM", breakfast, _isLocked(_breakfastCutoff), (v) => setState(() => breakfast = v)),
                    _mealTile("Lunch", "Cutoff: 10:00 AM", lunch, _isLocked(_lunchCutoff), (v) => setState(() => lunch = v)),
                    _mealTile("Dinner", "Cutoff: 07:00 PM", dinner, _isLocked(_dinnerCutoff), (v) => setState(() => dinner = v)),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () async {
                        await FirestoreService().saveMeal(
                          userId: userId, 
                          date: DateFormat('yyyy-MM-dd').format(selectedDate), 
                          breakfast: breakfast, lunch: lunch, dinner: dinner
                        );
                        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Preferences saved successfully!"), backgroundColor: AppColors.success));
                      },
                      child: const Text("Save Daily Choice", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
          ),
        ],
      ),
    );
  }

  Widget _mealTile(String title, String subtitle, bool val, bool locked, ValueChanged<bool> onChanged) {
    return Card(
      margin: const EdgeInsets.only(bottom: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: CheckboxListTile(
        title: Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: locked ? Colors.grey : Colors.black87)),
        subtitle: Text(subtitle, style: TextStyle(color: locked ? Colors.redAccent : Colors.grey)),
        secondary: Icon(Icons.restaurant_menu, color: locked ? Colors.grey : AppColors.primary),
        activeColor: AppColors.primary,
        value: val,
        onChanged: locked ? null : (v) => onChanged(v!),
      ),
    );
  }
}
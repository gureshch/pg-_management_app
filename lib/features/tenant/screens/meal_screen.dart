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
  // ─── State ───────────────────────────────────────────
  bool breakfast = false;
  bool lunch = false;
  bool dinner = false;
  bool isLoading = true;
  bool isSaving = false;
  String userId = "";

  // ─── Week strip: today + next 6 days ─────────────────
  final DateTime _today = DateTime.now();
  late DateTime selectedDate;

  // ─── Cutoff times ────────────────────────────────────
  // Breakfast: 8:30 AM | Lunch: 10:00 AM | Dinner: 7:00 PM
  static const _breakfastCutoff = TimeOfDay(hour: 8, minute: 30);
  static const _lunchCutoff = TimeOfDay(hour: 10, minute: 0);
  static const _dinnerCutoff = TimeOfDay(hour: 19, minute: 0);

  final _firestoreService = FirestoreService();

  @override
  void initState() {
    super.initState();
    selectedDate = _today;
    _loadUserId();
  }

  // ─── Helpers ─────────────────────────────────────────

  String _formatDate(DateTime date) => DateFormat('yyyy-MM-dd').format(date);

  bool _isToday(DateTime date) => _formatDate(date) == _formatDate(_today);

  bool _isPast(DateTime date) =>
      date.isBefore(DateTime(_today.year, _today.month, _today.day));

  /// Returns true if the cutoff for this meal has already passed TODAY
  bool _isCutoffPassed(TimeOfDay cutoff) {
    if (!_isToday(selectedDate)) return false; // future = not passed yet
    final now = TimeOfDay.now();
    final nowMinutes = now.hour * 60 + now.minute;
    final cutoffMinutes = cutoff.hour * 60 + cutoff.minute;
    return nowMinutes >= cutoffMinutes;
  }

  bool get breakfastLocked =>
      _isPast(selectedDate) || _isCutoffPassed(_breakfastCutoff);
  bool get lunchLocked =>
      _isPast(selectedDate) || _isCutoffPassed(_lunchCutoff);
  bool get dinnerLocked =>
      _isPast(selectedDate) || _isCutoffPassed(_dinnerCutoff);

  /// True if entire selected day is past (all read-only)
  bool get isDayReadOnly => _isPast(selectedDate);

  // ─── Data loading ─────────────────────────────────────

  Future<void> _loadUserId() async {
    userId = await SessionService().getUserId();
    await _loadMeal();
  }

  Future<void> _loadMeal() async {
    setState(() => isLoading = true);

    final data =
        await _firestoreService.getMeal(userId, _formatDate(selectedDate));

    setState(() {
      breakfast = data?['breakfast'] ?? false;
      lunch = data?['lunch'] ?? false;
      dinner = data?['dinner'] ?? false;
      isLoading = false;
    });
  }

  Future<void> _saveMeal() async {
    setState(() => isSaving = true);

    await _firestoreService.saveMeal(
      userId: userId,
      date: _formatDate(selectedDate),
      breakfast: breakfast,
      lunch: lunch,
      dinner: dinner,
    );

    setState(() => isSaving = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Meal preferences saved!"),
        backgroundColor: AppColors.success,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ─── Week strip dates ──────────────────────────────────

  List<DateTime> get _weekDates =>
      List.generate(7, (i) => _today.add(Duration(days: i)));

  // ─── Build ────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F8FC),
      appBar: AppBar(
        title: const Text("Meal Attendance"),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today_outlined),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: selectedDate,
                firstDate: _today,
                lastDate: _today.add(const Duration(days: 30)),
              );
              if (picked != null) {
                setState(() => selectedDate = picked);
                await _loadMeal();
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          /// 📅 Full date label
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
            child: Text(
              DateFormat('EEEE, d MMMM yyyy').format(selectedDate),
              style: const TextStyle(
                fontSize: 13,
                color: Colors.grey,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 📆 Week strip
          SizedBox(
            height: 72,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _weekDates.length,
              itemBuilder: (_, i) {
                final date = _weekDates[i];
                final isSelected =
                    _formatDate(date) == _formatDate(selectedDate);
                final isToday = _isToday(date);

                return GestureDetector(
                  onTap: () async {
                    setState(() => selectedDate = date);
                    await _loadMeal();
                  },
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    width: 52,
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppColors.primary
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: isSelected
                            ? AppColors.primary
                            : isToday
                                ? AppColors.primary.withOpacity(0.4)
                                : Colors.grey.shade200,
                      ),
                      boxShadow: isSelected
                          ? [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.3),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              )
                            ]
                          : [],
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat('EEE').format(date), // Mon, Tue...
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                            color:
                                isSelected ? Colors.white70 : Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          DateFormat('d').format(date), // 13, 14...
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isSelected
                                ? Colors.white
                                : Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),

          const SizedBox(height: 20),

          /// 🍽 Section header
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              "Mark your meal availability",
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          const SizedBox(height: 12),

          /// 🥘 Meal tiles
          Expanded(
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      _mealTile(
                        label: "Breakfast",
                        cutoffLabel: "Before 8:30 AM",
                        value: breakfast,
                        locked: breakfastLocked,
                        onChanged: (val) =>
                            setState(() => breakfast = val),
                      ),
                      _mealTile(
                        label: "Lunch",
                        cutoffLabel: "Before 10:00 AM",
                        value: lunch,
                        locked: lunchLocked,
                        onChanged: (val) => setState(() => lunch = val),
                      ),
                      _mealTile(
                        label: "Dinner",
                        cutoffLabel: "Before 7:00 PM",
                        value: dinner,
                        locked: dinnerLocked,
                        onChanged: (val) => setState(() => dinner = val),
                      ),

                      const SizedBox(height: 16),

                      /// ⚠️ Read-only notice
                      if (isDayReadOnly)
                        _infoBox(
                          "This is a past date. Meal preferences are read-only.",
                          AppColors.grey,
                        )
                      else if (breakfastLocked && lunchLocked && dinnerLocked)
                        _infoBox(
                          "You can update before cut-off time only.",
                          AppColors.primary,
                        )
                      else
                        _infoBox(
                          "You can update before cut-off time only.",
                          AppColors.primary,
                        ),

                      const SizedBox(height: 20),

                      /// 💾 Save button — hidden for past/fully locked days
                      if (!isDayReadOnly &&
                          !(breakfastLocked && lunchLocked && dinnerLocked))
                        SizedBox(
                          width: double.infinity,
                          child: isSaving
                              ? const Center(
                                  child: CircularProgressIndicator())
                              : ElevatedButton(
                                  onPressed: _saveMeal,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                        vertical: 14),
                                    shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    "Save Preferences",
                                    style: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      fontSize: 15,
                                    ),
                                  ),
                                ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  // ─── Meal tile widget ─────────────────────────────────

  Widget _mealTile({
    required String label,
    required String cutoffLabel,
    required bool value,
    required bool locked,
    required ValueChanged<bool> onChanged,
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
          /// Meal label + cutoff
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                  color: locked ? Colors.black38 : Colors.black87,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                cutoffLabel,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),

          /// ✅ Checkbox — disabled when locked
          GestureDetector(
            onTap: locked ? null : () => onChanged(!value),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: locked
                    ? Colors.grey.shade100
                    : value
                        ? AppColors.success
                        : Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: locked
                      ? Colors.grey.shade300
                      : value
                          ? AppColors.success
                          : Colors.grey.shade400,
                  width: 1.5,
                ),
              ),
              child: locked
                  ? Icon(
                      value ? Icons.check : Icons.remove,
                      size: 18,
                      color: Colors.grey.shade400,
                    )
                  : value
                      ? const Icon(Icons.check,
                          size: 18, color: Colors.white)
                      : null,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Info box ─────────────────────────────────────────

  Widget _infoBox(String message, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                fontSize: 12,
                color: color,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
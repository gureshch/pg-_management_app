import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // ===========================================================================
  // 🍽️ MEAL MANAGEMENT
  // ===========================================================================

  /// OWNER SIDE: Get a live stream of all meals for a specific date.
  /// Used in [MealsCountScreen](https://github.com/gureshch/pg-_management_app/blob/main/lib/features/owner/screens/meals_count_screen.dart)
  Stream<QuerySnapshot> getMealsByDate(String date) {
    return _db
        .collection('meal_logs')
        .where('date', isEqualTo: date)
        .snapshots();
  }

  /// TENANT SIDE: Fetch a single tenant's meal preference.
  /// 🛡️ Guarded to prevent "document path must be a non-empty string" error.
  Future<Map<String, dynamic>?> getMeal(String userId, String date) async {
    if (userId.isEmpty || date.isEmpty) return null;

    try {
      final doc = await _db.collection('meal_logs').doc("${userId}_$date").get();
      return doc.data();
    } catch (e) {
      return null;
    }
  }

  /// TENANT SIDE: Save or update meal attendance.
  /// Writes to a flat path for efficient owner querying.
  Future<void> saveMeal({
    required String userId,
    required String date,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    if (userId.isEmpty || date.isEmpty) return;

    await _db.collection('meal_logs').doc("${userId}_$date").set({
      'userId': userId,
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  // ===========================================================================
  // ⚠️ COMPLAINT MANAGEMENT
  // ===========================================================================

  /// TENANT SIDE: Raise a new issue.
  Future<void> createComplaint({
    required String userId,
    required String title,
    required String description,
  }) async {
    if (userId.isEmpty) return;

    await _db.collection('complaints').add({
      'userId': userId,
      'title': title,
      'description': description,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// TENANT SIDE: Get a list of complaints for a specific user.
  Stream<QuerySnapshot> getUserComplaints(String userId) {
    return _db
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }

  // ===========================================================================
  // 👤 USER / TENANT INFO
  // ===========================================================================

  /// OWNER SIDE: Get name for User UID [JX51CmbiiOdiQZkQyNWxLCeSTLt2](https://console.firebase.google.com/u/0/project/pg-management-app-6a329/authentication/users)
  Future<String> getTenantName(String uid) async {
    if (uid.isEmpty) return "Unknown";
    try {
      final doc = await _db.collection('users').doc(uid).get();
      return doc.data()?['name'] ?? "Unknown Tenant";
    } catch (e) {
      return "User ($uid)";
    }
  }
}
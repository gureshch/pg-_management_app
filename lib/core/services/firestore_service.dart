import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// 🔥 SAVE MEAL — writes to both nested (tenant use) and flat (owner query)
  Future<void> saveMeal({
    required String userId,
    required String date,
    required bool breakfast,
    required bool lunch,
    required bool dinner,
  }) async {
    // Nested path — used by tenant to read their own meal
    await _db
        .collection('meals')
        .doc(userId)
        .collection('dates')
        .doc(date)
        .set({
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
    });

    // ✅ Flat path — used by owner to query all meals by date efficiently
    await _db
        .collection('meal_logs')
        .doc('${date}_$userId')
        .set({
      'userId': userId,
      'date': date,
      'breakfast': breakfast,
      'lunch': lunch,
      'dinner': dinner,
      'updatedAt': Timestamp.now(),
    });
  }

  /// 🔥 GET MEAL (tenant)
  Future<Map<String, dynamic>?> getMeal(String userId, String date) async {
    final doc = await _db
        .collection('meals')
        .doc(userId)
        .collection('dates')
        .doc(date)
        .get();

    return doc.data();
  }

  /// 🔥 GET ALL MEALS BY DATE (owner) — flat collection, single query, live stream
  Stream<QuerySnapshot> getMealsByDate(String date) {
    return _db
        .collection('meal_logs')
        .where('date', isEqualTo: date)
        .snapshots();
  }

  /// 🛠 CREATE COMPLAINT
  Future<void> createComplaint({
    required String userId,
    required String title,
    required String description,
  }) async {
    await _db.collection('complaints').add({
      'userId': userId,
      'title': title,
      'description': description,
      'status': 'pending',
      'createdAt': Timestamp.now(),
    });
  }

  /// 📋 GET COMPLAINTS (tenant)
  Stream<QuerySnapshot> getUserComplaints(String userId) {
    return _db
        .collection('complaints')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots();
  }
}
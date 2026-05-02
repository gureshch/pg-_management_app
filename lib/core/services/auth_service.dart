import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

class AuthService {
  final _db = FirebaseFirestore.instance;

  /// 🔐 HASH PASSWORD using SHA-256
  String _hashPassword(String password) {
    final bytes = utf8.encode(password);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  /// REGISTER
  Future<String?> register({
    required String name,
    required String phone,
    required String password,
    required String role,
  }) async {
    try {
      final existing = await _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .get();

      if (existing.docs.isNotEmpty) {
        return "User already exists";
      }

      await _db.collection('users').add({
        "name": name,
        "phone": phone,
        "password": _hashPassword(password), // 🔐 store hashed
        "role": role,
        "createdAt": Timestamp.now(),
      });

      return null;
    } catch (e) {
      return e.toString();
    }
  }

  /// LOGIN
  Future<Map<String, dynamic>?> login({
    required String phone,
    required String password,
  }) async {
    try {
      final result = await _db
          .collection('users')
          .where('phone', isEqualTo: phone)
          .where('password', isEqualTo: _hashPassword(password)) // 🔐 compare hashed
          .get();

      if (result.docs.isEmpty) return null;

      return result.docs.first.data();
    } catch (e) {
      return null;
    }
  }
}
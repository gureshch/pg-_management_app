import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔑 Standard Login
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 🏠 Owner creates Tenant (Using Secondary App to keep Owner logged in)
  Future<void> createTenantAccount({
    required String email,
    required String tempPassword,
    required String name,
    required String roomNumber,
    required String bedNumber,
  }) async {
    try {
      // Create a secondary app to avoid logging out the current Owner
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: Firebase.app().options,
      );

      UserCredential result = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: tempPassword,
      );

      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'tenant',
          'roomNumber': roomNumber.trim(),
          'bedNumber': bedNumber.trim(),
          'profileCompleted': false, // Force setup on first login
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      await secondaryApp.delete();
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 📝 Tenant Completes Profile (First Login)
  Future<void> completeTenantProfile({
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePassword(newPassword.trim());
        await _firestore.collection('users').doc(user.uid).update({
          'profileCompleted': true,
        });
      }
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 👤 Fetch User Data
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  Future<void> signOut() async => await _auth.signOut();
}
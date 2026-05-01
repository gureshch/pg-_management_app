import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // 🔑 Standard Login for both Owner and Tenant
  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
          email: email.trim(), password: password.trim());
      return result.user;
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 🏠 Owner creates Tenant Account
  // This uses a 'SecondaryApp' instance so the Owner stays logged in
  Future<void> createTenantAccount({
    required String email,
    required String tempPassword,
    required String name,
    required String roomNumber,
    required String bedNumber,
  }) async {
    try {
      // 1. Initialize a temporary secondary app
      FirebaseApp secondaryApp = await Firebase.initializeApp(
        name: 'TenantCreationApp',
        options: Firebase.app().options,
      );

      // 2. Create the Auth User using the secondary app instance
      UserCredential result = await FirebaseAuth.instanceFor(app: secondaryApp)
          .createUserWithEmailAndPassword(
        email: email.trim(),
        password: tempPassword.trim(),
      );

      // 3. Store the Tenant details in the main Firestore 'users' collection
      if (result.user != null) {
        await _firestore.collection('users').doc(result.user!.uid).set({
          'uid': result.user!.uid,
          'name': name.trim(),
          'email': email.trim(),
          'role': 'tenant',
          'roomNumber': roomNumber.trim(),
          'bedNumber': bedNumber.trim(),
          'profileCompleted': false, // This triggers the password reset/setup for tenant
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      // 4. Clean up by deleting the secondary app instance
      await secondaryApp.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(e.message ?? "Failed to create tenant account");
    } catch (e) {
      throw Exception("An unexpected error occurred: $e");
    }
  }

  // 📝 Tenant Completes Profile (Changes password on first login)
  Future<void> completeTenantProfile({
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        // Update the password in Firebase Auth
        await user.updatePassword(newPassword.trim());
        
        // Update the flag in Firestore so they can access the dashboard next time
        await _firestore.collection('users').doc(user.uid).update({
          'profileCompleted': true,
        });
      }
    } catch (e) {
      throw Exception("Profile completion failed: ${e.toString()}");
    }
  }

  // 👤 Fetch User Role and Metadata
  Future<DocumentSnapshot> getUserData(String uid) async {
    return await _firestore.collection('users').doc(uid).get();
  }

  // 📧 Forgot Password logic
  Future<void> sendPasswordReset(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } catch (e) {
      throw Exception(e.toString());
    }
  }

  // 🚪 Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
  }
}
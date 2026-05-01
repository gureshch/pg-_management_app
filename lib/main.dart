import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Theme & Core
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';

// Screens
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/complete_profile_screen.dart';
import 'features/tenant/screens/tenant_dashboard.dart';
import 'features/owner/screens/owner_dashboard.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'PG Management App',
      theme: AppTheme.lightTheme,
      // The AuthWrapper determines the landing page dynamically
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final AuthService authService = AuthService();

    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 1. Check if Firebase is still loading the auth state
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. If user is NOT logged in, send to Login Screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 3. If user IS logged in, check their role and profile status in Firestore
        return FutureBuilder<DocumentSnapshot>(
          future: authService.getUserData(snapshot.data!.uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            if (userSnapshot.hasData && userSnapshot.data!.exists) {
              final data = userSnapshot.data!;
              final String role = data.get('role') ?? 'tenant';
              final bool isProfileComplete = data.get('profileCompleted') ?? false;

              // Logic for Tenant: If owner created account but tenant hasn't finished setup
              if (role == 'tenant') {
                return isProfileComplete 
                    ? const TenantDashboard() 
                    : const CompleteProfileScreen();
              }

              // Logic for Owner
              if (role == 'owner') {
                return const OwnerDashboard();
              }
            }

            // Fallback if data is missing
            return const LoginScreen();
          },
        );
      },
    );
  }
}
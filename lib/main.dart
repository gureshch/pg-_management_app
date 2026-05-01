import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// Core Services & Theme
import 'core/theme/app_theme.dart';
import 'core/services/auth_service.dart';

// Auth Screens
import 'features/auth/screens/login_screen.dart';
import 'features/auth/screens/complete_profile_screen.dart';

// Role-Based Dashboards
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
      title: 'PG Management',
      theme: AppTheme.lightTheme,
      // The AuthWrapper handles the initial routing logic
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
        // 1. Loading State
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 2. Not Logged In -> Go to Login Screen
        if (!snapshot.hasData) {
          return const LoginScreen();
        }

        // 3. Logged In -> Determine Role and Completion Status
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
              final bool isComplete = data.get('profileCompleted') ?? false;

              // Routing Logic
              if (role == 'owner') {
                return const OwnerDashboard();
              } else {
                // Tenant logic: Check if they've set their permanent password
                return isComplete 
                    ? const TenantDashboard() 
                    : const CompleteProfileScreen();
              }
            }

            // Fallback for unexpected data states
            return const LoginScreen();
          },
        );
      },
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';
import 'complete_profile_screen.dart';
import '../../tenant/screens/tenant_dashboard.dart';
import '../../owner/screens/owner_dashboard.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final _authService = AuthService();
  bool isLoading = false;

  void handleLogin() async {
    setState(() => isLoading = true);
    try {
      final user = await _authService.login(emailController.text, passwordController.text);
      if (user != null && mounted) {
        final doc = await _authService.getUserData(user.uid);
        final role = doc.get('role');
        final isComplete = doc.get('profileCompleted') ?? false;

        if (role == 'tenant' && !isComplete) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CompleteProfileScreen()));
        } else if (role == 'owner') {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OwnerDashboard()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TenantDashboard()));
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              height: 250, width: double.infinity,
              decoration: const BoxDecoration(
                gradient: LinearGradient(colors: [AppColors.primary, AppColors.secondary]),
                borderRadius: BorderRadius.only(bottomLeft: Radius.circular(80)),
              ),
              child: const Center(child: Text("PG Manager", style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold))),
            ),
            Padding(
              padding: const EdgeInsets.all(30),
              child: Column(
                children: [
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email", prefixIcon: Icon(Icons.email_outlined))),
                  const SizedBox(height: 20),
                  TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password", prefixIcon: Icon(Icons.lock_outline))),
                  const SizedBox(height: 30),
                  isLoading ? const CircularProgressIndicator() : PrimaryButton(text: "Login", onTap: handleLogin),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
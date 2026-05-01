import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/primary_button.dart';
import '../../tenant/screens/tenant_dashboard.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _passController = TextEditingController();
  final _authService = AuthService();
  bool isLoading = false;

  void handleComplete() async {
    setState(() => isLoading = true);
    try {
      await _authService.completeTenantProfile(newPassword: _passController.text);
      if (mounted) Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TenantDashboard()));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Finalize Setup")),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text("Welcome! Please set your permanent password to continue."),
            const SizedBox(height: 20),
            TextField(controller: _passController, obscureText: true, decoration: const InputDecoration(labelText: "New Password")),
            const SizedBox(height: 30),
            isLoading ? const CircularProgressIndicator() : PrimaryButton(text: "Start Using App", onTap: handleComplete),
          ],
        ),
      ),
    );
  }
}
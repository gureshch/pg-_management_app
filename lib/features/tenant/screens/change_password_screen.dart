import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/primary_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passController = TextEditingController();
  final AuthService _authService = AuthService();
  bool isLoading = false;

  void handleUpdate() async {
    if (passController.text.length < 6) return;
    setState(() => isLoading = true);
    try {
      await _authService.updatePassword(passController.text);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Password updated successfully!")),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Change Password")),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            TextField(
              controller: passController,
              obscureText: true,
              decoration: const InputDecoration(labelText: "New Password", border: OutlineInputBorder()),
            ),
            const SizedBox(height: 20),
            isLoading 
              ? const CircularProgressIndicator() 
              : PrimaryButton(text: "Update Password", onTap: handleUpdate),
          ],
        ),
      ),
    );
  }
}
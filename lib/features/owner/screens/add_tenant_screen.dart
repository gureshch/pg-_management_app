import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/widgets/primary_button.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _room = TextEditingController();
  final _bed = TextEditingController();
  final _authService = AuthService();
  bool isLoading = false;

  void _submit() async {
    setState(() => isLoading = true);
    try {
      await _authService.createTenantAccount(
        email: _email.text, tempPassword: _pass.text, 
        name: _name.text, roomNumber: _room.text, bedNumber: _bed.text
      );
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tenant Registered!")));
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Register Tenant")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _name, decoration: const InputDecoration(labelText: "Full Name")),
            TextField(controller: _email, decoration: const InputDecoration(labelText: "Email")),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: "Temp Password")),
            TextField(controller: _room, decoration: const InputDecoration(labelText: "Room No.")),
            TextField(controller: _bed, decoration: const InputDecoration(labelText: "Bed No.")),
            const SizedBox(height: 30),
            isLoading ? const CircularProgressIndicator() : PrimaryButton(text: "Create Account", onTap: _submit),
          ],
        ),
      ),
    );
  }
}
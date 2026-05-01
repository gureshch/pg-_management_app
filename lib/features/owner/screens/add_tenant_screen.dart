import 'package:flutter/material.dart';
import '../../../core/services/auth_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/primary_button.dart';

class AddTenantScreen extends StatefulWidget {
  const AddTenantScreen({super.key});

  @override
  State<AddTenantScreen> createState() => _AddTenantScreenState();
}

class _AddTenantScreenState extends State<AddTenantScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _roomController = TextEditingController();
  final _bedController = TextEditingController();
  final _tempPassController = TextEditingController();
  bool _isLoading = false;

  void _createTenant() async {
    if (_emailController.text.isEmpty || _tempPassController.text.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please provide a valid email and 6-char password")));
      return;
    }

    setState(() => _isLoading = true);
    try {
      await AuthService().createTenantAccount(
        email: _emailController.text.trim(),
        tempPassword: _tempPassController.text.trim(),
        name: _nameController.text.trim(),
        roomNumber: _roomController.text.trim(),
        bedNumber: _bedController.text.trim(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Tenant account created!")));
        Navigator.pop(context);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Tenant Registration")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            TextField(controller: _nameController, decoration: const InputDecoration(labelText: "Tenant Name")),
            const SizedBox(height: 15),
            TextField(controller: _emailController, decoration: const InputDecoration(labelText: "Tenant Email")),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(child: TextField(controller: _roomController, decoration: const InputDecoration(labelText: "Room No"))),
                const SizedBox(width: 15),
                Expanded(child: TextField(controller: _bedController, decoration: const InputDecoration(labelText: "Bed No"))),
              ],
            ),
            const SizedBox(height: 15),
            TextField(controller: _tempPassController, decoration: const InputDecoration(labelText: "Temporary Password")),
            const SizedBox(height: 40),
            _isLoading 
              ? const CircularProgressIndicator() 
              : PrimaryButton(text: "Register Tenant", onTap: _createTenant),
          ],
        ),
      ),
    );
  }
}
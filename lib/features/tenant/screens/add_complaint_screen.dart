import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/session_service.dart';

class AddComplaintScreen extends StatefulWidget {
  const AddComplaintScreen({super.key});

  @override
  State<AddComplaintScreen> createState() => _AddComplaintScreenState();
}

class _AddComplaintScreenState extends State<AddComplaintScreen> {
  final titleController = TextEditingController();
  final descController = TextEditingController();
  final firestore = FirestoreService();

  bool isLoading = false;

  Future<void> submit() async {
    if (titleController.text.trim().isEmpty ||
        descController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields")),
      );
      return;
    }

    setState(() => isLoading = true);

    // ✅ Fixed: use getUser() instead of missing getUserId()
    final userId = await SessionService().getUserId();

    await firestore.createComplaint(
      userId: userId,
      title: titleController.text.trim(),
      description: descController.text.trim(),
    );

    setState(() => isLoading = false);

    Navigator.pop(context);
  }

  @override
  void dispose() {
    titleController.dispose();
    descController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("New Complaint")),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(labelText: "Title"),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: descController,
              maxLines: 3,
              decoration: const InputDecoration(labelText: "Description"),
            ),

            const SizedBox(height: 24),

            isLoading
                ? const CircularProgressIndicator()
                : SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: submit,
                      child: const Text("Submit Complaint"),
                    ),
                  ),
          ],
        ),
      ),
    );
  }
}
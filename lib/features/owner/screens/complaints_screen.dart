import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_chip.dart';

class ComplaintsScreen extends StatelessWidget {
  const ComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("All Complaints")),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('complaints')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final docs = snapshot.data!.docs;

          if (docs.isEmpty) {
            return const Center(child: Text("No complaints yet"));
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (_, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              final docId = docs[i].id;

              return GlassCard(
                child: ListTile(
                  title: Text(data['title'] ?? ""),
                  subtitle: Text(data['description'] ?? ""),
                  trailing: PopupMenuButton<String>(
                    onSelected: (status) {
                      FirebaseFirestore.instance
                          .collection('complaints')
                          .doc(docId)
                          .update({'status': status});
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: "pending", child: Text("Pending")),
                      PopupMenuItem(value: "in progress", child: Text("In Progress")),
                      PopupMenuItem(value: "resolved", child: Text("Resolved")),
                    ],
                    child: StatusChip(status: data['status'] ?? "pending"),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/services/firestore_service.dart';
import '../../../core/services/session_service.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/status_chip.dart';

class TenantComplaintsScreen extends StatelessWidget {
  const TenantComplaintsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final firestore = FirestoreService();

    return Scaffold(
      appBar: AppBar(title: const Text("My Complaints")),
      body: FutureBuilder<String>(
        future: SessionService().getUserId(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final userId = snapshot.data!;

          return StreamBuilder(
            stream: firestore.getUserComplaints(userId),
            builder: (context, AsyncSnapshot snapshot) {
              if (!snapshot.hasData) {
                return const Center(child: CircularProgressIndicator());
              }

              final docs = snapshot.data.docs;

              if (docs.isEmpty) {
                return const Center(child: Text("No complaints yet"));
              }

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: docs.length,
                itemBuilder: (context, index) {
                  final data = docs[index];
                  return GlassCard(
                    child: ListTile(
                      title: Text(data['title']),
                      subtitle: Text(data['description']),
                      trailing: StatusChip(status: data['status']),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
import 'package:flutter/material.dart';
import '../../../core/widgets/stat_card.dart';

class OwnerHome extends StatelessWidget {
  const OwnerHome({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            const Text(
              "Dashboard",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 20),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              physics: const NeverScrollableScrollPhysics(),
              children: const [
                StatCard(title: "Tenants", value: "32", icon: Icons.people),
                StatCard(title: "Occupied", value: "28", icon: Icons.bed),
                StatCard(title: "Vacant", value: "4", icon: Icons.event_seat),
                StatCard(title: "Complaints", value: "3", icon: Icons.report),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
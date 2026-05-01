import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RoomsScreen extends StatefulWidget {
  const RoomsScreen({super.key});

  @override
  State<RoomsScreen> createState() => _RoomsScreenState();
}

class _RoomsScreenState extends State<RoomsScreen> {
  final firestore = FirebaseFirestore.instance;
  List<QueryDocumentSnapshot> rooms = [];
  String search = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadRooms();
  }

  Future<void> loadRooms() async {
    final snapshot = await firestore.collection('rooms').get();
    setState(() {
      rooms = snapshot.docs;
      isLoading = false;
    });
  }

  void showAddRoomDialog() {
    final nameController = TextEditingController();
    final totalBedsController = TextEditingController();

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Add Room"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: "Room Name"),
            ),
            TextField(
              controller: totalBedsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: "Total Beds"),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              await firestore.collection('rooms').add({
                'name': nameController.text.trim(),
                'totalBeds': int.tryParse(totalBedsController.text) ?? 0,
                'occupiedBeds': 0,
              });
              Navigator.pop(context);
              loadRooms();
            },
            child: const Text("Add"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filtered = rooms.where((room) {
      final name = room['name'].toString().toLowerCase();
      return name.contains(search.toLowerCase());
    }).toList();

    return Scaffold(
      appBar: AppBar(title: const Text("Rooms")),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          decoration: InputDecoration(
                            hintText: "Search room...",
                            prefixIcon: const Icon(Icons.search),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onChanged: (val) => setState(() => search = val),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // ✅ Add button now functional
                      GestureDetector(
                        onTap: showAddRoomDialog,
                        child: Container(
                          height: 50,
                          width: 50,
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.add, color: Colors.white),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: filtered.isEmpty
                        ? const Center(child: Text("No rooms found"))
                        : ListView.builder(
                            itemCount: filtered.length,
                            itemBuilder: (_, i) {
                              final room = filtered[i];
                              final total = room['totalBeds'] ?? 0;
                              final occupied = room['occupiedBeds'] ?? 0;
                              final isFull = occupied == total;

                              return Container(
                                margin: const EdgeInsets.only(bottom: 12),
                                padding: const EdgeInsets.all(14),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  color: Colors.grey.shade100,
                                ),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          room['name'],
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          "$occupied/$total Beds Occupied",
                                          style: const TextStyle(fontSize: 12),
                                        ),
                                      ],
                                    ),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: isFull
                                            ? Colors.green.shade100
                                            : Colors.orange.shade100,
                                        borderRadius:
                                            BorderRadius.circular(20),
                                      ),
                                      child: Text(
                                        isFull ? "Full" : "Vacant",
                                        style: TextStyle(
                                          color: isFull
                                              ? Colors.green
                                              : Colors.orange,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
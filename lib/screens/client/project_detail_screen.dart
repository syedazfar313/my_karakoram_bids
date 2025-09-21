import 'package:flutter/material.dart';

class ProjectDetailScreen extends StatelessWidget {
  final Map<String, dynamic> project;
  const ProjectDetailScreen({super.key, required this.project});

  @override
  Widget build(BuildContext context) {
    final bids = project['bids'] ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(project['title']),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: ListView(
          children: [
            Text(project['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 8),
            Text("Budget: ${project['budget']} PKR"),
            Text("Location: ${project['location']}"),
            const Divider(height: 24),

            Text(
              "Bids:",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Colors.blue[800],
              ),
            ),
            const SizedBox(height: 8),

            bids.isEmpty
                ? const Text("No bids yet.")
                : Column(
                    children: bids.map<Widget>((bid) {
                      return Card(
                        margin: const EdgeInsets.symmetric(vertical: 6),
                        color: Colors.grey[100],
                        child: ListTile(
                          title: Text(
                            bid['contractorName'],
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Amount: ${bid['amount']} PKR"),
                              Text("Days: ${bid['days']}"),
                              Text("Comment: ${bid['comment']}"),
                            ],
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.check_circle,
                                  color: Colors.green,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "You hired ${bid['contractorName']}",
                                      ),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.cancel,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "You rejected ${bid['contractorName']}",
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      );
                    }).toList(),
                  ),
          ],
        ),
      ),
    );
  }
}

// lib/screens/contractor/my_bids.dart
import 'package:flutter/material.dart';

class MyBidsPage extends StatelessWidget {
  final List<Map<String, dynamic>> myBids;
  const MyBidsPage({super.key, required this.myBids});

  @override
  Widget build(BuildContext context) {
    return myBids.isEmpty
        ? const Center(
            child: Text("No bids placed yet.", style: TextStyle(fontSize: 16)),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: myBids.length,
            itemBuilder: (context, index) {
              final bid = myBids[index];
              return Card(
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(
                    bid['project'] ?? '',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text("Amount: Rs.${bid['amount']}"),
                      Text("Days: ${bid['days']}"),
                      Text(
                        "Status: ${bid['status'] ?? 'Pending'}",
                        style: TextStyle(
                          color: bid['status'] == 'Approved'
                              ? Colors.green
                              : Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
  }
}

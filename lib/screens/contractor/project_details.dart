import 'package:flutter/material.dart';

class ProjectDetailsScreen extends StatefulWidget {
  final Map<String, dynamic> project;
  final void Function(Map<String, dynamic> bid) onBid;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    required this.onBid,
  });

  @override
  State<ProjectDetailsScreen> createState() => _ProjectDetailsScreenState();
}

class _ProjectDetailsScreenState extends State<ProjectDetailsScreen> {
  final amountCtrl = TextEditingController();
  final daysCtrl = TextEditingController();
  final commentCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final p = widget.project;

    return Scaffold(
      appBar: AppBar(title: Text(p['title'])),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            Text(p['description'], style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "Budget: ${p['budget']}",
              style: const TextStyle(color: Colors.black54),
            ),
            const SizedBox(height: 24),
            TextField(
              controller: amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Bid Amount (PKR)",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: daysCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: "Days to Complete",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: commentCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: "Comment",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (amountCtrl.text.isEmpty || daysCtrl.text.isEmpty) return;
                widget.onBid({
                  'project': p['title'],
                  'amount': amountCtrl.text,
                  'days': daysCtrl.text,
                  'comment': commentCtrl.text,
                  'status': 'Pending',
                });
                Navigator.pop(context);
              },
              child: const Text(
                "Place Bid",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

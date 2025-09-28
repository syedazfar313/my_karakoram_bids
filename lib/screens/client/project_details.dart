import 'package:flutter/material.dart';
//import 'dart:io';

class ProjectDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> project;
  final List<Map<String, dynamic>> bids;

  const ProjectDetailsScreen({
    super.key,
    required this.project,
    this.bids = const [],
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(project['title'] ?? "Project Details"),
        backgroundColor: Colors.blue,
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          // Project Title
          Text(
            project['title'] ?? "Untitled Project",
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          // Description
          Text(
            project['description'] ?? "No description provided.",
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 16),

          // Budget and Duration (if available)
          Row(
            children: [
              Chip(
                label: Text("Budget: ${project['budget'] ?? '-'} PKR"),
                backgroundColor: theme.colorScheme.primaryContainer,
              ),
              const SizedBox(width: 8),
              Chip(
                label: Text("Location: ${project['location'] ?? '-'}"),
                backgroundColor: theme.colorScheme.secondaryContainer,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Plan Image (if uploaded)
          if (project['planImage'] != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.file(
                project['planImage'],
                height: 200,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),
          if (project['planImage'] != null) const SizedBox(height: 24),

          // Bids Section
          Text(
            "Bids Received",
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          if (bids.isEmpty)
            const Text("No bids received yet.")
          else
            ...bids.map(
              (bid) => Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.symmetric(vertical: 6),
                child: ListTile(
                  title: Text("${bid['contractorName']}"),
                  subtitle: Text(
                    "Offer: PKR ${bid['offer']} · Duration: ${bid['duration']} days",
                  ),
                  trailing: FilledButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            "Bid from ${bid['contractorName']} accepted",
                          ),
                        ),
                      );
                    },
                    child: const Text("Accept"),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

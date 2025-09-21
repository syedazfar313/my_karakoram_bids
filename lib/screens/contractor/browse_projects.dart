import 'package:flutter/material.dart';
import 'package:my_karakoram_bids/routes/app_routes.dart';

class BrowseProjectsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> projects;
  final void Function(Map<String, dynamic>) onBid;

  const BrowseProjectsScreen({
    super.key,
    required this.projects,
    required this.onBid,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: projects.length,
        itemBuilder: (context, i) {
          final project = projects[i];
          return Card(
            margin: const EdgeInsets.only(bottom: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              title: Text(
                project['title'],
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(project['description']),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () {
                Navigator.pushNamed(
                  context,
                  AppRoutes.projectDetails,
                  arguments: {'project': project, 'onBid': onBid},
                );
              },
            ),
          );
        },
      ),
    );
  }
}

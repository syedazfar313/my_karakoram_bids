import 'package:flutter/material.dart';
import 'project_detail_screen.dart';

class MyProjectsPage extends StatelessWidget {
  final List<Map<String, dynamic>> projects;

  const MyProjectsPage({super.key, required this.projects});

  static List<Map<String, dynamic>> dummyProjects = [
    {
      "title": "10 Marla House Construction",
      "description":
          "Full house construction including grey structure and finishing.",
      "budget": "2,000,000",
      "location": "Gilgit jutial",
      "planImage": null,
      "bids": [
        {
          "contractorName": "Ahmed Builders",
          "amount": "1,900,000",
          "days": "120",
          "comment": "We will use high-quality material with guaranteed work.",
        },
        {
          "contractorName": "Khan Constructions",
          "amount": "2,050,000",
          "days": "110",
          "comment": "Fast and reliable service with experienced team.",
        },
      ],
    },
    {
      "title": "Boundary Wall Construction",
      "description": "Build a 100ft long and 8ft high boundary wall.",
      "budget": "500,000",
      "location": "Islamabad",
      "planImage": null,
      "bids": [
        {
          "contractorName": "SafeBuild Pvt Ltd",
          "amount": "480,000",
          "days": "20",
          "comment": "We will complete quickly with best quality bricks.",
        },
      ],
    },
  ];

  @override
  Widget build(BuildContext context) {
    final dataToShow = projects.isEmpty ? dummyProjects : projects;

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: dataToShow.length,
      itemBuilder: (context, index) {
        final project = dataToShow[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 3,
          child: ListTile(
            title: Text(
              project['title'],
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(project['description']),
            trailing: const Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProjectDetailScreen(project: project),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

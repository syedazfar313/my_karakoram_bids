import 'package:flutter/material.dart';
import '../../../models/user.dart';
import '../../../widgets/dashboard_shell.dart';
import '../../../widgets/custom_drawer.dart';
import 'post_project.dart';
import 'my_projects_page.dart';
import '../../../screens/common/messages_list_screen.dart';

class ClientHome extends StatefulWidget {
  final UserModel user;

  const ClientHome({super.key, required this.user});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  // Projects list with some initial dummy data
  final List<Map<String, dynamic>> projects = [
    {
      "title": "10 Marla House Construction",
      "description":
          "Full house construction including grey structure and finishing.",
      "budget": "2,000,000",
      "location": "Gilgit jutial",
      "planImage": null,
      "status": "active",
      "createdAt": DateTime.now()
          .subtract(const Duration(days: 2))
          .toIso8601String(),
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
      "status": "completed",
      "createdAt": DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
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

  void _addProject(Map<String, dynamic> project) {
    setState(() {
      // Add timestamp if not present
      if (project['createdAt'] == null) {
        project['createdAt'] = DateTime.now().toIso8601String();
      }

      // Add status if not present
      if (project['status'] == null) {
        project['status'] = 'active';
      }

      // Initialize bids if not present
      if (project['bids'] == null) {
        project['bids'] = <Map<String, dynamic>>[];
      }

      // Add project to beginning of list (newest first)
      projects.insert(0, project);
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Project posted successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        Scaffold(
          drawer: const CustomDrawer(),
          body: MyProjectsPage(projects: projects), // Pass actual projects
        ),
        PostProjectScreen(onProjectPosted: _addProject),
        const MessagesListScreen(userType: "Client"),
      ],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.work_outline),
          label: "Projects",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.add_circle_outline),
          label: "Post",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Chat",
        ),
      ],
      titles: const ["My Projects", "Post Project", "Messages"],
      drawers: const {0: CustomDrawer()},
    );
  }
}

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
  final List<Map<String, dynamic>> projects = [];

  void _addProject(Map<String, dynamic> project) {
    setState(() {
      projects.add(project);
    });
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        Scaffold(
          drawer: const CustomDrawer(), // Updated - no user parameter needed
          body: MyProjectsPage(projects: projects),
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
      drawers: const {0: CustomDrawer()}, // Updated - no user parameter needed
    );
  }
}

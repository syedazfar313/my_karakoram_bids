// lib/screens/client/client_home.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/user.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/projects_provider.dart';
import 'post_project.dart';
import 'my_projects_page.dart';
import '../common/messages_list_screen.dart';

class ClientHome extends StatefulWidget {
  final UserModel user;

  const ClientHome({super.key, required this.user});

  @override
  State<ClientHome> createState() => _ClientHomeState();
}

class _ClientHomeState extends State<ClientHome> {
  void _addProject(Map<String, dynamic> project) {
    project['clientId'] = widget.user.id;

    final projectsProvider = Provider.of<ProjectsProvider>(
      context,
      listen: false,
    );
    projectsProvider.addProject(project);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Project posted successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              project['planImage'] != null
                  ? 'Floor plan included - Contractors can now see your project with naksha'
                  : 'Contractors can now see your project',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
        behavior: SnackBarBehavior.floating,
      ),
    );

    debugPrint(
      'Client ${widget.user.name} posted project: ${project['title']}',
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        // Tab 1: My Projects
        Scaffold(
          drawer: const CustomDrawer(),
          body: Consumer<ProjectsProvider>(
            builder: (context, projectsProvider, child) {
              final clientProjects = projectsProvider.getProjectsByClientId(
                widget.user.id,
              );
              return MyProjectsPage(projects: clientProjects);
            },
          ),
        ),

        // Tab 2: Post Project
        PostProjectScreen(onProjectPosted: _addProject),

        // Tab 3: Messages
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

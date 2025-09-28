import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for ProjectsProvider
import '../../../models/user.dart';
import '../../../widgets/dashboard_shell.dart';
import '../../../widgets/custom_drawer.dart';
import '../../../providers/projects_provider.dart'; // Added import
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
  void _addProject(Map<String, dynamic> project) {
    // Add client ID to project
    project['clientId'] = widget.user.id;

    // Use global provider instead of local state
    final projectsProvider = Provider.of<ProjectsProvider>(
      context,
      listen: false,
    );
    projectsProvider.addProject(project);

    // Show success message with enhanced info
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
        action: SnackBarAction(
          label: 'View',
          textColor: Colors.white,
          onPressed: () {
            // Switch to My Projects tab to see the posted project
            // This would require tab controller access
          },
        ),
      ),
    );

    // Debug info
    debugPrint(
      'Client ${widget.user.name} posted project: ${project['title']}',
    );
    debugPrint('Project has image: ${project['planImage'] != null}');
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        // My Projects Page with Provider Consumer
        Scaffold(
          drawer: const CustomDrawer(),
          body: Consumer<ProjectsProvider>(
            builder: (context, projectsProvider, child) {
              // Get projects for current client
              final clientProjects = projectsProvider.getProjectsByClientId(
                widget.user.id,
              );

              // Debug info
              debugPrint('Client projects count: ${clientProjects.length}');

              return MyProjectsPage(projects: clientProjects);
            },
          ),
        ),

        // Post Project Page
        PostProjectScreen(onProjectPosted: _addProject),

        // Messages Page
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

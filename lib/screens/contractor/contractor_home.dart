import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Added for ProjectsProvider
import '../../models/user.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/custom_drawer.dart';
import '../../providers/projects_provider.dart'; // Added import
import 'browse_projects.dart';
import 'my_bids.dart';
import '../../screens/common/messages_list_screen.dart';

class ContractorHome extends StatefulWidget {
  final UserModel user;

  const ContractorHome({super.key, required this.user});

  @override
  State<ContractorHome> createState() => _ContractorHomeState();
}

class _ContractorHomeState extends State<ContractorHome> {
  final List<Map<String, dynamic>> myBids = [];

  void placeBid(Map<String, dynamic> bid) {
    // Create enhanced bid object
    final enhancedBid = {
      ...bid,
      'id': DateTime.now().millisecondsSinceEpoch.toString(),
      'contractorId': widget.user.id,
      'contractorName': widget.user.name,
      'status': 'pending',
      'createdAt': DateTime.now().toIso8601String(),
    };

    // Add to local bids list
    setState(() {
      myBids.add(enhancedBid);
    });

    // Also add to global projects provider if project ID is available
    if (bid['projectId'] != null) {
      final projectsProvider = Provider.of<ProjectsProvider>(
        context,
        listen: false,
      );
      projectsProvider.addBidToProject(bid['projectId'], enhancedBid);
    }

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bid placed successfully!',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Your bid of PKR ${bid['amount']} has been sent to the client',
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: 'View Bids',
          textColor: Colors.white,
          onPressed: () {
            // Switch to My Bids tab
            // This would require tab controller access
          },
        ),
      ),
    );

    // Debug info
    debugPrint(
      'Contractor ${widget.user.name} placed bid: PKR ${bid['amount']}',
    );
    debugPrint('Project: ${bid['project']}');
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        // Browse Projects Page with Provider Consumer
        Scaffold(
          drawer: const CustomDrawer(),
          body: Consumer<ProjectsProvider>(
            builder: (context, projectsProvider, child) {
              // Get all active projects from global provider
              final allProjects = projectsProvider.allActiveProjects;

              // Debug info
              debugPrint(
                'Available projects for contractor: ${allProjects.length}',
              );
              debugPrint(
                'Projects with images: ${allProjects.where((p) => p['planImage'] != null).length}',
              );

              return BrowseProjectsScreen(
                projects:
                    allProjects, // Now shows all client projects including newly posted ones
                onBid: (bid) {
                  // Find the project and add its ID to the bid
                  final project = allProjects.firstWhere(
                    (p) => p['title'] == bid['project'],
                    orElse: () => <String, dynamic>{},
                  );
                  if (project.isNotEmpty) {
                    bid['projectId'] = project['id'];
                  }
                  placeBid(bid);
                },
              );
            },
          ),
        ),

        // My Bids Page
        MyBidsPage(myBids: myBids),

        // Messages Page
        const MessagesListScreen(userType: "Contractor"),
      ],
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.search), label: "Browse"),
        BottomNavigationBarItem(
          icon: Icon(Icons.folder_copy_outlined),
          label: "My Bids",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Messages",
        ),
      ],
      titles: const ["Browse Projects", "My Bids", "Messages"],
      drawers: const {0: CustomDrawer()},
    );
  }
}

import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/custom_drawer.dart';
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

  // Sample projects for contractors to browse
  final List<Map<String, dynamic>> projects = [
    {
      "id": "1",
      "title": "Build 5 Marla House",
      "description":
          "Looking for a contractor to construct a 5 marla house with modern design. Need complete grey structure and finishing work.",
      "budget": "PKR 1,500,000",
      "location": "Gilgit Jutial",
      "clientId": "client1",
      "createdAt": "2024-01-15",
      "status": "active",
    },
    {
      "id": "2",
      "title": "Build a Shop in Commercial Area",
      "description":
          "Need a professional contractor for building a commercial shop. Ground floor with mezzanine required.",
      "budget": "PKR 800,000",
      "location": "Skardu Bazaar",
      "clientId": "client2",
      "createdAt": "2024-01-14",
      "status": "active",
    },
    {
      "id": "3",
      "title": "Boundary Wall Construction",
      "description":
          "Build a boundary wall around 1 kanal plot. Height should be 8 feet with proper foundation.",
      "budget": "PKR 350,000",
      "location": "Islamabad",
      "clientId": "client3",
      "createdAt": "2024-01-13",
      "status": "active",
    },
    {
      "id": "4",
      "title": "House Renovation Project",
      "description":
          "Complete renovation of old house including electrical, plumbing, and interior work.",
      "budget": "PKR 900,000",
      "location": "Hunza Valley",
      "clientId": "client4",
      "createdAt": "2024-01-12",
      "status": "active",
    },
    {
      "id": "5",
      "title": "Office Building Construction",
      "description":
          "2-story office building construction with parking and modern facilities.",
      "budget": "PKR 4,500,000",
      "location": "Gilgit City",
      "clientId": "client5",
      "createdAt": "2024-01-11",
      "status": "active",
    },
  ];

  void placeBid(Map<String, dynamic> bid) {
    setState(() {
      myBids.add({
        ...bid,
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'contractorId': widget.user.id,
        'contractorName': widget.user.name,
        'status': 'pending',
        'createdAt': DateTime.now().toIso8601String(),
      });
    });

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bid placed successfully!'),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        Scaffold(
          drawer: const CustomDrawer(), // Updated - no user parameter needed
          body: BrowseProjectsScreen(projects: projects, onBid: placeBid),
        ),
        MyBidsPage(myBids: myBids),
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
      drawers: const {0: CustomDrawer()}, // Updated - no user parameter needed
    );
  }
}

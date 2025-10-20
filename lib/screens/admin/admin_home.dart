// lib/screens/admin/admin_home.dart
import 'package:flutter/material.dart';
//import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user.dart';
import '../../../widgets/dashboard_shell.dart';
import '../../../widgets/custom_drawer.dart';
import 'admin_dashboard.dart';
import 'manage_users.dart';
import 'manage_projects.dart';
import 'manage_bids.dart';

class AdminHome extends StatefulWidget {
  final UserModel user;

  const AdminHome({super.key, required this.user});

  @override
  State<AdminHome> createState() => _AdminHomeState();
}

class _AdminHomeState extends State<AdminHome> {
  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        // Dashboard Page
        AdminDashboardPage(adminUser: widget.user),

        // Users Management Page
        ManageUsersPage(adminUser: widget.user),

        // Projects Management Page
        ManageProjectsPage(adminUser: widget.user),

        // Bids Management Page
        ManageBidsPage(adminUser: widget.user),
      ],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.dashboard),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(icon: Icon(Icons.people), label: "Users"),
        BottomNavigationBarItem(icon: Icon(Icons.work), label: "Projects"),
        BottomNavigationBarItem(icon: Icon(Icons.gavel), label: "Bids"),
      ],
      titles: const [
        "Admin Dashboard",
        "Manage Users",
        "Manage Projects",
        "Manage Bids",
      ],
      drawers: const {0: CustomDrawer()},
    );
  }
}

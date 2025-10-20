// lib/screens/supplier/supplier_home.dart
import 'package:flutter/material.dart';
import '../../models/user.dart';
import '../../widgets/dashboard_shell.dart';
import '../../widgets/custom_drawer.dart';
import 'my_materials.dart';
import 'material_orders.dart';
import '../../screens/common/messages_list_screen.dart';

class SupplierHome extends StatefulWidget {
  final UserModel user;

  const SupplierHome({super.key, required this.user});

  @override
  State<SupplierHome> createState() => _SupplierHomeState();
}

class _SupplierHomeState extends State<SupplierHome> {
  @override
  Widget build(BuildContext context) {
    return DashboardShell(
      pages: [
        // My Materials Page
        MyMaterialsPage(supplier: widget.user),

        // Orders Page
        MaterialOrdersPage(supplier: widget.user),

        // Messages Page
        const MessagesListScreen(userType: "Supplier"),
      ],
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.inventory),
          label: "Materials",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: "Orders",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.chat_bubble_outline),
          label: "Messages",
        ),
      ],
      titles: const ["My Materials", "Orders", "Messages"],
      drawers: const {0: CustomDrawer()},
    );
  }
}

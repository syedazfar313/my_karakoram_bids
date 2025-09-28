import 'package:flutter/material.dart';

/// 🔹 Agar kahin common AppBar banana ho
PreferredSizeWidget buildDashboardAppBar(
  BuildContext context,
  String title, {
  bool showRole = false,
  String? role,
}) {
  return AppBar(
    backgroundColor: Theme.of(context).colorScheme.primary,
    centerTitle: true,
    title: Text(
      showRole && role != null && role.isNotEmpty ? "$role – $title" : title,
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 18,
      ),
    ),
  );
}

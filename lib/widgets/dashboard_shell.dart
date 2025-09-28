import 'package:flutter/material.dart';

class DashboardShell extends StatefulWidget {
  final List<Widget> pages;
  final List<BottomNavigationBarItem> items;
  final List<String> titles;
  final Map<int, Widget> drawers; // Drawer per tab index

  const DashboardShell({
    super.key,
    required this.pages,
    required this.items,
    required this.titles,
    required this.drawers,
  });

  @override
  State<DashboardShell> createState() => _DashboardShellState();
}

class _DashboardShellState extends State<DashboardShell> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titles[_selectedIndex]),
        centerTitle: true,
        backgroundColor: theme.colorScheme.primary, // Theme se blue color
        foregroundColor: Colors.white,
      ),
      drawer: widget.drawers[_selectedIndex], // Drawer only for current tab
      body: IndexedStack(index: _selectedIndex, children: widget.pages),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: theme.colorScheme.primary, // Theme se blue color
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        onTap: (index) => setState(() => _selectedIndex = index),
        items: widget.items,
      ),
    );
  }
}

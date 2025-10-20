// lib/screens/admin/manage_users.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user.dart';
import 'dart:io';

class ManageUsersPage extends StatefulWidget {
  final UserModel adminUser;

  const ManageUsersPage({super.key, required this.adminUser});

  @override
  State<ManageUsersPage> createState() => _ManageUsersPageState();
}

class _ManageUsersPageState extends State<ManageUsersPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _searchController.addListener(() {
      setState(() {
        _searchQuery = _searchController.text;
      });
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _toggleUserApproval(String userId, bool currentStatus) async {
    try {
      await FirebaseFirestore.instance.collection('users').doc(userId).update({
        'isApproved': !currentStatus,
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(currentStatus ? 'User suspended' : 'User approved'),
            backgroundColor: currentStatus ? Colors.red : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  Future<void> _deleteUser(String userId, String userName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete $userName?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      // Delete user from Firestore
      await FirebaseFirestore.instance.collection('users').doc(userId).delete();

      // Also delete user's data (projects/bids)
      // Note: Implement cascade delete if needed

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting user: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Search Bar
        Padding(
          padding: const EdgeInsets.all(16),
          child: TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: 'Search users...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () => _searchController.clear(),
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),

        // Tabs
        TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Clients'),
            Tab(text: 'Contractors'),
          ],
        ),

        // Tab Views
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _buildUsersList('client'),
              _buildUsersList('contractor'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUsersList(String role) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: role)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        final users = snapshot.data?.docs ?? [];

        // Filter by search query
        final filteredUsers = users.where((doc) {
          final data = doc.data() as Map<String, dynamic>;
          final name = (data['name'] ?? '').toString().toLowerCase();
          final email = (data['email'] ?? '').toString().toLowerCase();
          final query = _searchQuery.toLowerCase();
          return name.contains(query) || email.contains(query);
        }).toList();

        if (filteredUsers.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.person_off, size: 64, color: Colors.grey[400]),
                const SizedBox(height: 16),
                Text(
                  _searchQuery.isEmpty
                      ? 'No ${role}s found'
                      : 'No results for "$_searchQuery"',
                  style: const TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(12),
          itemCount: filteredUsers.length,
          itemBuilder: (context, index) {
            final userDoc = filteredUsers[index];
            final userData = userDoc.data() as Map<String, dynamic>;

            return _buildUserCard(userDoc.id, userData, role);
          },
        );
      },
    );
  }

  Widget _buildUserCard(
    String userId,
    Map<String, dynamic> userData,
    String role,
  ) {
    final name = userData['name'] ?? 'Unknown User';
    final email = userData['email'] ?? '';
    final phone = userData['phone'] ?? 'No phone';
    final location = userData['location'] ?? 'No location';
    final isApproved = userData['isApproved'] ?? true;
    final imageUrl = userData['imageUrl'] ?? '';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundImage: imageUrl.isNotEmpty
              ? (imageUrl.startsWith('/') || imageUrl.startsWith('file://')
                        ? FileImage(File(imageUrl))
                        : NetworkImage(imageUrl))
                    as ImageProvider
              : null,
          child: imageUrl.isEmpty ? const Icon(Icons.person) : null,
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                name,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isApproved ? Colors.green.shade100 : Colors.red.shade100,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                isApproved ? 'Active' : 'Suspended',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: isApproved
                      ? Colors.green.shade800
                      : Colors.red.shade800,
                ),
              ),
            ),
          ],
        ),
        subtitle: Text(email),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildInfoRow(Icons.phone, 'Phone', phone),
                const SizedBox(height: 8),
                _buildInfoRow(Icons.location_on, 'Location', location),

                if (role == 'contractor' && userData['experience'] != null) ...[
                  const SizedBox(height: 8),
                  _buildInfoRow(
                    Icons.work,
                    'Experience',
                    userData['experience'],
                  ),
                ],

                const Divider(height: 24),

                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () =>
                            _toggleUserApproval(userId, isApproved),
                        icon: Icon(
                          isApproved ? Icons.block : Icons.check_circle,
                          size: 18,
                        ),
                        label: Text(isApproved ? 'Suspend' : 'Approve'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isApproved
                              ? Colors.red
                              : Colors.green,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _deleteUser(userId, name),
                        icon: const Icon(Icons.delete, size: 18),
                        label: const Text('Delete'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.red,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: Colors.grey[600]),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey[700],
          ),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: Colors.black87)),
        ),
      ],
    );
  }
}

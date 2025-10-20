// lib/screens/admin/admin_dashboard.dart
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../models/user.dart';
import '../../../widgets/custom_drawer.dart';

class AdminDashboardPage extends StatefulWidget {
  final UserModel adminUser;

  const AdminDashboardPage({super.key, required this.adminUser});

  @override
  State<AdminDashboardPage> createState() => _AdminDashboardPageState();
}

class _AdminDashboardPageState extends State<AdminDashboardPage> {
  int totalClients = 0;
  int totalContractors = 0;
  int totalProjects = 0;
  int totalBids = 0;
  int activeProjects = 0;
  int pendingBids = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStatistics();
  }

  Future<void> _loadStatistics() async {
    setState(() => isLoading = true);

    try {
      // Get total clients
      final clientsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'client')
          .get();
      totalClients = clientsSnapshot.docs.length;

      // Get total contractors
      final contractorsSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'contractor')
          .get();
      totalContractors = contractorsSnapshot.docs.length;

      // Get total projects
      final projectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .get();
      totalProjects = projectsSnapshot.docs.length;

      // Get active projects
      final activeProjectsSnapshot = await FirebaseFirestore.instance
          .collection('projects')
          .where('status', isEqualTo: 'active')
          .get();
      activeProjects = activeProjectsSnapshot.docs.length;

      // Get total bids
      final bidsSnapshot = await FirebaseFirestore.instance
          .collection('bids')
          .get();
      totalBids = bidsSnapshot.docs.length;

      // Get pending bids
      final pendingBidsSnapshot = await FirebaseFirestore.instance
          .collection('bids')
          .where('status', isEqualTo: 'Pending')
          .get();
      pendingBids = pendingBidsSnapshot.docs.length;

      setState(() => isLoading = false);
    } catch (e) {
      print('Error loading statistics: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      drawer: const CustomDrawer(),
      body: RefreshIndicator(
        onRefresh: _loadStatistics,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Welcome Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                          ],
                        ),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Welcome Admin!',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.adminUser.name,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Platform Overview & Management',
                            style: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Statistics Section
                    const Text(
                      'Platform Statistics',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Users Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Clients',
                            totalClients.toString(),
                            Icons.person,
                            Colors.blue,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Total Contractors',
                            totalContractors.toString(),
                            Icons.engineering,
                            Colors.orange,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Projects Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Projects',
                            totalProjects.toString(),
                            Icons.work,
                            Colors.green,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Active Projects',
                            activeProjects.toString(),
                            Icons.trending_up,
                            Colors.teal,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Bids Stats
                    Row(
                      children: [
                        Expanded(
                          child: _buildStatCard(
                            'Total Bids',
                            totalBids.toString(),
                            Icons.gavel,
                            Colors.purple,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _buildStatCard(
                            'Pending Bids',
                            pendingBids.toString(),
                            Icons.pending,
                            Colors.red,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Quick Actions
                    const Text(
                      'Quick Actions',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    _buildQuickActionCard(
                      'Manage Users',
                      'View and manage all clients and contractors',
                      Icons.people,
                      Colors.blue,
                      () {
                        // Navigate to users tab
                        // This requires passing callback from parent
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildQuickActionCard(
                      'Monitor Projects',
                      'Track all ongoing and completed projects',
                      Icons.work,
                      Colors.green,
                      () {
                        // Navigate to projects tab
                      },
                    ),

                    const SizedBox(height: 12),

                    _buildQuickActionCard(
                      'Review Bids',
                      'Check and monitor all bidding activities',
                      Icons.gavel,
                      Colors.orange,
                      () {
                        // Navigate to bids tab
                      },
                    ),

                    const SizedBox(height: 24),

                    // Platform Health
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.green,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.check_circle,
                              color: Colors.white,
                              size: 32,
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Platform Status',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'All systems operational',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, color: color, size: 32),
              Text(
                value,
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    String description,
    IconData icon,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade400,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

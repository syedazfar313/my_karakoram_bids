import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'project_detail_screen.dart';

class MyProjectsPage extends StatefulWidget {
  final List<Map<String, dynamic>> projects;

  const MyProjectsPage({super.key, required this.projects});

  @override
  State<MyProjectsPage> createState() => _MyProjectsPageState();
}

class _MyProjectsPageState extends State<MyProjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProjects = [];
  List<Map<String, dynamic>> _allProjects = [];
  String _searchQuery = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
    _fetchProjectsWithBids();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // Database se projects aur unke bids fetch karna
  Future<void> _fetchProjectsWithBids() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final currentUser = FirebaseAuth.instance.currentUser;
      if (currentUser == null) {
        print('❌ No user logged in');
        setState(() {
          _isLoading = false;
        });
        return;
      }

      print('👤 Fetching projects for user: ${currentUser.uid}');

      QuerySnapshot projectsSnapshot;

      try {
        projectsSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .where('clientId', isEqualTo: currentUser.uid)
            .orderBy('createdAt', descending: true)
            .get();
      } catch (e) {
        print('Trying without orderBy: $e');
        projectsSnapshot = await FirebaseFirestore.instance
            .collection('projects')
            .where('clientId', isEqualTo: currentUser.uid)
            .get();
      }

      print('📁 Found ${projectsSnapshot.docs.length} projects');

      List<Map<String, dynamic>> fetchedProjects = [];

      for (var projectDoc in projectsSnapshot.docs) {
        Map<String, dynamic> projectData =
            projectDoc.data() as Map<String, dynamic>;

        projectData['id'] = projectDoc.id;

        print('✅ Project: ${projectDoc.id} - ${projectData['title']}');

        if (projectData['createdAt'] is Timestamp) {
          projectData['createdAt'] = (projectData['createdAt'] as Timestamp)
              .toDate()
              .toIso8601String();
        } else if (projectData['createdAt'] == null) {
          projectData['createdAt'] = DateTime.now().toIso8601String();
        }

        print('🔍 Searching bids for projectId: ${projectDoc.id}');

        final bidsSnapshot = await FirebaseFirestore.instance
            .collection('bids')
            .where('projectId', isEqualTo: projectDoc.id)
            .get();

        print(
          '📊 Found ${bidsSnapshot.docs.length} bids for project ${projectDoc.id}',
        );

        List<Map<String, dynamic>> bids = [];
        for (var bidDoc in bidsSnapshot.docs) {
          Map<String, dynamic> bidData = bidDoc.data();
          bidData['id'] = bidDoc.id;

          print(
            '  - Bid from: ${bidData['contractorName']} (${bidData['amount']})',
          );

          if (bidData['createdAt'] is Timestamp) {
            bidData['createdAt'] = (bidData['createdAt'] as Timestamp)
                .toDate()
                .toIso8601String();
          } else if (bidData['timestamp'] is Timestamp) {
            bidData['createdAt'] = (bidData['timestamp'] as Timestamp)
                .toDate()
                .toIso8601String();
          }

          bids.add(bidData);
        }

        projectData['bids'] = bids;
        projectData['bidCount'] = bids.length;
        fetchedProjects.add(projectData);
      }

      fetchedProjects.sort((a, b) {
        try {
          final dateA = DateTime.parse(a['createdAt'] ?? '');
          final dateB = DateTime.parse(b['createdAt'] ?? '');
          return dateB.compareTo(dateA);
        } catch (e) {
          return 0;
        }
      });

      setState(() {
        _allProjects = fetchedProjects;
        _filteredProjects = fetchedProjects;
        _isLoading = false;
      });

      print(
        '✅ Successfully loaded ${fetchedProjects.length} projects with bids',
      );
    } catch (e) {
      print('❌ Error fetching projects: $e');
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading projects: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // DELETE PROJECT FUNCTION
  Future<void> _deleteProject(String projectId, int index) async {
    try {
      // Confirmation dialog
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Delete Project'),
          content: const Text(
            'Are you sure you want to delete this project? This action cannot be undone.',
          ),
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

      if (confirmed != true) return;

      // Show loading
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Deleting project...'),
            duration: Duration(seconds: 1),
          ),
        );
      }

      // Delete from Firestore
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(projectId)
          .delete();

      // Delete all bids related to this project
      final bidsSnapshot = await FirebaseFirestore.instance
          .collection('bids')
          .where('projectId', isEqualTo: projectId)
          .get();

      for (var bidDoc in bidsSnapshot.docs) {
        await bidDoc.reference.delete();
      }

      // Update UI - manual refresh nahi, list se remove karo
      setState(() {
        _allProjects.removeWhere((p) => p['id'] == projectId);
        _filterProjects();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project deleted successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error deleting project: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error deleting project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // EDIT PROJECT FUNCTION
  Future<void> _editProject(Map<String, dynamic> project) async {
    final titleController = TextEditingController(text: project['title']);
    final descController = TextEditingController(text: project['description']);
    final locationController = TextEditingController(text: project['location']);
    final budgetController = TextEditingController(
      text: project['budget']?.toString() ?? '',
    );

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Project'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                decoration: const InputDecoration(
                  labelText: 'Description',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
              const SizedBox(height: 12),
              TextField(
                controller: locationController,
                decoration: const InputDecoration(
                  labelText: 'Location',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: budgetController,
                decoration: const InputDecoration(
                  labelText: 'Budget (PKR)',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (result != true) return;

    try {
      // Update in Firestore
      await FirebaseFirestore.instance
          .collection('projects')
          .doc(project['id'])
          .update({
            'title': titleController.text,
            'description': descController.text,
            'location': locationController.text,
            'budget': budgetController.text.isEmpty
                ? null
                : int.tryParse(budgetController.text),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Local update in list - NO automatic refresh
      setState(() {
        final projectIndex = _allProjects.indexWhere(
          (p) => p['id'] == project['id'],
        );
        if (projectIndex != -1) {
          _allProjects[projectIndex]['title'] = titleController.text;
          _allProjects[projectIndex]['description'] = descController.text;
          _allProjects[projectIndex]['location'] = locationController.text;
          _allProjects[projectIndex]['budget'] = budgetController.text.isEmpty
              ? null
              : int.tryParse(budgetController.text);
          _filterProjects();
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Project updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      print('❌ Error updating project: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error updating project: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProjects();
    });
  }

  void _filterProjects() {
    if (_searchQuery.isEmpty) {
      setState(() {
        _filteredProjects = _allProjects;
      });
    } else {
      final query = _searchQuery.toLowerCase();
      setState(() {
        _filteredProjects = _allProjects.where((project) {
          return (project['title']?.toLowerCase().contains(query) ?? false) ||
              (project['location']?.toLowerCase().contains(query) ?? false) ||
              (project['description']?.toLowerCase().contains(query) ?? false);
        }).toList();
      });
    }
  }

  Future<void> _refreshProjects() async {
    await _fetchProjectsWithBids();
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Projects refreshed successfully'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  Widget _buildEmptyState() {
    if (_searchQuery.isNotEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.search_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              const Text(
                'No Results Found',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black54,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No projects found for "$_searchQuery"',
                style: TextStyle(color: Colors.grey[600], fontSize: 16),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () {
                  _searchController.clear();
                },
                child: const Text('Clear Search'),
              ),
            ],
          ),
        ),
      );
    } else {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.work_outline, size: 64, color: Colors.blue[300]),
              const SizedBox(height: 16),
              const Text(
                'No Projects Yet',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'You haven\'t posted any projects yet.\nStart by posting your first project.',
                style: TextStyle(
                  color: Colors.grey[600],
                  fontSize: 16,
                  height: 1.4,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }
  }

  Widget _buildProjectCard(Map<String, dynamic> project, int index) {
    final theme = Theme.of(context);
    final bidsCount = (project['bids'] as List?)?.length ?? 0;

    // Check if contractor is hired
    final isHired = project['hiredContractorId'] != null;
    final hiredContractorName = project['hiredContractorName'];

    Color statusColor = Colors.green;
    String statusText = project['status'] ?? 'active';
    if (statusText == 'completed') {
      statusColor = Colors.blue;
    } else if (statusText == 'cancelled') {
      statusColor = Colors.red;
    }

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () {
          print('Opening project: ${project['id']}');
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => ProjectDetailScreen(project: project),
            ),
          );
          // NO automatic refresh after closing detail screen
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project['title'] ?? 'Untitled Project',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          statusText.toUpperCase(),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Contractor Hired Badge
                  if (isHired)
                    Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Colors.green[600]!, Colors.green[400]!],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.green.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.check_circle,
                            color: Colors.white,
                            size: 16,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Contractor Hired${hiredContractorName != null ? ': $hiredContractorName' : ''}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),

                  // Description
                  Text(
                    project['description'] ?? 'No description',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Location and Budget
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          project['location'] ?? 'Location not specified',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 13,
                          ),
                        ),
                      ),
                      if (project['budget'] != null &&
                          project['budget'].toString().isNotEmpty)
                        Text(
                          'PKR ${project['budget']}',
                          style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),

                  // Bids count and date
                  Row(
                    children: [
                      Icon(
                        Icons.local_offer,
                        size: 16,
                        color: bidsCount > 0
                            ? Colors.orange[700]
                            : Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$bidsCount bid${bidsCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          color: bidsCount > 0
                              ? Colors.orange[700]
                              : Colors.grey[600],
                          fontSize: 13,
                          fontWeight: bidsCount > 0
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                      ),
                      if (bidsCount > 0 && !isHired) ...[
                        const SizedBox(width: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.orange[100],
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'NEW',
                            style: TextStyle(
                              color: Colors.orange[700],
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                      const Spacer(),
                      Text(
                        _formatDate(project['createdAt']),
                        style: TextStyle(color: Colors.grey[500], fontSize: 12),
                      ),
                    ],
                  ),

                  // Plan Image Indicator
                  if (project['planImage'] != null ||
                      project['planImageUrl'] != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          Icon(Icons.image, size: 14, color: Colors.blue[600]),
                          const SizedBox(width: 4),
                          Text(
                            'Floor plan attached',
                            style: TextStyle(
                              color: Colors.blue[600],
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),

            // EDIT & DELETE BUTTONS
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: () => _editProject(project),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.edit, size: 18, color: Colors.blue[700]),
                            const SizedBox(width: 6),
                            Text(
                              'Edit',
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Container(width: 1, height: 24, color: Colors.grey[300]),
                  Expanded(
                    child: InkWell(
                      onTap: () => _deleteProject(project['id'], index),
                      borderRadius: const BorderRadius.only(
                        bottomRight: Radius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete,
                              size: 18,
                              color: Colors.red[700],
                            ),
                            const SizedBox(width: 6),
                            Text(
                              'Delete',
                              style: TextStyle(
                                color: Colors.red[700],
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'Recently';

    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays == 0) {
        return 'Today';
      } else if (difference.inDays == 1) {
        return 'Yesterday';
      } else if (difference.inDays < 7) {
        return '${difference.inDays} days ago';
      } else {
        return '${date.day}/${date.month}/${date.year}';
      }
    } catch (e) {
      return 'Recently';
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
              hintText: 'Search projects...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                      },
                    )
                  : null,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Colors.grey.shade300),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(25),
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              filled: true,
              fillColor: Colors.grey.shade50,
            ),
          ),
        ),

        // Results count
        if (_searchQuery.isNotEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Text(
                  '${_filteredProjects.length} project${_filteredProjects.length == 1 ? '' : 's'} found',
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),

        // Projects List
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _refreshProjects,
                  child: _filteredProjects.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          padding: const EdgeInsets.only(bottom: 16),
                          itemCount: _filteredProjects.length,
                          itemBuilder: (context, index) {
                            return _buildProjectCard(
                              _filteredProjects[index],
                              index,
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}

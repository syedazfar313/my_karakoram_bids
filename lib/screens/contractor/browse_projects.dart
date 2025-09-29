import 'package:flutter/material.dart';
import 'dart:io';
import 'project_details.dart'; // Import the details screen

class BrowseProjectsScreen extends StatefulWidget {
  final List<Map<String, dynamic>> projects;
  final void Function(Map<String, dynamic>) onBid;

  const BrowseProjectsScreen({
    super.key,
    required this.projects,
    required this.onBid,
  });

  @override
  State<BrowseProjectsScreen> createState() => _BrowseProjectsScreenState();
}

class _BrowseProjectsScreenState extends State<BrowseProjectsScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _filteredProjects = [];
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _filteredProjects = widget.projects;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() {
      _searchQuery = _searchController.text;
      _filterProjects();
    });
  }

  void _filterProjects() {
    if (_searchQuery.isEmpty) {
      _filteredProjects = widget.projects;
    } else {
      final query = _searchQuery.toLowerCase();
      _filteredProjects = widget.projects.where((project) {
        return (project['title']?.toLowerCase().contains(query) ?? false) ||
            (project['description']?.toLowerCase().contains(query) ?? false) ||
            (project['location']?.toLowerCase().contains(query) ?? false);
      }).toList();
    }
  }

  Future<void> _refreshProjects() async {
    await Future.delayed(const Duration(seconds: 1));
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
                onPressed: () => _searchController.clear(),
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
              Icon(Icons.work_outline, size: 64, color: Colors.orange[300]),
              const SizedBox(height: 16),
              const Text(
                'No Projects Available',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Check back later for new opportunities.',
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

  // Navigate to project details screen
  void _openProjectDetails(Map<String, dynamic> project) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ContractorProjectDetailsScreen(
          project: project,
          onBid: widget.onBid,
        ),
      ),
    );
  }

  Widget _buildProjectCard(Map<String, dynamic> project) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: InkWell(
        onTap: () => _openProjectDetails(project), // Added tap handler
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Project Image
            if (project['planImage'] != null) ...[
              Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                    child: Container(
                      height: 220,
                      width: double.infinity,
                      child: Image.file(
                        project['planImage'] as File,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            height: 220,
                            color: Colors.grey[200],
                            child: const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.broken_image,
                                    size: 50,
                                    color: Colors.grey,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Image not available',
                                    style: TextStyle(
                                      color: Colors.grey,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Floor Plan Badge
                  Positioned(
                    top: 12,
                    left: 12,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade600,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.architecture,
                            color: Colors.white,
                            size: 14,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Plan Available',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  // Gradient Overlay
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            Colors.black.withOpacity(0.7),
                          ],
                        ),
                      ),
                    ),
                  ),
                  // "Tap to view" text
                  Positioned(
                    bottom: 8,
                    left: 12,
                    child: Text(
                      'Tap to view details',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        shadows: [
                          Shadow(
                            color: Colors.black.withOpacity(0.5),
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ] else ...[
              ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
                child: Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[100],
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.image_not_supported_outlined,
                        size: 40,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'No floor plan available',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ),
            ],

            // Content Section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title and Budget
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          project['title'] ?? 'Untitled Project',
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      if (project['budget'] != null &&
                          project['budget'].toString().isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.green.shade100,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'PKR ${project['budget']}',
                            style: TextStyle(
                              color: Colors.green.shade700,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Description
                  Text(
                    project['description'] ?? 'No description',
                    style: TextStyle(color: Colors.grey[700], fontSize: 14),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  // Location
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
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey[400],
                      ),
                    ],
                  ),
                  if (project['createdAt'] != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Posted ${_formatDate(project['createdAt'])}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String? dateString) {
    if (dateString == null) return 'recently';
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);
      if (difference.inDays == 0) return 'today';
      if (difference.inDays == 1) return 'yesterday';
      if (difference.inDays < 7) return '${difference.inDays} days ago';
      return '${date.day}/${date.month}/${date.year}';
    } catch (e) {
      return 'recently';
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
                      onPressed: () => _searchController.clear(),
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
          child: RefreshIndicator(
            onRefresh: _refreshProjects,
            child: _filteredProjects.isEmpty
                ? _buildEmptyState()
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredProjects.length,
                    itemBuilder: (context, index) =>
                        _buildProjectCard(_filteredProjects[index]),
                  ),
          ),
        ),
      ],
    );
  }
}

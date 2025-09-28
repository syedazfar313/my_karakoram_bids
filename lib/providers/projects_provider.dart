import 'package:flutter/material.dart';

class ProjectsProvider with ChangeNotifier {
  static final ProjectsProvider _instance = ProjectsProvider._internal();
  factory ProjectsProvider() => _instance;
  ProjectsProvider._internal();

  // Global projects list
  final List<Map<String, dynamic>> _allProjects = [
    // Sample existing projects
    {
      "id": "sample1",
      "title": "Sample Office Building",
      "description": "2-story office building with modern facilities",
      "budget": "PKR 3,000,000",
      "location": "Gilgit City",
      "clientId": "sample_client",
      "createdAt": DateTime.now()
          .subtract(const Duration(days: 5))
          .toIso8601String(),
      "status": "active",
      "planImage": null, // No image for sample
      "bids": [],
    },
  ];

  // Get all active projects (for contractors)
  List<Map<String, dynamic>> get allActiveProjects {
    return _allProjects
        .where((project) => project['status'] == 'active')
        .toList();
  }

  // Get projects by client ID (for clients)
  List<Map<String, dynamic>> getProjectsByClientId(String clientId) {
    return _allProjects
        .where((project) => project['clientId'] == clientId)
        .toList();
  }

  // Add new project (called by client)
  void addProject(Map<String, dynamic> project) {
    // Generate unique ID
    project['id'] = DateTime.now().millisecondsSinceEpoch.toString();

    // Add timestamps
    project['createdAt'] = DateTime.now().toIso8601String();
    project['status'] = 'active';

    // Initialize bids array if not present
    if (project['bids'] == null) {
      project['bids'] = <Map<String, dynamic>>[];
    }

    _allProjects.insert(0, project); // Add to beginning (newest first)
    notifyListeners(); // Notify all listening widgets

    debugPrint('Project added: ${project['title']}');
    debugPrint('Total projects now: ${_allProjects.length}');
  }

  // Update project (for bid management)
  void updateProject(String projectId, Map<String, dynamic> updates) {
    final index = _allProjects.indexWhere((p) => p['id'] == projectId);
    if (index != -1) {
      _allProjects[index] = {..._allProjects[index], ...updates};
      notifyListeners();
    }
  }

  // Add bid to project
  void addBidToProject(String projectId, Map<String, dynamic> bid) {
    final projectIndex = _allProjects.indexWhere((p) => p['id'] == projectId);
    if (projectIndex != -1) {
      final project = _allProjects[projectIndex];
      final bids = List<Map<String, dynamic>>.from(project['bids'] ?? []);

      // Add bid with timestamp
      bid['id'] = DateTime.now().millisecondsSinceEpoch.toString();
      bid['createdAt'] = DateTime.now().toIso8601String();
      bid['status'] = 'pending';

      bids.add(bid);
      project['bids'] = bids;

      notifyListeners();
      debugPrint('Bid added to project: ${project['title']}');
    }
  }

  // Get project by ID
  Map<String, dynamic>? getProjectById(String projectId) {
    try {
      return _allProjects.firstWhere((p) => p['id'] == projectId);
    } catch (e) {
      return null;
    }
  }

  // Search projects
  List<Map<String, dynamic>> searchProjects(String query) {
    if (query.isEmpty) return allActiveProjects;

    final searchQuery = query.toLowerCase();
    return allActiveProjects.where((project) {
      return (project['title']?.toLowerCase().contains(searchQuery) ?? false) ||
          (project['description']?.toLowerCase().contains(searchQuery) ??
              false) ||
          (project['location']?.toLowerCase().contains(searchQuery) ?? false);
    }).toList();
  }

  // Get projects with images (for enhanced display)
  List<Map<String, dynamic>> get projectsWithImages {
    return allActiveProjects
        .where((project) => project['planImage'] != null)
        .toList();
  }

  // Get total projects count
  int get totalProjectsCount => _allProjects.length;

  // Get active projects count
  int get activeProjectsCount => allActiveProjects.length;

  // Clear all projects (for testing)
  void clearAllProjects() {
    _allProjects.clear();
    notifyListeners();
  }
}

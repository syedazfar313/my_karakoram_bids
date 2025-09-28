enum ProjectStatus { active, completed, cancelled }

class ProjectModel {
  final String id;
  final String clientId;
  final String title;
  final String description;
  final String location;
  final double? budget;
  final String? planImageUrl;
  final ProjectStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final List<String> bidIds;

  ProjectModel({
    required this.id,
    required this.clientId,
    required this.title,
    required this.description,
    required this.location,
    this.budget,
    this.planImageUrl,
    this.status = ProjectStatus.active,
    required this.createdAt,
    this.updatedAt,
    List<String>? bidIds,
  }) : bidIds = bidIds ?? [];

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      id: json['id'],
      clientId: json['clientId'],
      title: json['title'],
      description: json['description'],
      location: json['location'],
      budget: json['budget']?.toDouble(),
      planImageUrl: json['planImageUrl'],
      status: ProjectStatus.values.firstWhere(
        (e) => e.toString() == 'ProjectStatus.${json['status']}',
        orElse: () => ProjectStatus.active,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      bidIds: List<String>.from(json['bidIds'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientId': clientId,
      'title': title,
      'description': description,
      'location': location,
      'budget': budget,
      'planImageUrl': planImageUrl,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'bidIds': bidIds,
    };
  }
}

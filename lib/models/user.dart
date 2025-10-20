// lib/models/user.dart
enum UserRole { client, contractor, admin } // ✅ Admin role added

class UserModel {
  String id;
  String name;
  String email;
  UserRole role;
  String phone;
  String imageUrl;
  String experience; // Contractor only
  List<String> completedProjects; // Contractor only
  String location;
  bool isApproved; // ✅ Admin approval status

  UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.role,
    this.phone = '',
    this.imageUrl = '',
    this.experience = '',
    List<String>? completedProjects,
    this.location = '',
    this.isApproved = true, // ✅ Default approved
  }) : completedProjects = completedProjects ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: _parseRole(json['role']),
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      experience: json['experience'] ?? '',
      completedProjects:
          (json['completedProjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] ?? '',
      isApproved: json['isApproved'] ?? true,
    );
  }

  // ✅ Role parsing helper
  static UserRole _parseRole(dynamic role) {
    if (role == 'contractor') return UserRole.contractor;
    if (role == 'admin') return UserRole.admin;
    return UserRole.client;
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.contractor
          ? 'contractor'
          : role == UserRole.admin
          ? 'admin'
          : 'client',
      'phone': phone,
      'imageUrl': imageUrl,
      'experience': experience,
      'completedProjects': completedProjects,
      'location': location,
      'isApproved': isApproved,
    };
  }

  // Method to update fields dynamically
  void update({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    String? experience,
    List<String>? completedProjects,
    String? location,
    bool? isApproved,
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (imageUrl != null) this.imageUrl = imageUrl;
    if (experience != null) this.experience = experience;
    if (completedProjects != null) this.completedProjects = completedProjects;
    if (location != null) this.location = location;
    if (isApproved != null) this.isApproved = isApproved;
  }

  // Helper methods
  bool get isClient => role == UserRole.client;
  bool get isContractor => role == UserRole.contractor;
  bool get isAdmin => role == UserRole.admin;

  String get roleString {
    if (role == UserRole.contractor) return 'Contractor';
    if (role == UserRole.admin) return 'Admin';
    return 'Client';
  }
}

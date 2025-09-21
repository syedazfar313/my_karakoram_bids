enum UserRole { client, contractor }

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
  }) : completedProjects = completedProjects ?? [];

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      role: json['role'] == 'contractor'
          ? UserRole.contractor
          : UserRole.client,
      phone: json['phone'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      experience: json['experience'] ?? '',
      completedProjects:
          (json['completedProjects'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      location: json['location'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'role': role == UserRole.contractor ? 'contractor' : 'client',
      'phone': phone,
      'imageUrl': imageUrl,
      'experience': experience,
      'completedProjects': completedProjects,
      'location': location,
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
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (imageUrl != null) this.imageUrl = imageUrl;
    if (experience != null) this.experience = experience;
    if (completedProjects != null) this.completedProjects = completedProjects;
    if (location != null) this.location = location;
  }
}

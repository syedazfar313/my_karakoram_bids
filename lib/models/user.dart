// lib/models/user.dart
enum UserRole { client, contractor, admin, supplier } // ✅ Supplier added

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
  bool isApproved;

  // ✅ NEW: Supplier-specific fields
  String? companyName; // Supplier ka company name
  List<String>?
  materialsAvailable; // Materials list (pathar, raat, bajari, etc.)
  List<String>? vehiclesAvailable; // Vehicles list (tractor, mazda, etc.)
  String? businessLicense; // Business license number (optional)

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
    this.isApproved = true,
    this.companyName, // ✅ NEW
    this.materialsAvailable, // ✅ NEW
    this.vehiclesAvailable, // ✅ NEW
    this.businessLicense, // ✅ NEW
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
      companyName: json['companyName'], // ✅ NEW
      materialsAvailable: (json['materialsAvailable'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(), // ✅ NEW
      vehiclesAvailable: (json['vehiclesAvailable'] as List<dynamic>?)
          ?.map((e) => e.toString())
          .toList(), // ✅ NEW
      businessLicense: json['businessLicense'], // ✅ NEW
    );
  }

  static UserRole _parseRole(dynamic role) {
    if (role == 'contractor') return UserRole.contractor;
    if (role == 'admin') return UserRole.admin;
    if (role == 'supplier') return UserRole.supplier; // ✅ NEW
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
          : role == UserRole.supplier
          ? 'supplier' // ✅ NEW
          : 'client',
      'phone': phone,
      'imageUrl': imageUrl,
      'experience': experience,
      'completedProjects': completedProjects,
      'location': location,
      'isApproved': isApproved,
      'companyName': companyName, // ✅ NEW
      'materialsAvailable': materialsAvailable ?? [], // ✅ NEW
      'vehiclesAvailable': vehiclesAvailable ?? [], // ✅ NEW
      'businessLicense': businessLicense, // ✅ NEW
    };
  }

  void update({
    String? name,
    String? email,
    String? phone,
    String? imageUrl,
    String? experience,
    List<String>? completedProjects,
    String? location,
    bool? isApproved,
    String? companyName, // ✅ NEW
    List<String>? materialsAvailable, // ✅ NEW
    List<String>? vehiclesAvailable, // ✅ NEW
    String? businessLicense, // ✅ NEW
  }) {
    if (name != null) this.name = name;
    if (email != null) this.email = email;
    if (phone != null) this.phone = phone;
    if (imageUrl != null) this.imageUrl = imageUrl;
    if (experience != null) this.experience = experience;
    if (completedProjects != null) this.completedProjects = completedProjects;
    if (location != null) this.location = location;
    if (isApproved != null) this.isApproved = isApproved;
    if (companyName != null) this.companyName = companyName; // ✅ NEW
    if (materialsAvailable != null)
      this.materialsAvailable = materialsAvailable; // ✅ NEW
    if (vehiclesAvailable != null)
      this.vehiclesAvailable = vehiclesAvailable; // ✅ NEW
    if (businessLicense != null)
      this.businessLicense = businessLicense; // ✅ NEW
  }

  // Helper methods
  bool get isClient => role == UserRole.client;
  bool get isContractor => role == UserRole.contractor;
  bool get isAdmin => role == UserRole.admin;
  bool get isSupplier => role == UserRole.supplier; // ✅ NEW

  String get roleString {
    if (role == UserRole.contractor) return 'Contractor';
    if (role == UserRole.admin) return 'Admin';
    if (role == UserRole.supplier) return 'Supplier'; // ✅ NEW
    return 'Client';
  }
}

import 'package:flutter/material.dart';
import '../models/user.dart';

enum AuthState { loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  UserModel? _user;
  AuthState _state = AuthState.unauthenticated;
  String? _errorMessage;

  // Getters
  UserModel? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  // Mock database (replace with Firebase later)
  final Map<String, Map<String, dynamic>> _usersDb = {};

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  // Simple validation methods
  String? _validateName(String? name) {
    if (name == null || name.trim().isEmpty) {
      return 'Name is required';
    }
    if (name.trim().length < 2) {
      return 'Name must be at least 2 characters';
    }
    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) {
      return 'Email is required';
    }
    if (!email.contains('@') || !email.contains('.')) {
      return 'Enter a valid email address';
    }
    return null;
  }

  String? _validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) {
      return 'Phone number is required';
    }
    if (phone.length < 10) {
      return 'Enter a valid phone number';
    }
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) {
      return 'Password is required';
    }
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }
    return null;
  }

  Future<void> signUp({
    required String name,
    String? email,
    String? phone,
    required String password,
    required UserRole role,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      // Validate inputs
      final nameError = _validateName(name);
      if (nameError != null) throw Exception(nameError);

      final passwordError = _validatePassword(password);
      if (passwordError != null) throw Exception(passwordError);

      if (email != null && email.isNotEmpty) {
        final emailError = _validateEmail(email);
        if (emailError != null) throw Exception(emailError);
      } else if (phone != null && phone.isNotEmpty) {
        final phoneError = _validatePhone(phone);
        if (phoneError != null) throw Exception(phoneError);
      } else {
        throw Exception("Please provide either email or phone number");
      }

      // Simulate network delay
      await Future.delayed(const Duration(seconds: 2));

      final key = email?.isNotEmpty == true ? email! : phone!;

      // Check if user already exists
      if (_usersDb.containsKey(key)) {
        throw Exception(
          "User already exists with this ${email?.isNotEmpty == true ? 'email' : 'phone'}",
        );
      }

      final userId = DateTime.now().millisecondsSinceEpoch.toString();

      _usersDb[key] = {
        "id": userId,
        "name": name,
        "email": email ?? '',
        "phone": phone ?? '',
        "password": password,
        "role": role.toString().split('.').last,
        "imageUrl": '',
        "experience": '',
        "completedProjects": <String>[],
        "location": '',
        "createdAt": DateTime.now().toIso8601String(),
      };

      _user = UserModel(
        id: userId,
        name: name,
        email: email ?? phone ?? '',
        role: role,
        phone: phone ?? '',
        imageUrl: '',
        experience: '',
        completedProjects: [],
        location: '',
      );

      _setState(AuthState.authenticated);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      rethrow;
    }
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      // Basic validation
      if (identifier.trim().isEmpty) {
        throw Exception("Please enter email or phone");
      }
      if (password.isEmpty) {
        throw Exception("Please enter password");
      }

      await Future.delayed(const Duration(seconds: 1));

      // Find user
      Map<String, dynamic>? userData;
      for (var user in _usersDb.values) {
        if (user["email"] == identifier || user["phone"] == identifier) {
          userData = user;
          break;
        }
      }

      if (userData == null) {
        throw Exception(
          "No account found with this ${identifier.contains('@') ? 'email' : 'phone'}",
        );
      }

      if (userData["password"] != password) {
        throw Exception("Incorrect password");
      }

      _user = UserModel(
        id: userData["id"] ?? '',
        name: userData["name"] ?? '',
        email: userData["email"] ?? userData["phone"] ?? '',
        role: userData["role"] == 'contractor'
            ? UserRole.contractor
            : UserRole.client,
        phone: userData["phone"] ?? '',
        imageUrl: userData["imageUrl"] ?? '',
        experience: userData["experience"] ?? '',
        completedProjects: List<String>.from(
          userData["completedProjects"] ?? [],
        ),
        location: userData["location"] ?? '',
      );

      _setState(AuthState.authenticated);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      rethrow;
    }
  }

  Future<void> resetPassword(String identifier) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      if (identifier.trim().isEmpty) {
        throw Exception("Please enter email or phone");
      }

      await Future.delayed(const Duration(seconds: 2));

      bool userExists = false;
      for (var user in _usersDb.values) {
        if (user["email"] == identifier || user["phone"] == identifier) {
          userExists = true;
          break;
        }
      }

      if (!userExists) {
        throw Exception(
          "No account found with this ${identifier.contains('@') ? 'email' : 'phone'}",
        );
      }

      // In real app, send reset email/SMS here
      _setState(AuthState.unauthenticated);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      rethrow;
    }
  }

  // Profile update method - MAIN SOLUTION FOR YOUR ISSUE
  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? experience,
    List<String>? completedProjects,
    String? imageUrl,
  }) {
    if (_user == null) return;

    // Update the user object
    _user!.update(
      name: name,
      email: email,
      phone: phone,
      location: location,
      experience: experience,
      completedProjects: completedProjects,
      imageUrl: imageUrl,
    );

    // Update mock database
    final key = _user!.email;
    if (_usersDb.containsKey(key)) {
      _usersDb[key]!.addAll({
        if (name != null) 'name': name,
        if (email != null) 'email': email,
        if (phone != null) 'phone': phone,
        if (location != null) 'location': location,
        if (experience != null) 'experience': experience,
        if (completedProjects != null) 'completedProjects': completedProjects,
        if (imageUrl != null) 'imageUrl': imageUrl,
      });
    }

    notifyListeners(); // This will update all Consumer widgets
  }

  void signOut() {
    _user = null;
    _errorMessage = null;
    _setState(AuthState.unauthenticated);
  }

  void clearError() {
    _setError(null);
  }
}

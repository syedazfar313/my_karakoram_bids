import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';

enum AuthState { loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  UserModel? _user;
  AuthState _state = AuthState.unauthenticated;
  String? _errorMessage;
  String? _verificationId;
  UserRole? _tempRole;

  // Getters
  UserModel? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _auth.authStateChanges().listen((User? firebaseUser) async {
      if (firebaseUser != null) {
        await _loadUserFromFirestore(firebaseUser);
        _setState(AuthState.authenticated);
      } else {
        _user = null;
        _setState(AuthState.unauthenticated);
      }
    });
  }

  Future<void> _loadUserFromFirestore(User firebaseUser) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(firebaseUser.uid)
          .get();

      if (doc.exists) {
        final data = doc.data()!;
        _user = UserModel(
          id: firebaseUser.uid,
          name: data['name'] ?? firebaseUser.displayName ?? 'User',
          email: data['email'] ?? firebaseUser.email ?? '',
          role: data['role'] == 'contractor'
              ? UserRole.contractor
              : UserRole.client,
          phone: data['phone'] ?? firebaseUser.phoneNumber ?? '',
          imageUrl: data['imageUrl'] ?? firebaseUser.photoURL ?? '',
          experience: data['experience'] ?? '',
          completedProjects: List<String>.from(data['completedProjects'] ?? []),
          location: data['location'] ?? '',
        );
        debugPrint('User loaded: ${_user!.name} as ${_user!.role}');
      } else {
        _createUserFromFirebase(firebaseUser, role: _tempRole);
        await _saveUserToFirestore();
      }
    } catch (e) {
      debugPrint('Error loading user: $e');
      _createUserFromFirebase(firebaseUser, role: _tempRole);
    }
  }

  Future<void> _saveUserToFirestore() async {
    if (_user == null) return;

    try {
      await _firestore.collection('users').doc(_user!.id).set({
        'name': _user!.name,
        'email': _user!.email,
        'role': _user!.role == UserRole.contractor ? 'contractor' : 'client',
        'phone': _user!.phone,
        'imageUrl': _user!.imageUrl,
        'experience': _user!.experience,
        'completedProjects': _user!.completedProjects,
        'location': _user!.location,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      debugPrint('User saved: ${_user!.name} as ${_user!.role}');
    } catch (e) {
      debugPrint('Error saving user: $e');
    }
  }

  void _setState(AuthState state) {
    _state = state;
    notifyListeners();
  }

  void _setError(String? error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _createUserFromFirebase(User firebaseUser, {UserRole? role}) {
    _user = UserModel(
      id: firebaseUser.uid,
      name: firebaseUser.displayName ?? 'User',
      email: firebaseUser.email ?? firebaseUser.phoneNumber ?? '',
      role: role ?? _tempRole ?? UserRole.client,
      phone: firebaseUser.phoneNumber ?? '',
      imageUrl: firebaseUser.photoURL ?? '',
      experience: '',
      completedProjects: [],
      location: '',
    );
    _tempRole = null;
  }

  String? _validateName(String? name) {
    if (name == null || name.trim().isEmpty) return 'Name is required';
    if (name.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
  }

  String? _validateEmail(String? email) {
    if (email == null || email.isEmpty) return 'Email is required';
    if (!email.contains('@') || !email.contains('.'))
      return 'Enter a valid email address';
    return null;
  }

  String? _validatePhone(String? phone) {
    if (phone == null || phone.isEmpty) return 'Phone number is required';
    if (phone.length < 10) return 'Enter a valid phone number';
    return null;
  }

  String? _validatePassword(String? password) {
    if (password == null || password.isEmpty) return 'Password is required';
    if (password.length < 6) return 'Password must be at least 6 characters';
    return null;
  }

  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      final nameError = _validateName(name);
      if (nameError != null) throw Exception(nameError);

      final emailError = _validateEmail(email);
      if (emailError != null) throw Exception(emailError);

      final passwordError = _validatePassword(password);
      if (passwordError != null) throw Exception(passwordError);

      _tempRole = role;

      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await result.user?.updateDisplayName(name);
      await result.user?.sendEmailVerification();

      _createUserFromFirebase(result.user!, role: role);
      _user?.update(name: name);
      if (_user != null) {
        _user!.role = role;
      }

      await _saveUserToFirestore();

      _setState(AuthState.authenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      _tempRole = null;
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null;
      rethrow;
    }
  }

  Future<void> signInWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      final emailError = _validateEmail(email);
      if (emailError != null) throw Exception(emailError);

      final passwordError = _validatePassword(password);
      if (passwordError != null) throw Exception(passwordError);

      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _loadUserFromFirestore(result.user!);
      _setState(AuthState.authenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      rethrow;
    }
  }

  Future<void> sendPhoneVerification({
    required String phoneNumber,
    UserRole? role,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      final phoneError = _validatePhone(phoneNumber);
      if (phoneError != null) throw Exception(phoneError);

      if (role != null) {
        _tempRole = role;
      }

      String formattedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+92$phoneNumber';

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          final UserCredential result = await _auth.signInWithCredential(
            credential,
          );
          _createUserFromFirebase(result.user!, role: _tempRole);
          await _saveUserToFirestore();
          _setState(AuthState.authenticated);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = _getFirebaseErrorMessage(e);
          _setError(errorMessage);
          _setState(AuthState.unauthenticated);
          _tempRole = null;
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setState(AuthState.unauthenticated);
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null;
      rethrow;
    }
  }

  Future<void> verifyPhoneOTP({required String otp, String? name}) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      if (_verificationId == null) {
        throw Exception("Verification ID not found. Please try again.");
      }

      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final UserCredential result = await _auth.signInWithCredential(
        credential,
      );

      if (name != null && name.isNotEmpty) {
        await result.user?.updateDisplayName(name);
      }

      _createUserFromFirebase(result.user!, role: _tempRole);

      if (name != null) {
        _user?.update(name: name);
      }

      await _saveUserToFirestore();

      _setState(AuthState.authenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      _tempRole = null;
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null;
      rethrow;
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      final emailError = _validateEmail(email);
      if (emailError != null) throw Exception(emailError);

      await _auth.sendPasswordResetEmail(email: email);
      _setState(AuthState.unauthenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      rethrow;
    }
  }

  Future<void> signUp({
    required String name,
    String? email,
    String? phone,
    required String password,
    required UserRole role,
  }) async {
    if (email != null && email.isNotEmpty) {
      await signUpWithEmail(
        name: name,
        email: email,
        password: password,
        role: role,
      );
    } else if (phone != null && phone.isNotEmpty) {
      await sendPhoneVerification(phoneNumber: phone, role: role);
    } else {
      throw Exception("Please provide either email or phone number");
    }
  }

  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    if (identifier.contains('@')) {
      await signInWithEmail(email: identifier, password: password);
    } else {
      await sendPhoneVerification(phoneNumber: identifier);
    }
  }

  void updateProfile({
    String? name,
    String? email,
    String? phone,
    String? location,
    String? experience,
    List<String>? completedProjects,
    String? imageUrl,
  }) async {
    if (_user == null) return;

    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
    if (imageUrl != null) {
      await _auth.currentUser?.updatePhotoURL(imageUrl);
    }

    _user!.update(
      name: name,
      email: email,
      phone: phone,
      location: location,
      experience: experience,
      completedProjects: completedProjects,
      imageUrl: imageUrl,
    );

    await _saveUserToFirestore();
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _errorMessage = null;
    _verificationId = null;
    _tempRole = null;
    _setState(AuthState.unauthenticated);
  }

  void clearError() {
    _setError(null);
  }

  String _getFirebaseErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Password is too weak.';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-phone-number':
        return 'Invalid phone number.';
      case 'invalid-verification-code':
        return 'Invalid verification code.';
      case 'session-expired':
        return 'Verification session expired. Please try again.';
      default:
        return e.message ?? 'An error occurred';
    }
  }
}

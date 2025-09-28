import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user.dart';

enum AuthState { loading, authenticated, unauthenticated }

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  UserModel? _user;
  AuthState _state = AuthState.unauthenticated;
  String? _errorMessage;
  String? _verificationId; // For phone auth
  UserRole? _tempRole; // Temporary store role during signup

  // Getters
  UserModel? get user => _user;
  AuthState get state => _state;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;

  // Constructor - Check current user
  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _auth.authStateChanges().listen((User? firebaseUser) {
      if (firebaseUser != null) {
        _createUserFromFirebase(firebaseUser);
        _setState(AuthState.authenticated);
      } else {
        _user = null;
        _setState(AuthState.unauthenticated);
      }
    });
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
      role:
          role ??
          _tempRole ??
          UserRole.client, // Use provided role or temp role
      phone: firebaseUser.phoneNumber ?? '',
      imageUrl: firebaseUser.photoURL ?? '',
      experience: '',
      completedProjects: [],
      location: '',
    );

    // Clear temp role after use
    _tempRole = null;
  }

  // Validation methods (same as before)
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

  // EMAIL/PASSWORD AUTHENTICATION
  Future<void> signUpWithEmail({
    required String name,
    required String email,
    required String password,
    required UserRole role,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      // Validate inputs
      final nameError = _validateName(name);
      if (nameError != null) throw Exception(nameError);

      final emailError = _validateEmail(email);
      if (emailError != null) throw Exception(emailError);

      final passwordError = _validatePassword(password);
      if (passwordError != null) throw Exception(passwordError);

      // Store role temporarily
      _tempRole = role;

      // Create user with Firebase
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Update display name
      await result.user?.updateDisplayName(name);

      // Send email verification
      await result.user?.sendEmailVerification();

      // Create user with correct role
      _createUserFromFirebase(result.user!, role: role);

      // Update user with name and role
      _user?.update(name: name);
      // Manually set role since update method doesn't handle role
      if (_user != null) {
        _user!.role = role;
      }

      _setState(AuthState.authenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      _tempRole = null; // Clear temp role on error
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null; // Clear temp role on error
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

      _createUserFromFirebase(result.user!);
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

  // PHONE AUTHENTICATION
  Future<void> sendPhoneVerification({
    required String phoneNumber,
    UserRole? role,
  }) async {
    try {
      _setState(AuthState.loading);
      _setError(null);

      final phoneError = _validatePhone(phoneNumber);
      if (phoneError != null) throw Exception(phoneError);

      // Store role for phone signup
      if (role != null) {
        _tempRole = role;
      }

      // Format phone number (add country code if not present)
      String formattedPhone = phoneNumber.startsWith('+')
          ? phoneNumber
          : '+92$phoneNumber'; // Pakistan country code

      await _auth.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto verification (on some Android devices)
          final UserCredential result = await _auth.signInWithCredential(
            credential,
          );
          _createUserFromFirebase(result.user!, role: _tempRole);
          _setState(AuthState.authenticated);
        },
        verificationFailed: (FirebaseAuthException e) {
          String errorMessage = _getFirebaseErrorMessage(e);
          _setError(errorMessage);
          _setState(AuthState.unauthenticated);
          _tempRole = null; // Clear temp role on error
        },
        codeSent: (String verificationId, int? resendToken) {
          _verificationId = verificationId;
          _setState(AuthState.unauthenticated); // Wait for OTP input
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          _verificationId = verificationId;
        },
      );
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null; // Clear temp role on error
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

      // Update display name if provided (for new users)
      if (name != null && name.isNotEmpty) {
        await result.user?.updateDisplayName(name);
      }

      // Create user with stored role
      _createUserFromFirebase(result.user!, role: _tempRole);

      if (name != null) {
        _user?.update(name: name);
      }

      _setState(AuthState.authenticated);
    } on FirebaseAuthException catch (e) {
      String errorMessage = _getFirebaseErrorMessage(e);
      _setError(errorMessage);
      _setState(AuthState.unauthenticated);
      _tempRole = null; // Clear temp role on error
      throw Exception(errorMessage);
    } catch (e) {
      _setError(e.toString());
      _setState(AuthState.unauthenticated);
      _tempRole = null; // Clear temp role on error
      rethrow;
    }
  }

  // PASSWORD RESET
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

  // COMBINED SIGN UP METHOD (for backward compatibility)
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
      // For phone signup, send verification with role
      await sendPhoneVerification(phoneNumber: phone, role: role);
      // After this, user needs to call verifyPhoneOTP
    } else {
      throw Exception("Please provide either email or phone number");
    }
  }

  // COMBINED SIGN IN METHOD (for backward compatibility)
  Future<void> signIn({
    required String identifier,
    required String password,
  }) async {
    if (identifier.contains('@')) {
      await signInWithEmail(email: identifier, password: password);
    } else {
      // For phone signin, send OTP first (no role needed for existing users)
      await sendPhoneVerification(phoneNumber: identifier);
      // After this, user needs to call verifyPhoneOTP
    }
  }

  // PROFILE UPDATE
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

    // Update Firebase user profile
    if (name != null) {
      await _auth.currentUser?.updateDisplayName(name);
    }
    if (imageUrl != null) {
      await _auth.currentUser?.updatePhotoURL(imageUrl);
    }

    // Update local user object
    _user!.update(
      name: name,
      email: email,
      phone: phone,
      location: location,
      experience: experience,
      completedProjects: completedProjects,
      imageUrl: imageUrl,
    );

    notifyListeners();
  }

  // SIGN OUT
  Future<void> signOut() async {
    await _auth.signOut();
    _user = null;
    _errorMessage = null;
    _verificationId = null;
    _tempRole = null; // Clear temp role
    _setState(AuthState.unauthenticated);
  }

  void clearError() {
    _setError(null);
  }

  // Helper method to convert Firebase errors to user-friendly messages
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

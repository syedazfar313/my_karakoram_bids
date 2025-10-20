// lib/screens/auth/login_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../routes/app_routes.dart';
import '../../core/utils/validation.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final identifierCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool obscurePass = true;

  @override
  void dispose() {
    identifierCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  // ✅ UPDATED: Admin routing support
  Future<void> _handleLogin() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final identifier = identifierCtrl.text.trim();

      debugPrint('========== LOGIN START ==========');
      debugPrint('Identifier: $identifier');

      await authProvider.signInWithEmail(
        email: identifier,
        password: passCtrl.text,
      );

      if (!mounted) return;

      // Wait for Firestore data to load
      await Future.delayed(const Duration(milliseconds: 1500));

      if (authProvider.isAuthenticated && authProvider.user != null) {
        final user = authProvider.user!;

        debugPrint('========== LOGIN COMPLETE ==========');
        debugPrint('User Name: ${user.name}');
        debugPrint('User Email: ${user.email}');
        debugPrint('User Role: ${user.role}');
        debugPrint('User Role String: ${user.role.toString()}');
        debugPrint('Is Admin: ${user.role == UserRole.admin}'); // ✅ ADDED
        debugPrint('Is Contractor: ${user.role == UserRole.contractor}');
        debugPrint('Is Client: ${user.role == UserRole.client}');

        // ✅ UPDATED: Determine route based on role (ADMIN FIRST!)
        final String route;
        if (user.role == UserRole.admin) {
          route = AppRoutes.adminHome;
          debugPrint('✅ Navigating to: ADMIN HOME');
        } else if (user.role == UserRole.contractor) {
          route = AppRoutes.contractorHome;
          debugPrint('✅ Navigating to: CONTRACTOR HOME');
        } else {
          route = AppRoutes.clientHome;
          debugPrint('✅ Navigating to: CLIENT HOME');
        }

        Navigator.pushReplacementNamed(context, route, arguments: user);
      } else {
        debugPrint('❌ ERROR: User not authenticated or user is null');
        debugPrint('Authenticated: ${authProvider.isAuthenticated}');
        debugPrint('User: ${authProvider.user}');
      }
    } catch (e) {
      debugPrint('❌ Login error: $e');
      // Error already shown by AuthProvider
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email or phone number';
    }

    value = value.trim();

    if (value.contains('@')) {
      return ValidationUtils.validateEmail(value);
    } else {
      return ValidationUtils.validatePhone(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: theme.colorScheme.primary,
          body: SafeArea(
            child: SingleChildScrollView(
              child: SizedBox(
                height: size.height,
                child: Column(
                  children: [
                    // Blue top area
                    Container(
                      height: size.height * 0.35,
                      width: double.infinity,
                      color: theme.colorScheme.primary,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.home_work,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Welcome Back",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to continue to Karakoram Bids",
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),

                    // White curved area
                    Expanded(
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 28,
                          vertical: 32,
                        ),
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                        ),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Error message
                              if (authProvider.errorMessage != null)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 16),
                                  padding: const EdgeInsets.all(12),
                                  decoration: BoxDecoration(
                                    color: Colors.red.shade50,
                                    border: Border.all(
                                      color: Colors.red.shade200,
                                    ),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(
                                        Icons.error_outline,
                                        color: Colors.red.shade700,
                                        size: 20,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          authProvider.errorMessage!,
                                          style: TextStyle(
                                            color: Colors.red.shade700,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                              // Email or Phone Field
                              TextFormField(
                                controller: identifierCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: InputDecoration(
                                  hintText: "Email or Phone",
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: theme.colorScheme.primary,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                validator: _validateIdentifier,
                                onChanged: (value) {
                                  if (authProvider.errorMessage != null) {
                                    authProvider.clearError();
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // Password Field
                              TextFormField(
                                controller: passCtrl,
                                obscureText: obscurePass,
                                textInputAction: TextInputAction.done,
                                decoration: InputDecoration(
                                  hintText: "Password",
                                  prefixIcon: Icon(
                                    Icons.lock_outline,
                                    color: theme.colorScheme.primary,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: theme.colorScheme.primary,
                                    ),
                                    onPressed: () => setState(
                                      () => obscurePass = !obscurePass,
                                    ),
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                                validator: ValidationUtils.validatePassword,
                                onFieldSubmitted: (_) => _handleLogin(),
                                onChanged: (value) {
                                  if (authProvider.errorMessage != null) {
                                    authProvider.clearError();
                                  }
                                },
                              ),

                              // Forgot Password
                              Align(
                                alignment: Alignment.centerRight,
                                child: TextButton(
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : () {
                                          Navigator.pushNamed(
                                            context,
                                            AppRoutes.forget,
                                          );
                                        },
                                  child: Text(
                                    "Forgot password?",
                                    style: TextStyle(
                                      color: theme.colorScheme.primary,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Login Button
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.primary,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: authProvider.isLoading
                                      ? null
                                      : _handleLogin,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Icon(Icons.login),
                                            SizedBox(width: 8),
                                            Text(
                                              "Sign In",
                                              style: TextStyle(
                                                fontWeight: FontWeight.bold,
                                                fontSize: 16,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),

                              const SizedBox(height: 20),

                              // Sign up link
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Don't have an account? "),
                                  GestureDetector(
                                    onTap: authProvider.isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.signup,
                                            );
                                          },
                                    child: Text(
                                      "Sign up",
                                      style: TextStyle(
                                        color: authProvider.isLoading
                                            ? Colors.grey
                                            : theme.colorScheme.primary,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Version info
                              const SizedBox(height: 20),
                              const Center(
                                child: Text(
                                  "Version 1.0.0",
                                  style: TextStyle(
                                    color: Colors.grey,
                                    fontSize: 12,
                                  ),
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
            ),
          ),
        );
      },
    );
  }
}

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

  Future<void> _handleLogin() async {
    // Clear any previous errors
    Provider.of<AuthProvider>(context, listen: false).clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      await authProvider.signIn(
        identifier: identifierCtrl.text.trim(),
        password: passCtrl.text,
      );

      if (mounted && authProvider.isAuthenticated) {
        final user = authProvider.user!;

        // Navigate based on user role
        if (user.role == UserRole.client) {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.clientHome,
            arguments: user,
          );
        } else {
          Navigator.pushReplacementNamed(
            context,
            AppRoutes.contractorHome,
            arguments: user,
          );
        }
      }
    } catch (e) {
      // Error is already handled by AuthProvider and shown via Consumer
      // Additional error handling can be added here if needed
    }
  }

  String? _validateIdentifier(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Please enter email or phone number';
    }

    value = value.trim();

    // Check if it's email or phone
    if (value.contains('@')) {
      return ValidationUtils.validateEmail(value);
    } else {
      // Treat as phone number
      return ValidationUtils.validatePhone(value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        return Scaffold(
          backgroundColor: const Color(0xFF2196F3),
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
                      color: const Color(0xFF2196F3),
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // App logo or icon
                          const Icon(
                            Icons.home_work,
                            size: 80,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            "Welcome Back",
                            style: Theme.of(context).textTheme.headlineMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign in to continue to Karakoram Bids",
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(
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
                              // Show error message if any
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
                                decoration: const InputDecoration(
                                  hintText: "Email or Phone",
                                  prefixIcon: Icon(
                                    Icons.person_outline,
                                    color: Colors.blue,
                                  ),
                                  enabledBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  focusedBorder: UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                validator: _validateIdentifier,
                                onChanged: (value) {
                                  // Clear error when user starts typing
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
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Colors.blue,
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscurePass
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                      color: Colors.blue,
                                    ),
                                    onPressed: () => setState(
                                      () => obscurePass = !obscurePass,
                                    ),
                                  ),
                                  enabledBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(
                                      color: Colors.blueAccent,
                                    ),
                                  ),
                                  focusedBorder: const UnderlineInputBorder(
                                    borderSide: BorderSide(color: Colors.blue),
                                  ),
                                ),
                                validator: ValidationUtils.validatePassword,
                                onFieldSubmitted: (_) => _handleLogin(),
                                onChanged: (value) {
                                  // Clear error when user starts typing
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
                                  child: const Text(
                                    "Forgot password?",
                                    style: TextStyle(color: Colors.blue),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),

                              // Login Button with Loading State
                              SizedBox(
                                height: 48,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF2196F3),
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
                                      : Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: const [
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
                                            : Colors.blue,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),

                              // Version info (optional)
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

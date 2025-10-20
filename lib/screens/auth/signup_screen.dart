import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/user.dart';
import '../../routes/app_routes.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool obscurePass = true;
  UserRole? selectedRole;

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    required Color color,
  }) {
    return InputDecoration(
      hintText: hint,
      prefixIcon: Icon(icon, color: color),
      border: const UnderlineInputBorder(),
      enabledBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: color.withOpacity(0.5), width: 1.5),
      ),
      focusedBorder: UnderlineInputBorder(
        borderSide: BorderSide(color: color, width: 2),
      ),
    );
  }

  Future<void> _handleSignup() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    authProvider.clearError();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    try {
      final input = emailCtrl.text.trim();

      debugPrint('========== SIGNUP START ==========');
      debugPrint('Selected Role: $selectedRole');

      await authProvider.signUpWithEmail(
        name: nameCtrl.text.trim(),
        email: input,
        password: passCtrl.text,
        role: selectedRole!,
      );

      if (!mounted) return;

      // Wait for auth state to update
      await Future.delayed(const Duration(milliseconds: 500));

      if (authProvider.isAuthenticated && authProvider.user != null) {
        final user = authProvider.user!;

        debugPrint('========== SIGNUP COMPLETE ==========');
        debugPrint('User Name: ${user.name}');
        debugPrint('User Role: ${user.role}');

        // Route selection based on role
        final String route;
        if (user.role == UserRole.contractor) {
          route = AppRoutes.contractorHome;
          debugPrint('Navigating to: CONTRACTOR HOME');
        } else if (user.role == UserRole.supplier) {
          route = AppRoutes.supplierHome;
          debugPrint('Navigating to: SUPPLIER HOME');
        } else {
          route = AppRoutes.clientHome;
          debugPrint('Navigating to: CLIENT HOME');
        }

        Navigator.pushReplacementNamed(context, route, arguments: user);
      } else {
        debugPrint('ERROR: User not authenticated after signup');
      }
    } catch (e) {
      debugPrint('Signup error: $e');
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
                    // Blue header
                    Container(
                      height: size.height * 0.30,
                      width: double.infinity,
                      color: theme.colorScheme.primary,
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Create Account",
                            style: theme.textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Sign up to start bidding & hiring",
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
                              // Error message display
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

                              // Name field
                              TextFormField(
                                controller: nameCtrl,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  hint: "Full Name",
                                  icon: Icons.person_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Enter your name"
                                    : null,
                                onChanged: (value) {
                                  if (authProvider.errorMessage != null) {
                                    authProvider.clearError();
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // Email field
                              TextFormField(
                                controller: emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  hint: "Email Address",
                                  icon: Icons.email_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                validator: (v) {
                                  if (v == null || v.trim().isEmpty) {
                                    return "Enter email address";
                                  }
                                  if (!v.contains('@')) {
                                    return "Enter a valid email";
                                  }
                                  return null;
                                },
                                onChanged: (value) {
                                  if (authProvider.errorMessage != null) {
                                    authProvider.clearError();
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // Password
                              TextFormField(
                                controller: passCtrl,
                                obscureText: obscurePass,
                                textInputAction: TextInputAction.next,
                                decoration:
                                    _inputDecoration(
                                      hint: "Password",
                                      icon: Icons.lock_outline,
                                      color: theme.colorScheme.primary,
                                    ).copyWith(
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
                                    ),
                                validator: (v) => v == null || v.length < 6
                                    ? "Password must be at least 6 characters"
                                    : null,
                                onChanged: (value) {
                                  if (authProvider.errorMessage != null) {
                                    authProvider.clearError();
                                  }
                                },
                              ),
                              const SizedBox(height: 24),

                              // Role dropdown - CONTRACTOR, SUPPLIER, CLIENT
                              DropdownButtonFormField<UserRole>(
                                value: selectedRole,
                                decoration: _inputDecoration(
                                  hint: "Register as",
                                  icon: Icons.work_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: UserRole.contractor,
                                    child: Text("Contractor"),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.supplier,
                                    child: Text("Supplier"),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.client,
                                    child: Text("Client"),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() => selectedRole = v);
                                  debugPrint('Role dropdown changed to: $v');
                                },
                                validator: (v) =>
                                    v == null ? "Please select a role" : null,
                              ),
                              const SizedBox(height: 28),

                              // Sign up button
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
                                      : _handleSignup,
                                  child: authProvider.isLoading
                                      ? const SizedBox(
                                          height: 20,
                                          width: 20,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : const Text(
                                          "Sign Up",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),

                              // Back to Login button
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Text("Already have an account? "),
                                  TextButton(
                                    onPressed: authProvider.isLoading
                                        ? null
                                        : () {
                                            Navigator.pushReplacementNamed(
                                              context,
                                              AppRoutes.login,
                                            );
                                          },
                                    child: Text(
                                      "Login",
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

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
  bool loading = false;
  UserRole? selectedRole;

  @override
  void dispose() {
    // Memory leak prevent karne ke liye controllers dispose karna zaroori hai
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

                              // Email or phone
                              TextFormField(
                                controller: emailCtrl,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                                decoration: _inputDecoration(
                                  hint: "Email or Phone",
                                  icon: Icons.email_outlined,
                                  color: theme.colorScheme.primary,
                                ),
                                validator: (v) => v == null || v.trim().isEmpty
                                    ? "Enter email or phone"
                                    : null,
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

                              // Role dropdown
                              DropdownButtonFormField<UserRole>(
                                value: selectedRole,
                                decoration: _inputDecoration(
                                  hint: "Register as",
                                  icon: Icons.work_outline,
                                  color: theme.colorScheme.primary,
                                ),
                                items: const [
                                  DropdownMenuItem(
                                    value: UserRole.client,
                                    child: Text("Client"),
                                  ),
                                  DropdownMenuItem(
                                    value: UserRole.contractor,
                                    child: Text("Contractor"),
                                  ),
                                ],
                                onChanged: (v) =>
                                    setState(() => selectedRole = v),
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
                                      : () async {
                                          if (!_formKey.currentState!
                                              .validate())
                                            return;

                                          try {
                                            final input = emailCtrl.text.trim();
                                            await authProvider.signUp(
                                              name: nameCtrl.text.trim(),
                                              email: input.contains("@")
                                                  ? input
                                                  : null,
                                              phone: input.contains("@")
                                                  ? null
                                                  : input,
                                              password: passCtrl.text,
                                              role: selectedRole!,
                                            );

                                            if (mounted &&
                                                authProvider.isAuthenticated) {
                                              final user = authProvider.user!;
                                              if (user.role ==
                                                  UserRole.client) {
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
                                            // Error already handled by AuthProvider
                                          }
                                        },
                                  child: authProvider.isLoading
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        )
                                      : const Text(
                                          "Sign up",
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

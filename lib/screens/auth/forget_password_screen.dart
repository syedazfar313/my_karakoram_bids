import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class ForgetPasswordScreen extends StatefulWidget {
  const ForgetPasswordScreen({super.key});

  @override
  State<ForgetPasswordScreen> createState() => _ForgetPasswordScreenState();
}

class _ForgetPasswordScreenState extends State<ForgetPasswordScreen> {
  final identifierCtrl = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool loading = false;

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.white, // White background preserved
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Header with theme blue color
              Container(
                width: double.infinity,
                height: size.height * 0.25,
                decoration: BoxDecoration(
                  color: theme.colorScheme.primary, // Theme se blue color
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
                alignment: Alignment.center,
                child: const Icon(
                  Icons.lock_reset_rounded,
                  color: Colors.white,
                  size: 80,
                ),
              ),

              // Form Section on white background
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 32,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        "Forgot Password",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Enter your registered email or phone number and we'll send you instructions to reset your password.",
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.black54,
                        ),
                      ),
                      const SizedBox(height: 32),

                      // Email or Phone field with theme colors
                      TextFormField(
                        controller: identifierCtrl,
                        decoration: InputDecoration(
                          labelText: "Email or Phone",
                          filled: true,
                          fillColor: Colors.white, // White background preserved
                          prefixIcon: Icon(
                            Icons.person_outline,
                            color: theme.colorScheme.primary,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: theme.colorScheme.primary,
                              width: 2,
                            ),
                          ),
                        ),
                        validator: (val) => val == null || val.isEmpty
                            ? "Enter email or phone"
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Send Reset Link button with theme colors
                      ElevatedButton(
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          setState(() => loading = true);
                          await Future.delayed(const Duration(seconds: 2));
                          setState(() => loading = false);

                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  "Password reset instructions sent!",
                                ),
                              ),
                            );
                            Navigator.pushReplacementNamed(
                              context,
                              AppRoutes.login,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          backgroundColor: theme.colorScheme.primary,
                          foregroundColor: Colors.white,
                        ),
                        child: loading
                            ? const SizedBox(
                                height: 22,
                                width: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Text("Send Reset Link"),
                      ),
                      const SizedBox(height: 16),

                      // Back to Login button with theme colors
                      TextButton(
                        onPressed: () => Navigator.pushReplacementNamed(
                          context,
                          AppRoutes.login,
                        ),
                        child: Text(
                          "Back to Login",
                          style: TextStyle(color: theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

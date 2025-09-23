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
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;
    final theme = Theme.of(context);

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
                          // Name field
                          TextFormField(
                            controller: nameCtrl,
                            decoration: _inputDecoration(
                              hint: "Full Name",
                              icon: Icons.person_outline,
                              color: theme.colorScheme.primary,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Enter your name"
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Email or phone
                          TextFormField(
                            controller: emailCtrl,
                            decoration: _inputDecoration(
                              hint: "Email or Phone",
                              icon: Icons.email_outlined,
                              color: theme.colorScheme.primary,
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Enter email or phone"
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Password
                          TextFormField(
                            controller: passCtrl,
                            obscureText: obscurePass,
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
                          ),
                          const SizedBox(height: 24),

                          // Role dropdown
                          DropdownButtonFormField<UserRole>(
                            initialValue: selectedRole,
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
                            onChanged: (v) => setState(() => selectedRole = v),
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
                              onPressed: () async {
                                if (!_formKey.currentState!.validate()) return;
                                setState(() => loading = true);

                                try {
                                  final input = emailCtrl.text.trim();
                                  await auth.signUp(
                                    name: nameCtrl.text.trim(),
                                    email: input.contains("@") ? input : null,
                                    phone: input.contains("@") ? null : input,
                                    password: passCtrl.text,
                                    role: selectedRole!,
                                  );

                                  final user = auth.user!;
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
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text(e.toString())),
                                  );
                                }

                                setState(() => loading = false);
                              },
                              child: loading
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
                                onPressed: () {
                                  Navigator.pushReplacementNamed(
                                    context,
                                    AppRoutes.login,
                                  );
                                },
                                child: Text(
                                  "Login",
                                  style: TextStyle(
                                    color: theme.colorScheme.primary,
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
  }
}

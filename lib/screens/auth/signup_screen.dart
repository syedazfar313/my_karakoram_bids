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
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context, listen: false);
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: const Color(0xFF2196F3),
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
                  color: const Color(0xFF2196F3),
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Create Account",
                        style: Theme.of(context).textTheme.headlineMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Sign up to start bidding & hiring",
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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
                          // Name
                          TextFormField(
                            controller: nameCtrl,
                            decoration: const InputDecoration(
                              hintText: "Full Name",
                              prefixIcon: Icon(
                                Icons.person_outline,
                                color: Colors.blue,
                              ),
                            ),
                            validator: (v) => v == null || v.isEmpty
                                ? "Enter your name"
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Email or phone
                          TextFormField(
                            controller: emailCtrl,
                            decoration: const InputDecoration(
                              hintText: "Email or Phone",
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.blue,
                              ),
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
                                onPressed: () =>
                                    setState(() => obscurePass = !obscurePass),
                              ),
                            ),
                            validator: (v) => v == null || v.length < 6
                                ? "Password must be at least 6 characters"
                                : null,
                          ),
                          const SizedBox(height: 24),

                          // Role dropdown
                          DropdownButtonFormField<UserRole>(
                            value: selectedRole,
                            decoration: const InputDecoration(
                              hintText: "Register as",
                              prefixIcon: Icon(
                                Icons.work_outline,
                                color: Colors.blue,
                              ),
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
                                backgroundColor: const Color(0xFF2196F3),
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
                                  // Navigate to respective home with user object
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

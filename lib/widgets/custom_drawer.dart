import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../screens/common/change_password_screen.dart';
import '../screens/common/profile_screen.dart';
import '../screens/common/privacy_policy_screen.dart';
import '../screens/common/faqs_screen.dart';
import '../screens/common/about_us_screen.dart';
import '../screens/common/contact_us_screen.dart';
import '../providers/auth_provider.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(child: Icon(Icons.person, size: 40));
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      // Local file
      return CircleAvatar(
        backgroundImage: FileImage(File(imageUrl)),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading local image: $exception');
        },
      );
    } else {
      // Network URL
      return CircleAvatar(
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading network image: $exception');
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Drawer(child: Center(child: Text('User not found')));
        }

        return Drawer(
          child: ListView(
            padding: EdgeInsets.zero,
            children: [
              UserAccountsDrawerHeader(
                accountName: Text(user.name),
                accountEmail: Text(user.email),
                currentAccountPicture: _buildProfileImage(user.imageUrl),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary,
                      theme.colorScheme.secondary,
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                onDetailsPressed: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "SETTINGS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(Icons.edit, color: theme.colorScheme.primary),
                title: const Text("Edit Profile"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ProfileScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.lock, color: theme.colorScheme.primary),
                title: const Text("Change Password"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(Icons.language, color: theme.colorScheme.primary),
                title: const Text("Language"),
                onTap: () {
                  Navigator.pop(context);
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text("Select Language"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            title: const Text("English"),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Language set to English"),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            title: const Text("Urdu"),
                            onTap: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text("Language set to Urdu"),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

              const Padding(
                padding: EdgeInsets.all(12.0),
                child: Text(
                  "SUPPORT",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
              ),

              ListTile(
                leading: Icon(
                  Icons.privacy_tip,
                  color: theme.colorScheme.primary,
                ),
                title: const Text("Privacy Policy"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const PrivacyPolicyScreen(),
                    ),
                  );
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.help_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text("FAQs"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const FAQsScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.info_outline,
                  color: theme.colorScheme.primary,
                ),
                title: const Text("About Us"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AboutUsScreen()),
                  );
                },
              ),

              ListTile(
                leading: Icon(
                  Icons.contact_mail,
                  color: theme.colorScheme.primary,
                ),
                title: const Text("Contact Us"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const ContactUsScreen()),
                  );
                },
              ),

              const Divider(),

              ListTile(
                leading: Icon(Icons.logout, color: theme.colorScheme.primary),
                title: const Text("Logout"),
                onTap: () {
                  authProvider.signOut();
                  Navigator.pushReplacementNamed(context, '/login');
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

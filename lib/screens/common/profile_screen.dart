import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import 'edit_profile_screen.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Widget _buildProfileImage(String imageUrl) {
    if (imageUrl.isEmpty) {
      return const CircleAvatar(
        radius: 60,
        child: Icon(Icons.person, size: 60),
      );
    }

    // Check if it's a local file path or network URL
    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      // Local file
      return CircleAvatar(
        radius: 60,
        backgroundImage: FileImage(File(imageUrl)),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading local image: $exception');
        },
        child: null,
      );
    } else {
      // Network URL
      return CircleAvatar(
        radius: 60,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading network image: $exception');
        },
        child: null,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final user = authProvider.user;

        if (user == null) {
          return const Scaffold(body: Center(child: Text('User not found')));
        }

        final isClient = user.role.toString().contains('client');

        return Scaffold(
          appBar: AppBar(
            title: const Text("Profile"),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Colors.white,
          ),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Profile Image with hero animation
              Center(
                child: Hero(
                  tag: 'profile_image',
                  child: GestureDetector(
                    onTap: user.imageUrl.isNotEmpty
                        ? () {
                            // Show full screen image
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => Scaffold(
                                  backgroundColor: Colors.black,
                                  appBar: AppBar(
                                    backgroundColor: Colors.transparent,
                                    iconTheme: const IconThemeData(
                                      color: Colors.white,
                                    ),
                                  ),
                                  body: Center(
                                    child: InteractiveViewer(
                                      child: _buildProfileImage(user.imageUrl),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }
                        : null,
                    child: _buildProfileImage(user.imageUrl),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Name
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // User Role
              Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context,
                    ).colorScheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isClient ? "Client" : "Contractor",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Email
              Card(
                child: ListTile(
                  leading: const Icon(Icons.email),
                  title: const Text("Email"),
                  subtitle: Text(
                    user.email.isEmpty ? 'No email added' : user.email,
                  ),
                ),
              ),

              // Phone
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: const Text("Phone"),
                  subtitle: Text(
                    user.phone.isEmpty ? 'No phone added' : user.phone,
                  ),
                ),
              ),

              // Location
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: const Text("Location"),
                  subtitle: Text(
                    user.location.isEmpty ? 'No location added' : user.location,
                  ),
                ),
              ),

              // Contractor specific fields
              if (!isClient) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: const Text("Experience"),
                    subtitle: Text(
                      user.experience.isEmpty
                          ? "Experience: N/A"
                          : user.experience,
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: const Text("Completed Projects"),
                    subtitle: Text(
                      user.completedProjects.isEmpty
                          ? "Completed Projects: N/A"
                          : user.completedProjects.join(', '),
                    ),
                  ),
                ),
              ],

              const SizedBox(height: 30),

              // Edit Profile Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.edit),
                  label: const Text("Edit Profile"),
                  onPressed: () async {
                    final result = await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => EditProfileScreen(
                          userType: isClient ? "Client" : "Contractor",
                          currentName: user.name,
                          currentEmail: user.email,
                          currentPhone: user.phone,
                          currentLocation: user.location,
                          currentExperience: user.experience,
                          currentCompletedProjects: user.completedProjects.join(
                            ', ',
                          ),
                          currentImage: user.imageUrl,
                        ),
                      ),
                    );

                    // Force refresh if needed
                    if (result == true) {
                      // Profile was updated, Consumer will automatically rebuild
                    }
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'edit_profile_screen.dart';
import '../../providers/auth_provider.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

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
          appBar: AppBar(title: const Text("Profile")),
          body: ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 60,
                  backgroundImage: user.imageUrl.isNotEmpty
                      ? NetworkImage(user.imageUrl)
                      : null,
                  child: user.imageUrl.isEmpty
                      ? const Icon(Icons.person, size: 60)
                      : null,
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Text(
                  user.name,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Phone
              Card(
                child: ListTile(
                  leading: const Icon(Icons.phone),
                  title: Text(
                    user.phone.isEmpty ? 'No phone added' : user.phone,
                  ),
                ),
              ),

              // Location
              Card(
                child: ListTile(
                  leading: const Icon(Icons.location_on),
                  title: Text(
                    user.location.isEmpty ? 'No location added' : user.location,
                  ),
                ),
              ),

              // Contractor specific fields
              if (!isClient) ...[
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.school),
                    title: Text(
                      user.experience.isEmpty
                          ? "Experience: N/A"
                          : "Experience: ${user.experience}",
                    ),
                  ),
                ),
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.check_circle_outline),
                    title: Text(
                      user.completedProjects.isEmpty
                          ? "Completed Projects: N/A"
                          : "Completed Projects: ${user.completedProjects.join(', ')}",
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
                    await Navigator.push(
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
                    // No need to handle result here because Consumer will auto-update
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

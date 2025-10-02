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
        radius: 50,
        child: Icon(Icons.person, size: 50),
      );
    }

    if (imageUrl.startsWith('/') || imageUrl.startsWith('file://')) {
      return CircleAvatar(
        radius: 50,
        backgroundImage: FileImage(File(imageUrl)),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading local image: $exception');
        },
      );
    } else {
      return CircleAvatar(
        radius: 50,
        backgroundImage: NetworkImage(imageUrl),
        onBackgroundImageError: (exception, stackTrace) {
          debugPrint('Error loading network image: $exception');
        },
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
        final theme = Theme.of(context);

        return Scaffold(
          backgroundColor: Colors.grey.shade50,
          body: CustomScrollView(
            slivers: [
              // App Bar with gradient
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                backgroundColor: theme.colorScheme.primary,
                iconTheme: const IconThemeData(color: Colors.white),
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          theme.colorScheme.secondary,
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 40),
                        GestureDetector(
                          onTap: user.imageUrl.isNotEmpty
                              ? () =>
                                    _showFullScreenImage(context, user.imageUrl)
                              : null,
                          child: _buildProfileImage(user.imageUrl),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          user.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isClient ? 'Client' : 'Contractor',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

              // Content
              SliverToBoxAdapter(
                child: Column(
                  children: [
                    const SizedBox(height: 16),

                    // Contact Information Card
                    _buildSectionCard(
                      context,
                      'Contact Information',
                      Icons.contact_phone,
                      Colors.blue,
                      [
                        _buildInfoRow(
                          Icons.email,
                          'Email',
                          user.email.isEmpty ? 'No email added' : user.email,
                          Colors.blue,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.phone,
                          'Phone',
                          user.phone.isEmpty ? 'No phone added' : user.phone,
                          Colors.green,
                        ),
                        const Divider(height: 24),
                        _buildInfoRow(
                          Icons.location_on,
                          'Location',
                          user.location.isEmpty
                              ? 'No location added'
                              : user.location,
                          Colors.red,
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Contractor specific information
                    if (!isClient) ...[
                      _buildSectionCard(
                        context,
                        'Professional Details',
                        Icons.work,
                        Colors.purple,
                        [
                          _buildInfoRow(
                            Icons.school,
                            'Experience',
                            user.experience.isEmpty
                                ? 'No experience added'
                                : user.experience,
                            Colors.purple,
                          ),
                          if (user.completedProjects.isNotEmpty) ...[
                            const Divider(height: 24),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Icon(
                                      Icons.check_circle,
                                      color: Colors.teal.shade600,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Completed Projects',
                                      style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade600,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Wrap(
                                  spacing: 8,
                                  runSpacing: 8,
                                  children: user.completedProjects.map((
                                    project,
                                  ) {
                                    return Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 12,
                                        vertical: 6,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.teal.shade50,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Colors.teal.shade200,
                                        ),
                                      ),
                                      child: Text(
                                        project,
                                        style: TextStyle(
                                          color: Colors.teal.shade700,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                    );
                                  }).toList(),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Account Settings Card
                    _buildSectionCard(
                      context,
                      'Account Settings',
                      Icons.settings,
                      Colors.orange,
                      [
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.blue.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.edit,
                              color: Colors.blue.shade700,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Edit Profile',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Update your profile information',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.grey,
                          ),
                          onTap: () =>
                              _navigateToEditProfile(context, user, isClient),
                        ),
                        const Divider(height: 24),
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.green.shade50,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.verified_user,
                              color: Colors.green.shade700,
                              size: 20,
                            ),
                          ),
                          title: const Text(
                            'Account Status',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: const Text(
                            'Verified Account',
                            style: TextStyle(fontSize: 12),
                          ),
                          trailing: Icon(
                            Icons.check_circle,
                            color: Colors.green.shade600,
                            size: 20,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ],
          ),

          // Edit Profile Button at bottom
          bottomNavigationBar: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              child: ElevatedButton.icon(
                onPressed: () =>
                    _navigateToEditProfile(context, user, isClient),
                icon: const Icon(Icons.edit, size: 20),
                label: const Text('Edit Profile'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: theme.colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSectionCard(
    BuildContext context,
    String title,
    IconData icon,
    Color color,
    List<Widget> children,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: color, size: 20),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _navigateToEditProfile(
    BuildContext context,
    dynamic user,
    bool isClient,
  ) async {
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
          currentCompletedProjects: user.completedProjects.join(', '),
          currentImage: user.imageUrl,
        ),
      ),
    );

    if (result == true) {
      // Profile was updated
    }
  }

  void _showFullScreenImage(BuildContext context, String imageUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Scaffold(
          backgroundColor: Colors.black,
          appBar: AppBar(
            backgroundColor: Colors.transparent,
            iconTheme: const IconThemeData(color: Colors.white),
            title: const Text(
              'Profile Picture',
              style: TextStyle(color: Colors.white),
            ),
          ),
          body: Center(
            child: InteractiveViewer(
              panEnabled: true,
              boundaryMargin: const EdgeInsets.all(20),
              minScale: 0.5,
              maxScale: 4.0,
              child: imageUrl.startsWith('/') || imageUrl.startsWith('file://')
                  ? Image.file(File(imageUrl), fit: BoxFit.contain)
                  : Image.network(imageUrl, fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }
}

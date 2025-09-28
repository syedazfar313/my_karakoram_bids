import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../providers/auth_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final String userType;
  final String currentName;
  final String currentEmail;
  final String currentPhone;
  final String currentLocation;
  final String? currentExperience;
  final String? currentCompletedProjects;
  final String? currentImage;

  const EditProfileScreen({
    super.key,
    required this.userType,
    required this.currentName,
    required this.currentEmail,
    required this.currentPhone,
    required this.currentLocation,
    this.currentExperience,
    this.currentCompletedProjects,
    this.currentImage,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController nameCtrl;
  late TextEditingController emailCtrl;
  late TextEditingController phoneCtrl;
  late TextEditingController locationCtrl;
  late TextEditingController experienceCtrl;
  late TextEditingController completedProjectsCtrl;
  File? _pickedImage;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    nameCtrl = TextEditingController(text: widget.currentName);
    emailCtrl = TextEditingController(text: widget.currentEmail);
    phoneCtrl = TextEditingController(text: widget.currentPhone);
    locationCtrl = TextEditingController(text: widget.currentLocation);
    experienceCtrl = TextEditingController(
      text: widget.currentExperience ?? '',
    );
    completedProjectsCtrl = TextEditingController(
      text: widget.currentCompletedProjects ?? '',
    );
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );

    if (pickedFile != null) {
      setState(() {
        _pickedImage = File(pickedFile.path);
      });
    }
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      // Convert completedProjects string to list if contractor
      List<String>? completedProjectsList;
      if (widget.userType.toLowerCase() != "client" &&
          completedProjectsCtrl.text.isNotEmpty) {
        completedProjectsList = completedProjectsCtrl.text
            .split(',')
            .map((e) => e.trim())
            .where((e) => e.isNotEmpty)
            .toList();
      }

      // Update profile in AuthProvider
      authProvider.updateProfile(
        name: nameCtrl.text.trim(),
        email: emailCtrl.text.trim(),
        phone: phoneCtrl.text.trim(),
        location: locationCtrl.text.trim(),
        experience: experienceCtrl.text.trim(),
        completedProjects: completedProjectsList,
        imageUrl: _pickedImage?.path ?? widget.currentImage,
      );

      setState(() => _isLoading = false);

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Profile updated successfully"),
            backgroundColor: Colors.green,
          ),
        );

        // Go back to profile screen
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() => _isLoading = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Failed to update profile: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isClient = widget.userType.toLowerCase() == "client";

    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Profile"),
        actions: [
          if (_isLoading)
            const Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Profile Image
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 50,
                      backgroundImage: _pickedImage != null
                          ? FileImage(_pickedImage!)
                          : (widget.currentImage != null &&
                                        widget.currentImage!.isNotEmpty
                                    ? NetworkImage(widget.currentImage!)
                                    : null)
                                as ImageProvider?,
                      child:
                          (_pickedImage == null &&
                              (widget.currentImage == null ||
                                  widget.currentImage!.isEmpty))
                          ? const Icon(Icons.person, size: 60)
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: InkWell(
                        onTap: _pickImage,
                        child: const CircleAvatar(
                          radius: 18,
                          backgroundColor: Colors.blue,
                          child: Icon(
                            Icons.edit,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: nameCtrl,
                decoration: const InputDecoration(
                  labelText: "Name",
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Enter name" : null,
              ),
              const SizedBox(height: 15),

              // Email Field
              TextFormField(
                controller: emailCtrl,
                decoration: const InputDecoration(
                  labelText: "Email",
                  prefixIcon: Icon(Icons.email),
                  border: OutlineInputBorder(),
                ),
                validator: (val) => val == null || !val.contains("@")
                    ? "Enter valid email"
                    : null,
              ),
              const SizedBox(height: 15),

              // Phone Field
              TextFormField(
                controller: phoneCtrl,
                decoration: const InputDecoration(
                  labelText: "Phone",
                  prefixIcon: Icon(Icons.phone),
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.phone,
                validator: (val) =>
                    val == null || val.length < 10 ? "Enter valid phone" : null,
              ),
              const SizedBox(height: 15),

              // Location Field
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: "Location",
                  prefixIcon: Icon(Icons.location_on),
                  border: OutlineInputBorder(),
                ),
                validator: (val) =>
                    val == null || val.trim().isEmpty ? "Enter location" : null,
              ),
              const SizedBox(height: 15),

              // Contractor specific fields
              if (!isClient) ...[
                TextFormField(
                  controller: experienceCtrl,
                  decoration: const InputDecoration(
                    labelText: "Experience",
                    prefixIcon: Icon(Icons.school),
                    border: OutlineInputBorder(),
                    hintText: "e.g. 5 years in construction",
                  ),
                ),
                const SizedBox(height: 15),
                TextFormField(
                  controller: completedProjectsCtrl,
                  decoration: const InputDecoration(
                    labelText: "Completed Projects",
                    prefixIcon: Icon(Icons.check_circle_outline),
                    border: OutlineInputBorder(),
                    hintText: "e.g. House Construction, Shop Building",
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 15),
              ],

              const SizedBox(height: 20),

              // Save Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : const Text("Save Changes"),
                  onPressed: _isLoading ? null : _saveProfile,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameCtrl.dispose();
    emailCtrl.dispose();
    phoneCtrl.dispose();
    locationCtrl.dispose();
    experienceCtrl.dispose();
    completedProjectsCtrl.dispose();
    super.dispose();
  }
}

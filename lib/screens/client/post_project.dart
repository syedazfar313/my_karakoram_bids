// lib/screens/client/post_project.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_storage/firebase_storage.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';

class PostProjectScreen extends StatefulWidget {
  final void Function(Map<String, dynamic> project) onProjectPosted;
  const PostProjectScreen({super.key, required this.onProjectPosted});

  @override
  State<PostProjectScreen> createState() => _PostProjectScreenState();
}

class _PostProjectScreenState extends State<PostProjectScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController titleCtrl = TextEditingController();
  final TextEditingController budgetCtrl = TextEditingController();
  final TextEditingController locationCtrl = TextEditingController();
  final TextEditingController descCtrl = TextEditingController();

  File? _planImage;
  bool _submitting = false;

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  // final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
      maxWidth: 1024,
      maxHeight: 1024,
    );
    if (picked != null) {
      setState(() {
        _planImage = File(picked.path);
      });
    }
  }

  // Future<String?> _uploadImageToStorage(File imageFile, String projectId) async {
  //   try {
  //     // Create unique filename
  //     final fileName = 'floor_plan_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     final storageRef = _storage.ref().child('projects/$projectId/$fileName');

  //     // Upload file
  //     final uploadTask = await storageRef.putFile(imageFile);

  //     // Get download URL
  //     final downloadUrl = await uploadTask.ref.getDownloadURL();
  //     return downloadUrl;
  //   } catch (e) {
  //     debugPrint('Error uploading image: $e');
  //     return null;
  //   }
  // }

  Future<void> _submitProject() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    try {
      // Get current user
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final currentUser = authProvider.user;

      if (currentUser == null) {
        throw Exception('User not logged in');
      }

      // Create new document reference to get ID
      final projectRef = _firestore.collection('projects').doc();
      final projectId = projectRef.id;

      // Upload image if exists
      // String? imageUrl;
      // if (_planImage != null) {
      //   imageUrl = await _uploadImageToStorage(_planImage!, projectId);
      // }

      // Prepare project data
      final projectData = {
        'id': projectId,
        'clientId': currentUser.id,
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'budget': budgetCtrl.text.trim().isEmpty
            ? null
            : double.tryParse(budgetCtrl.text.trim()),
        // 'planImageUrl': imageUrl ?? '',
        'status': 'active',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'bidCount': 0,
      };

      // Save to Firestore
      await projectRef.set(projectData);

      // Create local project object for provider
      final localProject = {
        'id': projectId,
        'clientId': currentUser.id,
        'title': titleCtrl.text.trim(),
        'description': descCtrl.text.trim(),
        'location': locationCtrl.text.trim(),
        'budget': budgetCtrl.text.trim(),
        'planImage': _planImage,
        // 'planImageUrl': imageUrl ?? '',
        'status': 'active',
        'createdAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
        'bids': [],
        'bidCount': 0,
      };

      // Callback to parent
      widget.onProjectPosted(localProject);

      // Clear form
      _formKey.currentState!.reset();
      titleCtrl.clear();
      budgetCtrl.clear();
      locationCtrl.clear();
      descCtrl.clear();

      setState(() {
        _planImage = null;
        _submitting = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Project posted successfully!',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                // Text(
                //   imageUrl != null
                //       ? 'Floor plan uploaded - Contractors can now see your project'
                //       : 'Project is now visible to contractors',
                //   style: const TextStyle(fontSize: 12),
                // ),
              ],
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      setState(() => _submitting = false);

      debugPrint('Error posting project: $e');

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to post project: ${e.toString()}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    }
  }

  @override
  void dispose() {
    titleCtrl.dispose();
    budgetCtrl.dispose();
    locationCtrl.dispose();
    descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                "Post Your Project",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),

              // Title
              TextFormField(
                controller: titleCtrl,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: "Project Title",
                  hintText: "e.g., 2-Story House Construction",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.title),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Please enter project title";
                  }
                  if (v.trim().length < 5) {
                    return "Title must be at least 5 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Budget (optional)
              TextFormField(
                controller: budgetCtrl,
                enabled: !_submitting,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Budget (PKR) - Optional",
                  hintText: "e.g., 3000000",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.attach_money),
                  helperText: "Leave empty if not decided",
                ),
                validator: (v) {
                  if (v != null && v.trim().isNotEmpty) {
                    final budget = double.tryParse(v.trim());
                    if (budget == null) {
                      return "Please enter a valid number";
                    }
                    if (budget < 1000) {
                      return "Budget seems too low";
                    }
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Location
              TextFormField(
                controller: locationCtrl,
                enabled: !_submitting,
                decoration: const InputDecoration(
                  labelText: "Location",
                  hintText: "e.g., Gilgit City, Jutial Road",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on),
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Please enter location";
                  }
                  if (v.trim().length < 3) {
                    return "Location must be at least 3 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: descCtrl,
                enabled: !_submitting,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Project Description",
                  hintText:
                      "Provide detailed information about your project...",
                  border: OutlineInputBorder(),
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().isEmpty) {
                    return "Please enter description";
                  }
                  if (v.trim().length < 20) {
                    return "Description must be at least 20 characters";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Plan image upload
              GestureDetector(
                onTap: _submitting ? null : _pickImage,
                child: Container(
                  height: 200,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _submitting ? Colors.grey : Colors.blueAccent,
                      width: 2,
                    ),
                  ),
                  child: _planImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.upload_file,
                              size: 48,
                              color: _submitting ? Colors.grey : Colors.blue,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              "Upload Floor Plan / Naksha",
                              style: TextStyle(
                                color: _submitting ? Colors.grey : Colors.blue,
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Optional - Tap to select image",
                              style: TextStyle(
                                color: Colors.grey.shade600,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        )
                      : Stack(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image.file(
                                _planImage!,
                                fit: BoxFit.cover,
                                width: double.infinity,
                                height: 200,
                              ),
                            ),
                            if (!_submitting)
                              Positioned(
                                top: 8,
                                right: 8,
                                child: CircleAvatar(
                                  backgroundColor: Colors.red,
                                  child: IconButton(
                                    icon: const Icon(
                                      Icons.close,
                                      color: Colors.white,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      setState(() => _planImage = null);
                                    },
                                  ),
                                ),
                              ),
                          ],
                        ),
                ),
              ),

              if (_planImage != null) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.green.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.green.shade200),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.check_circle,
                        color: Colors.green.shade700,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Floor plan selected - This will help contractors understand your project better',
                          style: TextStyle(
                            color: Colors.green.shade700,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Submit button
              SizedBox(
                height: 52,
                child: ElevatedButton(
                  onPressed: _submitting ? null : _submitProject,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _submitting
                      ? Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _planImage != null
                                  ? "Uploading image..."
                                  : "Posting project...",
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(Icons.send, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Post Project",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                ),
              ),

              const SizedBox(height: 12),

              Text(
                'Your project will be visible to all contractors immediately after posting',
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 12,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

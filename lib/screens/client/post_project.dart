// lib/screens/client/post_project.dart
import 'dart:io';
import 'package:flutter/material.dart';
//import '../../core/widgets/custom_button.dart';
import 'package:image_picker/image_picker.dart';

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

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked != null) {
      setState(() {
        _planImage = File(picked.path);
      });
    }
  }

  void _submitProject() {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _submitting = true);

    final project = <String, dynamic>{
      "title": titleCtrl.text.trim(),
      // budget optional: null if empty
      "budget": budgetCtrl.text.trim().isEmpty ? null : budgetCtrl.text.trim(),
      "location": locationCtrl.text.trim(),
      "description": descCtrl.text.trim(),
      "planImage": _planImage, // File? (use Image.file when showing)
      "bids": <Map<String, dynamic>>[], // ready to receive bids
      "createdAt": DateTime.now().toIso8601String(),
    };

    // Callback to parent (ClientHome) to add to list
    widget.onProjectPosted(project);

    // Clear fields after submit (no Navigator.pop — important when embedded in tabs)
    _formKey.currentState!.reset();
    titleCtrl.clear();
    budgetCtrl.clear();
    locationCtrl.clear();
    descCtrl.clear();
    setState(() {
      _planImage = null;
      _submitting = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Project posted successfully")),
    );
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
                decoration: const InputDecoration(
                  labelText: "Project Title",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Please enter project title"
                    : null,
              ),
              const SizedBox(height: 12),

              // Budget (optional)
              TextFormField(
                controller: budgetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: "Budget (PKR) — Optional",
                  hintText: "Leave empty if not decided",
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),

              // Location
              TextFormField(
                controller: locationCtrl,
                decoration: const InputDecoration(
                  labelText: "Location",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Please enter location"
                    : null,
              ),
              const SizedBox(height: 12),

              // Description
              TextFormField(
                controller: descCtrl,
                minLines: 4,
                maxLines: 8,
                decoration: const InputDecoration(
                  labelText: "Project Description",
                  border: OutlineInputBorder(),
                ),
                validator: (v) => v == null || v.trim().isEmpty
                    ? "Please enter description"
                    : null,
              ),
              const SizedBox(height: 16),

              // Plan image upload
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 160,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blueAccent),
                  ),
                  child: _planImage == null
                      ? Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.upload_file,
                              size: 40,
                              color: Colors.blue,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Upload Floor Plan / Naksha",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ],
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _planImage!,
                            fit: BoxFit.cover,
                            width: double.infinity,
                          ),
                        ),
                ),
              ),
              const SizedBox(height: 20),

              // Submit button (uses your CustomButton if available)
              _submitting
                  ? const Center(child: CircularProgressIndicator())
                  : SizedBox(
                      height: 48,
                      child: ElevatedButton(
                        onPressed: _submitProject,
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text("Submit Project"),
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}

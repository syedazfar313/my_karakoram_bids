import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const List<String> allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];

  // Pick image with validation
  static Future<File?> pickImage({
    ImageSource source = ImageSource.gallery,
    bool showDialog = true,
  }) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (pickedFile != null) {
        final file = File(pickedFile.path);

        // Validate file size
        final fileSize = await file.length();
        if (fileSize > maxFileSizeInBytes) {
          throw Exception('Image size should be less than 5MB');
        }

        // Validate file extension
        final extension = path.extension(pickedFile.path).toLowerCase();
        if (!allowedExtensions.contains(extension)) {
          throw Exception('Please select a valid image file (JPG, PNG, WEBP)');
        }

        return file;
      }
      return null;
    } catch (e) {
      if (e.toString().contains('Image size') ||
          e.toString().contains('valid image')) {
        rethrow; // Our custom validation errors
      }
      throw Exception('Failed to pick image: ${e.toString()}');
    }
  }

  // Show image source selection dialog
  static Future<File?> showImageSourceDialog(BuildContext context) async {
    File? selectedImage;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Select Image Source',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        selectedImage = await pickImage(
                          source: ImageSource.camera,
                        );
                      } catch (e) {
                        _showErrorSnackBar(context, e.toString());
                      }
                    },
                  ),
                  _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      try {
                        selectedImage = await pickImage(
                          source: ImageSource.gallery,
                        );
                      } catch (e) {
                        _showErrorSnackBar(context, e.toString());
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );

    return selectedImage;
  }

  static Widget _buildSourceOption({
    required BuildContext context,
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 40, color: Theme.of(context).primaryColor),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  static void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Get file info
  static Future<Map<String, dynamic>> getFileInfo(File file) async {
    final fileSize = await file.length();
    final fileName = path.basename(file.path);
    final fileExtension = path.extension(file.path);

    return {
      'size': fileSize,
      'sizeInMB': (fileSize / (1024 * 1024)).toStringAsFixed(2),
      'name': fileName,
      'extension': fileExtension,
      'path': file.path,
    };
  }

  // Validate image file
  static String? validateImageFile(File? file) {
    if (file == null) return null;

    final extension = path.extension(file.path).toLowerCase();
    if (!allowedExtensions.contains(extension)) {
      return 'Invalid file format. Please select JPG, PNG, or WEBP';
    }

    return null;
  }
}

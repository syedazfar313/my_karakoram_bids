import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;

class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Configuration
  static const int maxFileSizeInBytes = 5 * 1024 * 1024; // 5MB
  static const int maxFileSizeForProfileInBytes =
      2 * 1024 * 1024; // 2MB for profiles
  static const List<String> allowedExtensions = [
    '.jpg',
    '.jpeg',
    '.png',
    '.webp',
  ];
  static const int maxImageWidth = 1920;
  static const int maxImageHeight = 1080;

  // Pick image with comprehensive validation
  static Future<ImagePickResult> pickImage({
    ImageSource source = ImageSource.gallery,
    ImagePickType type = ImagePickType.general,
    int? customMaxSize,
  }) async {
    try {
      final maxSize =
          customMaxSize ??
          (type == ImagePickType.profile
              ? maxFileSizeForProfileInBytes
              : maxFileSizeInBytes);

      final XFile? pickedFile = await _picker.pickImage(
        source: source,
        maxWidth: maxImageWidth.toDouble(),
        maxHeight: maxImageHeight.toDouble(),
        imageQuality: type == ImagePickType.profile ? 85 : 80,
      );

      if (pickedFile == null) {
        return ImagePickResult.cancelled();
      }

      final file = File(pickedFile.path);

      // Validate file
      final validationResult = await validateImageFile(file, maxSize: maxSize);
      if (!validationResult.isValid) {
        return ImagePickResult.error(validationResult.error!);
      }

      return ImagePickResult.success(file);
    } catch (e) {
      return ImagePickResult.error('Failed to pick image: ${e.toString()}');
    }
  }

  // Image validation
  static Future<ValidationResult> validateImageFile(
    File file, {
    int? maxSize,
  }) async {
    try {
      // Check if file exists
      if (!await file.exists()) {
        return ValidationResult.invalid('File does not exist');
      }

      // Check file extension
      final extension = path.extension(file.path).toLowerCase();
      if (!allowedExtensions.contains(extension)) {
        return ValidationResult.invalid(
          'Invalid file format. Please select JPG, PNG, or WEBP files only.',
        );
      }

      // Check file size
      final fileSize = await file.length();
      final sizeLimit = maxSize ?? maxFileSizeInBytes;

      if (fileSize > sizeLimit) {
        final sizeMB = (sizeLimit / (1024 * 1024)).toStringAsFixed(1);
        return ValidationResult.invalid(
          'Image size should be less than ${sizeMB}MB. Current size: ${_formatFileSize(fileSize)}',
        );
      }

      // Additional check for very small files (likely corrupted)
      if (fileSize < 1024) {
        // Less than 1KB
        return ValidationResult.invalid(
          'Image file appears to be corrupted or too small',
        );
      }

      return ValidationResult.valid();
    } catch (e) {
      return ValidationResult.invalid(
        'Error validating image: ${e.toString()}',
      );
    }
  }

  // Show image source selection with options
  static Future<ImagePickResult> showImageSourceDialog(
    BuildContext context, {
    ImagePickType type = ImagePickType.general,
    String? title,
  }) async {
    ImagePickResult? result;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title ?? 'Select Image Source',
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Maximum size: ${_formatFileSize(type == ImagePickType.profile ? maxFileSizeForProfileInBytes : maxFileSizeInBytes)}',
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
              const SizedBox(height: 24),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildSourceOption(
                    context: context,
                    icon: Icons.camera_alt,
                    label: 'Camera',
                    onTap: () async {
                      Navigator.pop(context);
                      result = await pickImage(
                        source: ImageSource.camera,
                        type: type,
                      );
                    },
                  ),
                  _buildSourceOption(
                    context: context,
                    icon: Icons.photo_library,
                    label: 'Gallery',
                    onTap: () async {
                      Navigator.pop(context);
                      result = await pickImage(
                        source: ImageSource.gallery,
                        type: type,
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );

    if (result != null && result!.hasError) {
      _showErrorSnackBar(context, result!.error!);
    }

    return result ?? ImagePickResult.cancelled();
  }

  // Helper methods
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
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, size: 48, color: Theme.of(context).primaryColor),
            const SizedBox(height: 12),
            Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            ),
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
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  // Get detailed file information
  static Future<ImageFileInfo> getImageInfo(File file) async {
    try {
      final fileSize = await file.length();
      final fileName = path.basename(file.path);
      final fileExtension = path.extension(file.path);
      final lastModified = await file.lastModified();

      return ImageFileInfo(
        file: file,
        size: fileSize,
        sizeFormatted: _formatFileSize(fileSize),
        name: fileName,
        extension: fileExtension,
        path: file.path,
        lastModified: lastModified,
        isValid: (await validateImageFile(file)).isValid,
      );
    } catch (e) {
      throw Exception('Failed to get image info: $e');
    }
  }

  // Format file size in human readable format
  static String _formatFileSize(int bytes) {
    if (bytes < 1024) {
      return '${bytes}B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)}KB';
    } else {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)}MB';
    }
  }

  // Compress image if needed
  static Future<File?> compressImage(File file, {int quality = 80}) async {
    try {
      final compressedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: quality,
      );
      return compressedFile != null ? File(compressedFile.path) : null;
    } catch (e) {
      return null;
    }
  }
}

// Enums and Classes
enum ImagePickType { profile, project, general }

class ImagePickResult {
  final File? file;
  final String? error;
  final bool cancelled;

  ImagePickResult._({this.file, this.error, this.cancelled = false});

  factory ImagePickResult.success(File file) => ImagePickResult._(file: file);
  factory ImagePickResult.error(String error) =>
      ImagePickResult._(error: error);
  factory ImagePickResult.cancelled() => ImagePickResult._(cancelled: true);

  bool get isSuccess => file != null;
  bool get hasError => error != null;
  bool get isCancelled => cancelled;
}

class ValidationResult {
  final bool isValid;
  final String? error;

  ValidationResult._(this.isValid, this.error);

  factory ValidationResult.valid() => ValidationResult._(true, null);
  factory ValidationResult.invalid(String error) =>
      ValidationResult._(false, error);
}

class ImageFileInfo {
  final File file;
  final int size;
  final String sizeFormatted;
  final String name;
  final String extension;
  final String path;
  final DateTime lastModified;
  final bool isValid;

  ImageFileInfo({
    required this.file,
    required this.size,
    required this.sizeFormatted,
    required this.name,
    required this.extension,
    required this.path,
    required this.lastModified,
    required this.isValid,
  });
}

import 'package:flutter/material.dart';

class LoadingOverlay {
  static OverlayEntry? _overlay;

  static void show(BuildContext context, {String? message}) {
    if (_overlay != null) return; // Already showing

    _overlay = OverlayEntry(
      builder: (context) => Material(
        color: Colors.black54,
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            margin: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                if (message != null) ...[
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_overlay!);
  }

  static void hide() {
    _overlay?.remove();
    _overlay = null;
  }
}

// Safe Operation Wrapper
class SafeOperation {
  static Future<T?> execute<T>(
    Future<T> Function() operation, {
    required BuildContext context,
    String? loadingMessage,
    String? successMessage,
    bool showLoading = false,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      if (showLoading) {
        LoadingOverlay.show(context, message: loadingMessage);
      }

      final result = await operation();

      if (showLoading) {
        LoadingOverlay.hide();
      }

      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      onSuccess?.call();
      return result;
    } catch (error) {
      if (showLoading) {
        LoadingOverlay.hide();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      onError?.call();
      return null;
    }
  }

  // For void operations
  static Future<bool> executeVoid(
    Future<void> Function() operation, {
    required BuildContext context,
    String? loadingMessage,
    String? successMessage,
    bool showLoading = false,
    VoidCallback? onSuccess,
    VoidCallback? onError,
  }) async {
    try {
      if (showLoading) {
        LoadingOverlay.show(context, message: loadingMessage);
      }

      await operation();

      if (showLoading) {
        LoadingOverlay.hide();
      }

      if (successMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }

      onSuccess?.call();
      return true;
    } catch (error) {
      if (showLoading) {
        LoadingOverlay.hide();
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 3),
        ),
      );

      onError?.call();
      return false;
    }
  }
}

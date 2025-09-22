import 'package:flutter/material.dart';
import 'dart:io';
import 'dart:async';

// Custom Exception Classes
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  AppException(this.message, {this.code, this.details});

  @override
  String toString() => message;
}

class NetworkException extends AppException {
  NetworkException([String? message])
    : super(
        message ??
            'No internet connection. Please check your network settings.',
      );
}

class AuthException extends AppException {
  AuthException(super.message);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class ServerException extends AppException {
  ServerException([String? message])
    : super(message ?? 'Server error. Please try again later.');
}

class FileException extends AppException {
  FileException(super.message);
}

class PermissionException extends AppException {
  PermissionException(super.message);
}

// Error Handler Utility
class ErrorHandler {
  static String getDisplayMessage(dynamic error) {
    if (error is AppException) {
      return error.message;
    }

    if (error is SocketException) {
      return 'No internet connection. Please check your network.';
    }

    if (error is FileSystemException) {
      return 'File operation failed. Please try again.';
    }

    if (error is FormatException) {
      return 'Invalid data format received.';
    }

    if (error is TimeoutException) {
      return 'Request timed out. Please try again.';
    }

    // Generic error
    String errorMessage = error.toString();

    // Clean up common error patterns
    if (errorMessage.contains('Exception:')) {
      errorMessage = errorMessage.replaceAll('Exception:', '').trim();
    }

    if (errorMessage.isEmpty || errorMessage == 'null') {
      return 'Something went wrong. Please try again.';
    }

    return errorMessage;
  }

  static void showError(
    BuildContext context,
    dynamic error, {
    VoidCallback? onRetry,
  }) {
    final message = getDisplayMessage(error);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 4),
        action: onRetry != null
            ? SnackBarAction(
                label: 'Retry',
                textColor: Colors.white,
                onPressed: onRetry,
              )
            : null,
      ),
    );
  }

  static void showSuccess(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showWarning(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  static void showInfo(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.blue,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // Show error dialog for critical errors
  static void showErrorDialog(
    BuildContext context,
    String title,
    dynamic error,
  ) {
    final message = getDisplayMessage(error);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(message),
        icon: const Icon(Icons.error, color: Colors.red, size: 48),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

// Loading Overlay Widget
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

// Try-Catch Wrapper for Async Operations
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
        ErrorHandler.showSuccess(context, successMessage);
      }

      onSuccess?.call();
      return result;
    } catch (error) {
      if (showLoading) {
        LoadingOverlay.hide();
      }

      ErrorHandler.showError(context, error);
      onError?.call();
      return null;
    }
  }

  // For operations that don't return values
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
        ErrorHandler.showSuccess(context, successMessage);
      }

      onSuccess?.call();
      return true;
    } catch (error) {
      if (showLoading) {
        LoadingOverlay.hide();
      }

      ErrorHandler.showError(context, error);
      onError?.call();
      return false;
    }
  }
}

// Network connectivity checker (mock implementation)
class ConnectivityService {
  static Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    }
  }

  static Future<void> checkConnectivityAndThrow() async {
    final isConnected = await ConnectivityService.isConnected();
    if (!isConnected) {
      throw NetworkException();
    }
  }
}

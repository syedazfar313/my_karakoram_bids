import 'dart:async';
import 'package:flutter/foundation.dart';

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();

  ConnectivityService._();

  final StreamController<bool> _connectionStreamController =
      StreamController<bool>.broadcast();
  Stream<bool> get connectionStream => _connectionStreamController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _timer;

  void initialize() {
    // Simple connectivity check every 5 seconds
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      checkConnection();
    });

    // Initial check
    checkConnection();
  }

  Future<void> checkConnection() async {
    try {
      // Simple mock connectivity check
      // In real app, you would check actual internet connectivity
      _updateConnectionStatus(true);
    } catch (e) {
      _updateConnectionStatus(false);
    }
  }

  void _updateConnectionStatus(bool connected) {
    if (_isConnected != connected) {
      _isConnected = connected;
      _connectionStreamController.add(_isConnected);
      if (kDebugMode) {
        print('Connection status: ${connected ? 'Connected' : 'Disconnected'}');
      }
    }
  }

  // Method to manually set connection status (for testing)
  void setConnectionStatus(bool connected) {
    _updateConnectionStatus(connected);
  }

  void dispose() {
    _timer?.cancel();
    _connectionStreamController.close();
  }
}

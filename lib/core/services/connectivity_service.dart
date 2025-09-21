import 'dart:async';
import 'dart:io';

class ConnectivityService {
  static ConnectivityService? _instance;
  static ConnectivityService get instance =>
      _instance ??= ConnectivityService._();
  ConnectivityService._();

  final StreamController<bool> _connectionController =
      StreamController.broadcast();
  Stream<bool> get connectionStream => _connectionController.stream;

  bool _isConnected = true;
  bool get isConnected => _isConnected;

  Timer? _periodicCheck;

  void initialize() {
    // Start periodic connectivity check
    _periodicCheck = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _checkConnectivity(),
    );

    // Initial check
    _checkConnectivity();
  }

  Future<void> _checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      final connected = result.isNotEmpty && result[0].rawAddress.isNotEmpty;

      if (connected != _isConnected) {
        _isConnected = connected;
        _connectionController.add(_isConnected);
      }
    } on SocketException catch (_) {
      if (_isConnected) {
        _isConnected = false;
        _connectionController.add(_isConnected);
      }
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup(
        'google.com',
      ).timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    }
  }

  void dispose() {
    _periodicCheck?.cancel();
    _connectionController.close();
  }
}

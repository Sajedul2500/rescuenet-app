import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';

/// Service to monitor network connectivity for auto-sync
class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  // Stream controller for connectivity changes
  final StreamController<bool> _connectivityController =
      StreamController<bool>.broadcast();

  bool _isConnected = false;

  /// Stream of connectivity status (true = connected, false = disconnected)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current connectivity status
  bool get isConnected => _isConnected;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    _isConnected = await checkConnectivity();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        _updateConnectivityStatus(results);
      },
    );
  }

  /// Check current connectivity status
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _hasActiveConnection(results);
    } catch (e) {
      print('Error checking connectivity: $e');
      return false;
    }
  }

  /// Update connectivity status based on results
  void _updateConnectivityStatus(List<ConnectivityResult> results) {
    final wasConnected = _isConnected;
    _isConnected = _hasActiveConnection(results);

    // Notify listeners only if status changed
    if (wasConnected != _isConnected) {
      _connectivityController.add(_isConnected);
      print(
          'Connectivity changed: ${_isConnected ? "CONNECTED" : "DISCONNECTED"}');
    }
  }

  /// Check if there's an active internet connection
  bool _hasActiveConnection(List<ConnectivityResult> results) {
    // Check if any result indicates connectivity
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet);
  }

  /// Wait for internet connection (useful for sync operations)
  /// Returns true when connected, or false after timeout
  Future<bool> waitForConnection(
      {Duration timeout = const Duration(seconds: 30)}) async {
    if (_isConnected) return true;

    try {
      await _connectivityController.stream
          .firstWhere((isConnected) => isConnected)
          .timeout(timeout);
      return true;
    } catch (e) {
      return false;
    }
  }

  /// Dispose resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController.close();
  }
}

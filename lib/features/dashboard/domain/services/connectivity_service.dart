import 'dart:async';
import 'dart:io';

/// Service to monitor network connectivity status.
/// Provides offline/online state for the dashboard header.
class ConnectivityService {
  Timer? _timer;

  bool _isOffline = false;
  final _connectivityController = StreamController<bool>.broadcast();

  /// Stream of connectivity changes (true = offline, false = online)
  Stream<bool> get connectivityStream => _connectivityController.stream;

  /// Current offline status
  bool get isOffline => _isOffline;

  /// Initialize connectivity monitoring
  Future<void> initialize() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Poll connectivity every 10 seconds
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnectivity();
    });
  }

  /// Check current connectivity status
  Future<void> _checkConnectivity() async {
    final wasOffline = _isOffline;

    try {
      // Try to lookup a reliable host
      final result = await InternetAddress.lookup('google.com');
      _isOffline = result.isEmpty;
    } catch (e) {
      // Assume offline on error
      _isOffline = true;
    }

    // Notify listeners if status changed
    if (wasOffline != _isOffline) {
      _connectivityController.add(_isOffline);
    }
  }

  /// Manually refresh connectivity status
  Future<void> refresh() async {
    await _checkConnectivity();
  }

  /// Dispose resources
  void dispose() {
    _timer?.cancel();
    _connectivityController.close();
  }
}

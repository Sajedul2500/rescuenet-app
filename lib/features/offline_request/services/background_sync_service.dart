import 'dart:async';
import 'dart:io';
import 'package:workmanager/workmanager.dart';
import '../data/repositories/offline_request_repository.dart';
import 'connectivity_service.dart';

/// Background sync service for Android
/// Automatically syncs pending requests when internet is available
class BackgroundSyncService {
  static const String syncTaskName = 'rescuenet_sync_task';
  static const String uniqueSyncTaskName = 'rescuenet_unique_sync';

  static final BackgroundSyncService _instance =
      BackgroundSyncService._internal();
  factory BackgroundSyncService() => _instance;
  BackgroundSyncService._internal();

  final OfflineRequestRepository _repository = OfflineRequestRepository();
  final ConnectivityService _connectivityService = ConnectivityService();

  bool _isInitialized = false;
  bool _isSyncing = false;
  StreamSubscription<bool>? _connectivitySubscription;

  /// Initialize background sync service
  Future<void> initialize() async {
    if (_isInitialized || !Platform.isAndroid) return;

    try {
      // Initialize Workmanager for Android
      await Workmanager().initialize(
        callbackDispatcher,
        isInDebugMode: false,
      );

      // Register periodic sync task (runs every 15 minutes when constraints are met)
      await Workmanager().registerPeriodicTask(
        uniqueSyncTaskName,
        syncTaskName,
        frequency: const Duration(minutes: 15),
        constraints: Constraints(
          networkType: NetworkType.connected,
        ),
        existingWorkPolicy: ExistingWorkPolicy.keep,
      );

      // Initialize connectivity service
      await _connectivityService.initialize();

      // Listen to connectivity changes for immediate sync
      _connectivitySubscription =
          _connectivityService.connectivityStream.listen((isConnected) {
        if (isConnected) {
          // Trigger immediate sync when connection is restored
          syncNow();
        }
      });

      _isInitialized = true;
      print('Background sync service initialized');
    } catch (e) {
      print('Failed to initialize background sync service: $e');
    }
  }

  /// Trigger immediate sync (can be called from UI)
  Future<Map<String, int>> syncNow() async {
    if (_isSyncing) {
      print('Sync already in progress');
      return {'success': 0, 'failed': 0, 'total': 0};
    }

    // Check connectivity
    if (!await _connectivityService.checkConnectivity()) {
      print('No internet connection, skipping sync');
      return {'success': 0, 'failed': 0, 'total': 0};
    }

    _isSyncing = true;

    try {
      final result = await _repository.syncAllPendingRequests();
      print(
          'Sync completed: ${result['success']}/${result['total']} successful');
      return result;
    } catch (e) {
      print('Error during sync: $e');
      return {'success': 0, 'failed': 0, 'total': 0};
    } finally {
      _isSyncing = false;
    }
  }

  /// Check if sync is currently running
  bool get isSyncing => _isSyncing;

  /// Cancel all background tasks
  Future<void> cancelAllTasks() async {
    if (!Platform.isAndroid) return;

    try {
      await Workmanager().cancelAll();
      print('All background tasks cancelled');
    } catch (e) {
      print('Failed to cancel background tasks: $e');
    }
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
  }
}

/// Workmanager callback dispatcher (runs in background isolate)
@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    print('Background task started: $task');

    try {
      // Create repository instance in background isolate
      final repository = OfflineRequestRepository();
      final connectivityService = ConnectivityService();

      // Initialize connectivity service
      await connectivityService.initialize();

      // Check if connected
      if (!await connectivityService.checkConnectivity()) {
        print('No internet connection in background task');
        return Future.value(false);
      }

      // Sync pending requests
      final result = await repository.syncAllPendingRequests();

      print(
          'Background sync completed: ${result['success']}/${result['total']} successful');

      // Cleanup old requests
      await repository.cleanupOldRequests();

      return Future.value(true);
    } catch (e) {
      print('Error in background task: $e');
      return Future.value(false);
    }
  });
}

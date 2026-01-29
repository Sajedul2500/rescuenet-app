import '../../domain/models/offline_request.dart';
import '../local/offline_request_local_storage.dart';
import '../../../../core/api/api_service.dart';

/// Repository for managing offline requests
class OfflineRequestRepository {
  final OfflineRequestLocalStorage _storage = OfflineRequestLocalStorage();
  final ApiService _apiService = ApiService();

  /// Create a new offline request and store it locally
  Future<OfflineRequest> createRequest({
    required String type,
    required String description,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    final request = OfflineRequest(
      type: type,
      description: description,
      latitude: latitude,
      longitude: longitude,
      locationName: locationName,
      createdAt: DateTime.now(),
      syncStatus: SyncStatus.pending,
    );

    final id = await _storage.insertRequest(request);
    return request.copyWith(id: id);
  }

  /// Get all pending requests that need to be synced
  Future<List<OfflineRequest>> getPendingRequests() async {
    return await _storage.getPendingRequests();
  }

  /// Get all requests for display
  Future<List<OfflineRequest>> getAllRequests() async {
    return await _storage.getAllRequests();
  }

  /// Sync a single request to the backend
  Future<bool> syncRequest(OfflineRequest request) async {
    try {
      // Mark as syncing
      await _storage.updateRequest(
        request.copyWith(syncStatus: SyncStatus.syncing),
      );

      // Prepare data for API
      final data = {
        'type': request.type,
        'description': request.description,
        'latitude': request.latitude.toString(),
        'longitude': request.longitude.toString(),
        'location_name': request.locationName ?? '',
      };

      // Send to backend
      final response = await _apiService.post<Map<String, dynamic>>(
        '/help-requests',
        data: data,
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        // Mark as synced
        await _storage.updateRequest(
          request.copyWith(
            syncStatus: SyncStatus.synced,
            errorMessage: null,
          ),
        );
        return true;
      } else {
        // Mark as failed with error message
        await _storage.updateRequest(
          request.copyWith(
            syncStatus: SyncStatus.failed,
            retryCount: request.retryCount + 1,
            errorMessage: response.message ?? 'Sync failed',
          ),
        );
        return false;
      }
    } catch (e) {
      print('Error syncing request: $e');

      // Mark as failed
      await _storage.updateRequest(
        request.copyWith(
          syncStatus: SyncStatus.failed,
          retryCount: request.retryCount + 1,
          errorMessage: e.toString(),
        ),
      );
      return false;
    }
  }

  /// Sync all pending requests
  Future<Map<String, int>> syncAllPendingRequests() async {
    final pendingRequests = await getPendingRequests();

    int successCount = 0;
    int failedCount = 0;

    for (final request in pendingRequests) {
      // Skip if retry count is too high (max 5 retries)
      if (request.retryCount >= 5) {
        failedCount++;
        continue;
      }

      final success = await syncRequest(request);
      if (success) {
        successCount++;
      } else {
        failedCount++;
      }

      // Add delay between requests to avoid overwhelming the server
      await Future.delayed(const Duration(milliseconds: 500));
    }

    return {
      'success': successCount,
      'failed': failedCount,
      'total': pendingRequests.length,
    };
  }

  /// Get count of pending requests
  Future<int> getPendingCount() async {
    final pending = await _storage.getPendingRequests();
    return pending.length;
  }

  /// Clean up old synced requests
  Future<void> cleanupOldRequests() async {
    await _storage.deleteSyncedRequests();
  }

  /// Update request status
  Future<void> updateRequestStatus(
    OfflineRequest request,
    SyncStatus status, {
    String? errorMessage,
  }) async {
    await _storage.updateRequest(
      request.copyWith(
        syncStatus: status,
        errorMessage: errorMessage,
      ),
    );
  }
}
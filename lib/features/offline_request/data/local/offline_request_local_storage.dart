import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/offline_request.dart';

/// Local storage for offline requests using SharedPreferences
/// More reliable than SQLite as it doesn't require native plugins
class OfflineRequestLocalStorage {
  static const String _requestsKey = 'offline_requests';
  static const String _counterKey = 'offline_request_counter';

  /// Insert a new offline request
  Future<int> insertRequest(OfflineRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Get current requests
      final requests = await getAllRequests();

      // Generate new ID
      final id = await _getNextId();

      // Add new request with ID
      final newRequest = request.copyWith(id: id);
      requests.add(newRequest);

      // Save to storage
      await _saveRequests(prefs, requests);

      return id;
    } catch (e) {
      print('Error inserting request to local storage: $e');
      throw Exception('Failed to save request: ${e.toString()}');
    }
  }

  /// Get next available ID
  Future<int> _getNextId() async {
    final prefs = await SharedPreferences.getInstance();
    final counter = prefs.getInt(_counterKey) ?? 0;
    final nextId = counter + 1;
    await prefs.setInt(_counterKey, nextId);
    return nextId;
  }

  /// Get all pending requests
  Future<List<OfflineRequest>> getPendingRequests() async {
    try {
      final requests = await getAllRequests();
      return requests.where((r) => r.syncStatus == SyncStatus.pending).toList();
    } catch (e) {
      print('Error getting pending requests: $e');
      return [];
    }
  }

  /// Get all requests (for display purposes)
  Future<List<OfflineRequest>> getAllRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_requestsKey);

      if (jsonString == null || jsonString.isEmpty) {
        return [];
      }

      final List<dynamic> jsonList = json.decode(jsonString);
      return jsonList
          .map((json) => OfflineRequest.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print('Error getting all requests: $e');
      return [];
    }
  }

  /// Update request sync status
  Future<int> updateRequest(OfflineRequest request) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = await getAllRequests();

      // Find and update the request
      final index = requests.indexWhere((r) => r.id == request.id);
      if (index != -1) {
        requests[index] = request;
        await _saveRequests(prefs, requests);
        return 1; // Success
      }
      return 0; // Not found
    } catch (e) {
      print('Error updating request: $e');
      return 0;
    }
  }

  /// Delete synced requests older than 7 days (cleanup)
  Future<int> deleteSyncedRequests() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final requests = await getAllRequests();
      final sevenDaysAgo = DateTime.now().subtract(const Duration(days: 7));

      final filteredRequests = requests.where((request) {
        final isSynced = request.syncStatus == SyncStatus.synced;
        final isOld = request.createdAt.isBefore(sevenDaysAgo);
        return !(isSynced && isOld);
      }).toList();

      final deletedCount = requests.length - filteredRequests.length;
      await _saveRequests(prefs, filteredRequests);

      return deletedCount;
    } catch (e) {
      print('Error deleting synced requests: $e');
      return 0;
    }
  }

  /// Get count of pending requests
  Future<int> getPendingCount() async {
    try {
      final pending = await getPendingRequests();
      return pending.length;
    } catch (e) {
      print('Error getting pending count: $e');
      return 0;
    }
  }

  /// Save requests to SharedPreferences
  Future<void> _saveRequests(
      SharedPreferences prefs, List<OfflineRequest> requests) async {
    final jsonList = requests.map((r) => r.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_requestsKey, jsonString);
  }

  /// Clear all requests (for testing/debugging)
  Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_requestsKey);
    await prefs.remove(_counterKey);
  }
}

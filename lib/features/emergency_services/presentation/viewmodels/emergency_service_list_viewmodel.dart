import 'package:flutter/foundation.dart';
import '../../domain/entities/emergency_service.dart';
import '../../domain/repositories/emergency_service_repository.dart';

/// ViewModel for Emergency Service List Screen.
/// Handles business logic and state management.
class EmergencyServiceListViewModel extends ChangeNotifier {
  final EmergencyServiceRepository _repository;
  bool _disposed = false;

  EmergencyServiceListViewModel(this._repository);

  // State
  List<EmergencyService> _services = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _searchQuery;

  // Getters
  List<EmergencyService> get services => _services;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;
  bool get isEmpty => _services.isEmpty && !_isLoading && !hasError;

  /// Loads nearby services
  Future<void> loadNearbyServices({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radius = 10.0,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    _searchQuery = null;
    _notifyListeners();

    try {
      _services = await _repository.getNearbyServices(
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
        radius: radius,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _services = [];
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Searches for services
  Future<void> searchServices({
    required String query,
    required double latitude,
    required double longitude,
    String? serviceType,
  }) async {
    if (query.trim().isEmpty) {
      // Reset to nearby services if query is empty
      if (serviceType != null) {
        await loadNearbyServices(
          latitude: latitude,
          longitude: longitude,
          serviceType: serviceType,
        );
      }
      return;
    }

    _isLoading = true;
    _errorMessage = null;
    _searchQuery = query;
    _notifyListeners();

    try {
      _services = await _repository.searchServices(
        query: query,
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = _getErrorMessage(e);
      _services = [];
    } finally {
      _isLoading = false;
      _notifyListeners();
    }
  }

  /// Retries the last operation
  Future<void> retry({
    required double latitude,
    required double longitude,
    required String serviceType,
  }) async {
    if (_searchQuery != null) {
      await searchServices(
        query: _searchQuery!,
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
      );
    } else {
      await loadNearbyServices(
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
      );
    }
  }

  /// Clears error message
  void clearError() {
    _errorMessage = null;
    _notifyListeners();
  }

  /// Gets user-friendly error message
  String _getErrorMessage(dynamic error) {
    final errorStr = error.toString().toLowerCase();

    if (errorStr.contains('network') ||
        errorStr.contains('socket') ||
        errorStr.contains('connection')) {
      return 'No internet connection. Please check your network.';
    } else if (errorStr.contains('timeout')) {
      return 'Request timed out. Please try again.';
    } else if (errorStr.contains('404')) {
      return 'Service not found.';
    } else if (errorStr.contains('500') || errorStr.contains('server')) {
      return 'Server error. Please try again later.';
    } else {
      return 'Failed to load services. Please try again.';
    }
  }

  /// Safe notifyListeners that checks if disposed
  void _notifyListeners() {
    if (!_disposed) {
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}

import '../entities/emergency_service.dart';

/// Repository interface for emergency services.
/// Domain layer - defines contract, not implementation.
abstract class EmergencyServiceRepository {
  /// Fetches nearby emergency services based on user location and type.
  ///
  /// [latitude] User's current latitude
  /// [longitude] User's current longitude
  /// [serviceType] Type of service (police, fire, medical, etc.)
  /// [radius] Search radius in kilometers (default: 10km)
  ///
  /// Returns a list of emergency services sorted by distance.
  /// Throws an exception if the operation fails.
  Future<List<EmergencyService>> getNearbyServices({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radius = 10.0,
  });

  /// Fetches a specific emergency service by ID.
  ///
  /// [serviceId] Unique identifier of the service
  ///
  /// Returns the emergency service or null if not found.
  Future<EmergencyService?> getServiceById(String serviceId);

  /// Searches for emergency services by name or address.
  ///
  /// [query] Search query
  /// [latitude] User's current latitude for distance calculation
  /// [longitude] User's current longitude for distance calculation
  /// [serviceType] Optional service type filter
  ///
  /// Returns a list of matching emergency services.
  Future<List<EmergencyService>> searchServices({
    required String query,
    required double latitude,
    required double longitude,
    String? serviceType,
  });
}

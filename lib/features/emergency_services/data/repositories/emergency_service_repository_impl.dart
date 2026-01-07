import '../../domain/entities/emergency_service.dart';
import '../../domain/repositories/emergency_service_repository.dart';
import '../datasources/osm_service_datasource.dart';
import '../datasources/backend_service_datasource.dart';

/// Implementation of Emergency Service Repository.
/// Decides which data source to use (OSM or Backend).
/// UI layer doesn't need to know about data source implementation.
class EmergencyServiceRepositoryImpl implements EmergencyServiceRepository {
  final OsmServiceDataSource _osmDataSource;
  final BackendServiceDataSource? _backendDataSource;
  final bool useBackend;

  EmergencyServiceRepositoryImpl({
    OsmServiceDataSource? osmDataSource,
    BackendServiceDataSource? backendDataSource,
    this.useBackend = false, // Default to OSM
  })  : _osmDataSource = osmDataSource ?? OsmServiceDataSource(),
        _backendDataSource = backendDataSource;

  @override
  Future<List<EmergencyService>> getNearbyServices({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radius = 10.0,
  }) async {
    try {
      // Try backend first if enabled and available
      if (useBackend && _backendDataSource != null) {
        try {
          return await _backendDataSource.fetchNearbyServices(
            latitude: latitude,
            longitude: longitude,
            serviceType: serviceType,
            radius: radius,
          );
        } catch (e) {
          // Fallback to OSM if backend fails
          print('Backend fetch failed, falling back to OSM: $e');
        }
      }

      // Use OSM as default or fallback
      return await _osmDataSource.fetchNearbyServices(
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
        radius: radius,
      );
    } catch (e) {
      throw Exception('Failed to fetch nearby services: $e');
    }
  }

  @override
  Future<EmergencyService?> getServiceById(String serviceId) async {
    try {
      // Try backend first if enabled and service ID is from backend
      if (useBackend &&
          _backendDataSource != null &&
          !serviceId.startsWith('osm_')) {
        return await _backendDataSource.fetchServiceById(serviceId);
      }

      // OSM doesn't support fetch by ID, return null
      return null;
    } catch (e) {
      throw Exception('Failed to fetch service by ID: $e');
    }
  }

  @override
  Future<List<EmergencyService>> searchServices({
    required String query,
    required double latitude,
    required double longitude,
    String? serviceType,
  }) async {
    try {
      // Try backend first if enabled
      if (useBackend && _backendDataSource != null) {
        try {
          return await _backendDataSource.searchServices(
            query: query,
            latitude: latitude,
            longitude: longitude,
            serviceType: serviceType,
          );
        } catch (e) {
          print('Backend search failed, falling back to OSM: $e');
        }
      }

      // OSM doesn't have a dedicated search endpoint
      // Fetch all services and filter by name/address
      final services = await _osmDataSource.fetchNearbyServices(
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType ?? 'all',
        radius: 20.0, // Wider radius for search
      );

      // Filter by query
      final lowerQuery = query.toLowerCase();
      return services.where((service) {
        return service.name.toLowerCase().contains(lowerQuery) ||
            service.address.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      throw Exception('Failed to search services: $e');
    }
  }
}

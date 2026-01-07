import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/emergency_service.dart';

/// Data source for fetching emergency services from Laravel backend API.
/// This can be used as an alternative to OSM when backend is available.
class BackendServiceDataSource {
  final String baseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  BackendServiceDataSource({
    this.baseUrl = 'https://api.rescuenet.com', // Replace with actual URL
  });

  /// Fetches nearby services from backend API.
  Future<List<EmergencyService>> fetchNearbyServices({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radius = 10.0,
  }) async {
    try {
      final uri = Uri.parse('$baseUrl/api/emergency-services/nearby').replace(
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'type': serviceType,
          'radius': radius.toString(),
        },
      );

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseBackendResponse(data, serviceType);
      } else {
        throw Exception('Failed to fetch services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching backend services: $e');
    }
  }

  /// Fetches service by ID from backend.
  Future<EmergencyService?> fetchServiceById(String serviceId) async {
    try {
      final uri = Uri.parse('$baseUrl/api/emergency-services/$serviceId');

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseServiceFromBackend(data['data']);
      } else if (response.statusCode == 404) {
        return null;
      } else {
        throw Exception('Failed to fetch service: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching service by ID: $e');
    }
  }

  /// Searches services from backend.
  Future<List<EmergencyService>> searchServices({
    required String query,
    required double latitude,
    required double longitude,
    String? serviceType,
  }) async {
    try {
      final queryParams = {
        'q': query,
        'latitude': latitude.toString(),
        'longitude': longitude.toString(),
      };

      if (serviceType != null) {
        queryParams['type'] = serviceType;
      }

      final uri = Uri.parse('$baseUrl/api/emergency-services/search')
          .replace(queryParameters: queryParams);

      final response = await http.get(
        uri,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ).timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseBackendResponse(data, serviceType ?? 'mixed');
      } else {
        throw Exception('Failed to search services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching services: $e');
    }
  }

  /// Parses backend API response
  List<EmergencyService> _parseBackendResponse(
    Map<String, dynamic> data,
    String serviceType,
  ) {
    final services = <EmergencyService>[];
    final items = data['data'] as List? ?? [];

    for (var item in items) {
      try {
        services.add(_parseServiceFromBackend(item));
      } catch (e) {
        // Skip malformed items
        continue;
      }
    }

    return services;
  }

  /// Parses a single service from backend format
  EmergencyService _parseServiceFromBackend(Map<String, dynamic> item) {
    return EmergencyService(
      id: item['id'].toString(),
      name: item['name'] ?? 'Unnamed Service',
      type: item['type'] ?? 'unknown',
      latitude: (item['latitude'] ?? 0.0).toDouble(),
      longitude: (item['longitude'] ?? 0.0).toDouble(),
      address: item['address'] ?? 'Address not available',
      distance: item['distance'] != null ? (item['distance']).toDouble() : null,
      phone: item['phone'],
      openingHours: item['opening_hours'],
      additionalInfo: {
        'source': 'backend',
        'verified': item['verified'] ?? false,
        'rating': item['rating'],
        'total_reviews': item['total_reviews'],
        ...?item['additional_info'],
      },
    );
  }
}

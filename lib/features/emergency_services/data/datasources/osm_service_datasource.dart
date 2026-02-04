import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../domain/entities/emergency_service.dart';

/// Data source for fetching emergency services from OpenStreetMap (Overpass API).
/// This is a concrete implementation that can be swapped with backend API.
class OsmServiceDataSource {
  static const String _overpassUrl = 'https://overpass-api.de/api/interpreter';
  static const Duration _timeout = Duration(seconds: 15);

  /// Fetches nearby services from OpenStreetMap using Overpass API.
  Future<List<EmergencyService>> fetchNearbyServices({
    required double latitude,
    required double longitude,
    required String serviceType,
    double radius = 10.0,
  }) async {
    try {
      final query = _buildOverpassQuery(
        latitude: latitude,
        longitude: longitude,
        serviceType: serviceType,
        radius: radius,
      );

      final response = await http
          .post(
            Uri.parse(_overpassUrl),
            headers: {'Content-Type': 'application/x-www-form-urlencoded'},
            body: 'data=$query',
          )
          .timeout(_timeout);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _parseOsmResponse(
          data,
          userLat: latitude,
          userLon: longitude,
          serviceType: serviceType,
        );
      } else {
        throw Exception('Failed to fetch services: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error fetching OSM services: $e');
    }
  }

  /// Builds Overpass QL query based on service type
  String _buildOverpassQuery({
    required double latitude,
    required double longitude,
    required String serviceType,
    required double radius,
  }) {
    final radiusInMeters = (radius * 1000).toInt();
    final osmTag = _getOsmTag(serviceType);

    return '''
[out:json][timeout:15];
(
  node$osmTag(around:$radiusInMeters,$latitude,$longitude);
  way$osmTag(around:$radiusInMeters,$latitude,$longitude);
  relation$osmTag(around:$radiusInMeters,$latitude,$longitude);
);
out center;
''';
  }

  /// Maps service type to OSM tags
  String _getOsmTag(String serviceType) {
    switch (serviceType) {
      case ServiceType.police:
        return '["amenity"="police"]';
      case ServiceType.fire:
        return '["amenity"="fire_station"]';
      case ServiceType.medical:
        return '["amenity"~"hospital|clinic|doctors"]';
      case ServiceType.shelter:
        return '["amenity"="shelter"]';
      case ServiceType.bloodBank:
        return '["healthcare"="blood_bank"]';
      default:
        return '["amenity"~".*"]';
    }
  }

  /// Parses OSM Overpass API response
  List<EmergencyService> _parseOsmResponse(
    Map<String, dynamic> data, {
    required double userLat,
    required double userLon,
    required String serviceType,
  }) {
    final elements = data['elements'] as List? ?? [];
    final services = <EmergencyService>[];

    for (var element in elements) {
      try {
        final tags = element['tags'] as Map<String, dynamic>? ?? {};
        final lat = (element['lat'] ?? element['center']?['lat']) as double?;
        final lon = (element['lon'] ?? element['center']?['lon']) as double?;

        if (lat == null || lon == null) continue;

        final name = tags['name'] ??
            'Unnamed ${ServiceType.getDisplayName(serviceType)}';
        final address = _buildAddress(tags);
        final distance = _calculateDistance(userLat, userLon, lat, lon);

        services.add(EmergencyService(
          id: 'osm_${element['id']}',
          name: name,
          type: serviceType,
          latitude: lat,
          longitude: lon,
          address: address,
          distance: distance,
          phone: tags['phone'],
          openingHours: tags['opening_hours'],
          additionalInfo: {
            'source': 'osm',
            'operator': tags['operator'],
            'website': tags['website'],
          },
        ));
      } catch (e) {
        // Skip malformed elements
        continue;
      }
    }

    // Sort by distance
    services.sort((a, b) => (a.distance ?? double.infinity)
        .compareTo(b.distance ?? double.infinity));

    return services;
  }

  /// Builds address from OSM tags
  String _buildAddress(Map<String, dynamic> tags) {
    final parts = <String>[];

    if (tags['addr:housenumber'] != null) parts.add(tags['addr:housenumber']);
    if (tags['addr:street'] != null) parts.add(tags['addr:street']);
    if (tags['addr:city'] != null) parts.add(tags['addr:city']);
    if (tags['addr:postcode'] != null) parts.add(tags['addr:postcode']);

    return parts.isEmpty ? 'Address not available' : parts.join(', ');
  }

  /// Calculates distance between two coordinates using Haversine formula
  double _calculateDistance(
      double lat1, double lon1, double lat2, double lon2) {
    const earthRadius = 6371; // km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);

    final a = (sin(dLat / 2) * sin(dLat / 2)) +
        (cos(_toRadians(lat1)) *
            cos(_toRadians(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2));

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _toRadians(double degrees) => degrees * (3.141592653589793 / 180.0);

  double sin(double x) => _sin(x);
  double cos(double x) => _cos(x);
  double sqrt(double x) => _sqrt(x);
  double asin(double x) => _asin(x);

  double _sin(double x) {
    // Taylor series approximation
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= -x * x / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }

  double _cos(double x) {
    return _sin(x + 3.141592653589793 / 2);
  }

  double _sqrt(double x) {
    if (x < 0) return double.nan;
    if (x == 0) return 0;
    double guess = x / 2;
    for (int i = 0; i < 10; i++) {
      guess = (guess + x / guess) / 2;
    }
    return guess;
  }

  double _asin(double x) {
    // Taylor series approximation
    if (x < -1 || x > 1) return double.nan;
    double result = x;
    double term = x;
    for (int i = 1; i < 10; i++) {
      term *= x * x * (2 * i - 1) * (2 * i - 1) / ((2 * i) * (2 * i + 1));
      result += term;
    }
    return result;
  }
}

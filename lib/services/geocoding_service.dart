import 'dart:convert';
import 'package:http/http.dart' as http;

class GeocodingService {
  static const String _baseUrl = 'https://nominatim.openstreetmap.org';

  /// Reverse geocode: Get place name from coordinates
  /// Returns a formatted address string or null if failed
  static Future<Map<String, dynamic>?> getPlaceFromCoordinates({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/reverse?format=json&lat=$latitude&lon=$longitude&zoom=18&addressdetails=1',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RescueNetApp/1.0.0', // Required by Nominatim
          'Accept-Language': 'en', // Prefer English responses
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data is Map<String, dynamic>) {
          return {
            'displayName': data['display_name'] ?? 'Unknown Location',
            'address': _formatAddress(data['address'] ?? {}),
            'city': data['address']?['city'] ??
                data['address']?['town'] ??
                data['address']?['village'] ??
                data['address']?['county'] ??
                '',
            'state': data['address']?['state'] ?? '',
            'country': data['address']?['country'] ?? '',
            'countryCode':
                data['address']?['country_code']?.toString().toUpperCase() ??
                    '',
            'postcode': data['address']?['postcode'] ?? '',
            'latitude': latitude,
            'longitude': longitude,
            'raw': data,
          };
        }
      } else if (response.statusCode == 429) {
        throw Exception('Rate limit exceeded. Please try again later.');
      } else {
        throw Exception('Failed to fetch location: ${response.statusCode}');
      }
    } catch (e) {
      print('Geocoding error: $e');
      return null;
    }
    return null;
  }

  /// Format address from Nominatim address components
  static String _formatAddress(Map<String, dynamic> address) {
    List<String> parts = [];

    // Add house number and road
    if (address['house_number'] != null && address['road'] != null) {
      parts.add('${address['house_number']} ${address['road']}');
    } else if (address['road'] != null) {
      parts.add(address['road']);
    }

    // Add neighbourhood or suburb
    if (address['neighbourhood'] != null) {
      parts.add(address['neighbourhood']);
    } else if (address['suburb'] != null) {
      parts.add(address['suburb']);
    }

    // Add city/town/village
    if (address['city'] != null) {
      parts.add(address['city']);
    } else if (address['town'] != null) {
      parts.add(address['town']);
    } else if (address['village'] != null) {
      parts.add(address['village']);
    }

    // Add state
    if (address['state'] != null) {
      parts.add(address['state']);
    }

    // Add country
    if (address['country'] != null) {
      parts.add(address['country']);
    }

    return parts.isNotEmpty ? parts.join(', ') : 'Unknown Location';
  }

  /// Get short place name (City, Country)
  static String getShortPlaceName(Map<String, dynamic>? location) {
    if (location == null) return 'Unknown Location';

    final city = location['city'] as String? ?? '';
    final country = location['country'] as String? ?? '';

    if (city.isNotEmpty && country.isNotEmpty) {
      return '$city, $country';
    } else if (city.isNotEmpty) {
      return city;
    } else if (country.isNotEmpty) {
      return country;
    }

    return location['displayName'] ?? 'Unknown Location';
  }

  /// Forward geocode: Search for places (optional for future use)
  static Future<List<Map<String, dynamic>>> searchPlaces(String query) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/search?format=json&q=${Uri.encodeComponent(query)}&limit=5',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'RescueNetApp/1.0.0',
          'Accept-Language': 'en',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data
            .map((item) => {
                  'displayName': item['display_name'] ?? '',
                  'latitude':
                      double.tryParse(item['lat']?.toString() ?? '0') ?? 0.0,
                  'longitude':
                      double.tryParse(item['lon']?.toString() ?? '0') ?? 0.0,
                  'type': item['type'] ?? '',
                  'importance': item['importance'] ?? 0.0,
                })
            .toList();
      }
    } catch (e) {
      print('Search error: $e');
    }
    return [];
  }
}

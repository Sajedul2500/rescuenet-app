import '../core/api/api_service.dart';
import '../core/api/api_config.dart';
import '../core/api/api_response.dart';

/// Service for More Services features (Emergency Contacts, Nearby Volunteers)
class MoreService {
  final ApiService _apiService;

  MoreService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get emergency contacts
  Future<ApiResponse<List<EmergencyContact>>> getEmergencyContacts() async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.emergencyContacts,
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final contactsList = (response.data!['emergency_contacts'] as List?)
                ?.map(
                    (e) => EmergencyContact.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return ApiResponse.success(
          contactsList,
          message: response.message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to load emergency contacts',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  /// Add emergency contact
  Future<ApiResponse<EmergencyContact>> addEmergencyContact({
    required String name,
    required String phone,
    String? relationship,
  }) async {
    try {
      final response = await _apiService.post<Map<String, dynamic>>(
        ApiConfig.emergencyContacts,
        data: {
          'name': name,
          'phone': phone,
          if (relationship != null) 'relationship': relationship,
        },
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final contact = EmergencyContact.fromJson(
            response.data!['emergency_contact'] as Map<String, dynamic>);

        return ApiResponse.success(
          contact,
          message: response.message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to add emergency contact',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  /// Delete emergency contact
  Future<ApiResponse<void>> deleteEmergencyContact(int id) async {
    try {
      final response = await _apiService.delete<Map<String, dynamic>>(
        '${ApiConfig.emergencyContacts}/$id',
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success) {
        return ApiResponse.success(
          null,
          message: response.message ?? 'Contact deleted successfully',
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to delete emergency contact',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }

  /// Get nearby volunteers
  Future<ApiResponse<List<NearbyVolunteer>>> getNearbyVolunteers({
    required double latitude,
    required double longitude,
    double? radiusKm,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.nearbyVolunteers,
        queryParameters: {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          if (radiusKm != null) 'radius_km': radiusKm.toString(),
        },
        parser: (data) => data as Map<String, dynamic>,
      );

      if (response.success && response.data != null) {
        final volunteersList = (response.data!['volunteers'] as List?)
                ?.map(
                    (e) => NearbyVolunteer.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [];

        return ApiResponse.success(
          volunteersList,
          message: response.message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to load nearby volunteers',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Error: $e');
    }
  }
}

/// Emergency Contact Model
class EmergencyContact {
  final int id;
  final String name;
  final String phone;
  final String? relationship;
  final String? createdAt;

  EmergencyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.relationship,
    this.createdAt,
  });

  factory EmergencyContact.fromJson(Map<String, dynamic> json) {
    return EmergencyContact(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      relationship: json['relationship']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      if (relationship != null) 'relationship': relationship,
      if (createdAt != null) 'created_at': createdAt,
    };
  }
}

/// Nearby Volunteer Model
class NearbyVolunteer {
  final int id;
  final int userId;
  final double? latitude;
  final double? longitude;
  final double distance;
  final User? user;

  NearbyVolunteer({
    required this.id,
    required this.userId,
    this.latitude,
    this.longitude,
    required this.distance,
    this.user,
  });

  factory NearbyVolunteer.fromJson(Map<String, dynamic> json) {
    return NearbyVolunteer(
      id: json['id'] as int,
      userId: json['user_id'] as int,
      latitude: _parseDouble(json['latitude']),
      longitude: _parseDouble(json['longitude']),
      distance: _parseDouble(json['distance']) ?? 0.0,
      user: json['user'] != null
          ? User.fromJson(json['user'] as Map<String, dynamic>)
          : null,
    );
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  String get distanceText {
    if (distance < 1) {
      return '${(distance * 1000).toStringAsFixed(0)} m';
    }
    return '${distance.toStringAsFixed(1)} km';
  }

  String get etaText {
    // Assuming average walking speed of 5 km/h
    final hours = distance / 5;
    final minutes = (hours * 60).ceil();
    if (minutes < 60) {
      return '$minutes mins';
    }
    final hrs = (minutes / 60).floor();
    final mins = minutes % 60;
    return '$hrs hr${hrs > 1 ? 's' : ''} ${mins > 0 ? '$mins mins' : ''}';
  }
}

/// User Model (for volunteer)
class User {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final bool? isVerified;

  User({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.isVerified,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      name: json['name']?.toString() ?? 'Unknown',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      isVerified: json['is_verified'] as bool?,
    );
  }
}

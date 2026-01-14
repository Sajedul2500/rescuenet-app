import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/api_service.dart';

/// Dashboard Service
/// Handles dashboard-related API calls
class DashboardService {
  final ApiService _apiService;

  DashboardService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get dashboard data with user location
  Future<ApiResponse<DashboardData>> getDashboardData({
    double? latitude,
    double? longitude,
  }) async {
    try {
      final response = await _apiService.get<Map<String, dynamic>>(
        ApiConfig.dashboard,
        queryParameters: {
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        },
      );

      if (response.success && response.data != null) {
        final dashboardData = DashboardData.fromJson(response.data!);
        return ApiResponse.success(
          dashboardData,
          message: response.message,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          response.message ?? 'Failed to fetch dashboard data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      return ApiResponse.error('Unexpected error: $e');
    }
  }
}

/// Dashboard Data Model
class DashboardData {
  final UserInfo user;
  final List<HelpRequest> helpRequests;

  DashboardData({
    required this.user,
    required this.helpRequests,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    // The API response structure is:
    // { "success": true, "user": {...}, "data": { "help_requests": [...] } }
    // But api_service.dart passes data['data'] to parser if it exists
    // So we need to handle both cases

    Map<String, dynamic>? userData;
    List? helpRequestsList;

    // Case 1: Full response passed (has 'user' at root)
    if (json.containsKey('user')) {
      userData = json['user'] as Map<String, dynamic>?;
      final dataObj = json['data'] as Map<String, dynamic>?;
      helpRequestsList = dataObj?['help_requests'] as List?;
    }
    // Case 2: Only nested 'data' object passed (has 'help_requests' at root)
    else if (json.containsKey('help_requests')) {
      // This case shouldn't happen with current API structure, but handle it
      userData = null;
      helpRequestsList = json['help_requests'] as List?;
    }

    return DashboardData(
      user: userData != null
          ? UserInfo.fromJson(userData)
          : UserInfo(
              id: 0,
              name: 'Unknown',
              isVerified: false,
              hasEmergencyContact: false),
      helpRequests: helpRequestsList
              ?.map((e) => HelpRequest.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
}

/// User Info Model
class UserInfo {
  final int id;
  final String name;
  final bool isVerified;
  final bool hasEmergencyContact;

  UserInfo({
    required this.id,
    required this.name,
    required this.isVerified,
    required this.hasEmergencyContact,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'User',
      isVerified: json['is_verified'] as bool? ?? false,
      hasEmergencyContact: json['has_emergency_contact'] as bool? ?? false,
    );
  }
}

/// Help Request Model
class HelpRequest {
  final int id;
  final String userName;
  final String? userPhone;
  final String category;
  final String description;
  final String? location;
  final double? latitude;
  final double? longitude;
  final String status;
  final String createdAt;
  final double? distance;

  HelpRequest({
    required this.id,
    required this.userName,
    this.userPhone,
    required this.category,
    required this.description,
    this.location,
    this.latitude,
    this.longitude,
    required this.status,
    required this.createdAt,
    this.distance,
  });

  factory HelpRequest.fromJson(Map<String, dynamic> json) {
    // Parse nested user object
    final user = json['user'] as Map<String, dynamic>?;
    final userName = user?['name']?.toString() ?? 'Unknown';

    // Parse nested location object
    final locationObj = json['location'] as Map<String, dynamic>?;
    final latitude = (locationObj?['latitude'] as num?)?.toDouble();
    final longitude = (locationObj?['longitude'] as num?)?.toDouble();
    final locationName = locationObj?['name']?.toString();
    final distance = (locationObj?['distance'] as num?)?.toDouble();

    return HelpRequest(
      id: json['id'] as int? ?? 0,
      userName: userName,
      userPhone: null, // Not provided in API response
      category: json['type']?.toString() ?? 'Emergency',
      description: json['description']?.toString() ?? '',
      location: locationName,
      latitude: latitude,
      longitude: longitude,
      status: json['status']?.toString() ?? 'pending',
      createdAt:
          json['created_at']?.toString() ?? DateTime.now().toIso8601String(),
      distance: distance,
    );
  }

  String get timeAgo {
    try {
      final dateTime = DateTime.parse(createdAt);
      final now = DateTime.now();
      final difference = now.difference(dateTime);

      if (difference.inMinutes < 1) {
        return 'Just now';
      } else if (difference.inMinutes < 60) {
        return '${difference.inMinutes} min ago';
      } else if (difference.inHours < 24) {
        return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
      } else {
        return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
      }
    } catch (e) {
      return 'Recently';
    }
  }

  String get distanceText {
    if (distance == null) return 'Unknown distance';
    if (distance! < 1) {
      return '${(distance! * 1000).toStringAsFixed(0)} m';
    } else {
      return '${distance!.toStringAsFixed(1)} km';
    }
  }
}

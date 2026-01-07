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
    final response = await _apiService.post<DashboardData>(
      ApiConfig.dashboard,
      data: {
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
      },
      parser: (data) => DashboardData.fromJson(data as Map<String, dynamic>),
    );

    return response;
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
    return DashboardData(
      user: UserInfo.fromJson(json['user'] as Map<String, dynamic>),
      helpRequests: (json['help_requests'] as List?)
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
    return HelpRequest(
      id: json['id'] as int? ?? 0,
      userName: json['user_name']?.toString() ?? 'Unknown',
      userPhone: json['user_phone']?.toString(),
      category: json['category']?.toString() ?? 'Emergency',
      description: json['description']?.toString() ?? '',
      location: json['location']?.toString(),
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString() ?? '',
      distance: (json['distance'] as num?)?.toDouble(),
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

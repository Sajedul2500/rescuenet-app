import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/auth_storage.dart';
import 'package:dio/dio.dart';

/// Dashboard Service
/// Handles dashboard-related API calls
class DashboardService {
  final ApiService _apiService;
  final AuthStorage _authStorage;

  DashboardService({ApiService? apiService, AuthStorage? authStorage})
      : _apiService = apiService ?? ApiService(),
        _authStorage = authStorage ?? AuthStorage();

  /// Get dashboard data with user location
  /// Uses raw Dio to get full response including user object
  Future<ApiResponse<DashboardData>> getDashboardData({
    double? latitude,
    double? longitude,
  }) async {
    try {
      // Get token
      final token = await _authStorage.getToken();

      // Make direct Dio call to get full response
      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));

      final response = await dio.get(
        ApiConfig.dashboard,
        queryParameters: {
          if (latitude != null) 'latitude': latitude.toString(),
          if (longitude != null) 'longitude': longitude.toString(),
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final fullData = response.data as Map<String, dynamic>;

        print('📦 Full dashboard response: $fullData');

        final dashboardData = DashboardData.fromJson(fullData);
        return ApiResponse.success(
          dashboardData,
          message: fullData['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to fetch dashboard data',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Dashboard fetch error: $e');
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Get detailed help request by ID
  Future<ApiResponse<HelpRequestDetail>> getHelpRequestDetails(
      int requestId) async {
    try {
      final token = await _authStorage.getToken();

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));

      final response = await dio.get('${ApiConfig.helpRequests}/$requestId');

      if (response.statusCode == 200 && response.data != null) {
        final fullData = response.data as Map<String, dynamic>;
        final detailData = fullData['data'] as Map<String, dynamic>;

        final helpRequestDetail = HelpRequestDetail.fromJson(detailData);
        return ApiResponse.success(
          helpRequestDetail,
          message: fullData['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to fetch help request details',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Help request details fetch error: $e');
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Respond to a help request
  Future<ApiResponse<Map<String, dynamic>>> respondToHelpRequest({
    required int requestId,
    required String action,
    String? note,
  }) async {
    try {
      final token = await _authStorage.getToken();

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));

      final response = await dio.post(
        '${ApiConfig.helpRequests}/$requestId/respond',
        data: {
          'action': action,
          if (note != null && note.isNotEmpty) 'note': note,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final fullData = response.data as Map<String, dynamic>;
        return ApiResponse.success(
          fullData,
          message: fullData['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to respond to help request',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Respond to help request error: $e');
      return ApiResponse.error('Unexpected error: $e');
    }
  }

  /// Submit a flag report for a help request
  Future<ApiResponse<Map<String, dynamic>>> submitFlagReport({
    required int requestId,
    required String reportType,
    required String reportReason,
    String? reportAttachment,
  }) async {
    try {
      final token = await _authStorage.getToken();

      final dio = Dio(BaseOptions(
        baseUrl: ApiConfig.baseUrl,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      ));

      final response = await dio.post(
        ApiConfig.flagReports,
        data: {
          'request_id': requestId,
          'report_type': reportType,
          'report_reason': reportReason,
          if (reportAttachment != null && reportAttachment.isNotEmpty)
            'report_attachment': reportAttachment,
        },
      );

      if (response.statusCode == 200 && response.data != null) {
        final fullData = response.data as Map<String, dynamic>;
        return ApiResponse.success(
          fullData,
          message: fullData['message'] as String?,
          statusCode: response.statusCode,
        );
      } else {
        return ApiResponse.error(
          'Failed to submit flag report',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      print('❌ Submit flag report error: $e');
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
              role: 'member',
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
  final String role;
  final bool isVerified;
  final bool hasEmergencyContact;

  UserInfo({
    required this.id,
    required this.name,
    required this.role,
    required this.isVerified,
    required this.hasEmergencyContact,
  });

  factory UserInfo.fromJson(Map<String, dynamic> json) {
    return UserInfo(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'User',
      role: json['role']?.toString() ?? 'member',
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
  final int flagsCount;

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
    this.flagsCount = 0,
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
      flagsCount: json['flagsCount'] as int? ?? 0,
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

/// Detailed Help Request Model
class HelpRequestDetail {
  final int id;
  final RequestedUser requestedUser;
  final String type;
  final String description;
  final RequestLocation location;
  final List<AttachedFile> attachedFiles;
  final List<RequestLog> requestLogs;
  final List<FlaggedReport> flaggedReports;
  final String status;
  final String? createdAt;
  final String? updatedAt;

  HelpRequestDetail({
    required this.id,
    required this.requestedUser,
    required this.type,
    required this.description,
    required this.location,
    required this.attachedFiles,
    required this.requestLogs,
    required this.flaggedReports,
    required this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory HelpRequestDetail.fromJson(Map<String, dynamic> json) {
    return HelpRequestDetail(
      id: json['id'] as int,
      requestedUser: RequestedUser.fromJson(
          json['requested_user'] as Map<String, dynamic>),
      type: json['type']?.toString() ?? 'Emergency',
      description: json['description']?.toString() ?? '',
      location: RequestLocation.fromJson(
          json['location'] as Map<String, dynamic>? ?? {}),
      attachedFiles: (json['attached_files'] as List?)
              ?.map((e) => AttachedFile.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      requestLogs: (json['request_logs'] as List?)
              ?.map((e) => RequestLog.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      flaggedReports: (json['flagged_reports'] as List?)
              ?.map((e) => FlaggedReport.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      status: json['status']?.toString() ?? 'pending',
      createdAt: json['created_at']?.toString(),
      updatedAt: json['updated_at']?.toString(),
    );
  }

  String get timeAgo {
    if (createdAt == null) return 'Recently';
    try {
      final dateTime = DateTime.parse(createdAt!);
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
}

class RequestedUser {
  final String name;
  final String phone;

  RequestedUser({required this.name, required this.phone});

  factory RequestedUser.fromJson(Map<String, dynamic> json) {
    return RequestedUser(
      name: json['name']?.toString() ?? 'Unknown',
      phone: json['phone']?.toString() ?? 'N/A',
    );
  }
}

class RequestLocation {
  final double? latitude;
  final double? longitude;
  final String? name;

  RequestLocation({this.latitude, this.longitude, this.name});

  factory RequestLocation.fromJson(Map<String, dynamic> json) {
    return RequestLocation(
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      name: json['name']?.toString(),
    );
  }

  String get coordinatesText {
    if (latitude != null && longitude != null) {
      return '${latitude!.toStringAsFixed(6)}, ${longitude!.toStringAsFixed(6)}';
    }
    return 'N/A';
  }
}

class AttachedFile {
  final int id;
  final String url;
  final String uploadedAt;

  AttachedFile({
    required this.id,
    required this.url,
    required this.uploadedAt,
  });

  factory AttachedFile.fromJson(Map<String, dynamic> json) {
    return AttachedFile(
      id: json['id'] as int,
      url: json['url']?.toString() ?? '',
      uploadedAt: json['uploaded_at']?.toString() ?? '',
    );
  }

  bool get isVideo {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.mp4') ||
        lowerUrl.endsWith('.mov') ||
        lowerUrl.endsWith('.avi') ||
        lowerUrl.contains('video');
  }

  bool get isImage {
    final lowerUrl = url.toLowerCase();
    return lowerUrl.endsWith('.jpg') ||
        lowerUrl.endsWith('.jpeg') ||
        lowerUrl.endsWith('.png') ||
        lowerUrl.endsWith('.gif') ||
        lowerUrl.contains('image');
  }
}

class RequestLog {
  final int id;
  final String performedBy;
  final String action;
  final String? note;
  final String performedAt;

  RequestLog({
    required this.id,
    required this.performedBy,
    required this.action,
    this.note,
    required this.performedAt,
  });

  factory RequestLog.fromJson(Map<String, dynamic> json) {
    return RequestLog(
      id: json['id'] as int,
      performedBy: json['performed_by']?.toString() ?? 'System',
      action: json['action']?.toString() ?? '',
      note: json['note']?.toString(),
      performedAt: json['performed_at']?.toString() ?? '',
    );
  }

  String get timeAgo {
    try {
      final dateTime = DateTime.parse(performedAt);
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
}

class FlaggedReport {
  final int id;
  final int reportedUserId;

  FlaggedReport({
    required this.id,
    required this.reportedUserId,
  });

  factory FlaggedReport.fromJson(Map<String, dynamic> json) {
    return FlaggedReport(
      id: json['id'] as int,
      reportedUserId: json['reported_user_id'] as int,
    );
  }
}

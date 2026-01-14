import 'package:RescueNetApp/core/api/api_service.dart';
import 'package:RescueNetApp/core/api/api_config.dart';
import 'package:RescueNetApp/core/api/api_response.dart';

class NotificationItem {
  final int id;
  final String type;
  final String message;
  final bool isRead;
  final DateTime createdAt;
  final Map<String, dynamic>? data;

  NotificationItem({
    required this.id,
    required this.type,
    required this.message,
    required this.isRead,
    required this.createdAt,
    this.data,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      type: json['type'] ?? '',
      message: json['message'] ?? '',
      isRead: json['is_read'] == 1 || json['is_read'] == true,
      createdAt: DateTime.parse(json['created_at']),
      data: json['data'],
    );
  }

  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class NotificationService {
  final ApiService _apiService = ApiService();

  // Fetch all notifications with pagination
  Future<ApiResponse<Map<String, dynamic>>> getNotifications({
    bool? isRead,
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      String endpoint =
          '${ApiConfig.notifications}?page=$page&per_page=$perPage';

      if (isRead != null) {
        endpoint += '&is_read=${isRead ? 'true' : 'false'}';
      }

      final response = await _apiService.get<Map<String, dynamic>>(
        endpoint,
        parser: (data) => data as Map<String, dynamic>,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to fetch notifications: $e');
    }
  }

  // Get unread notification count
  Future<ApiResponse<int>> getUnreadCount() async {
    try {
      final response = await _apiService.get<int>(
        '${ApiConfig.notifications}/unread-count',
        parser: (data) {
          if (data is Map<String, dynamic> &&
              data.containsKey('unread_count')) {
            return data['unread_count'] as int;
          }
          return 0;
        },
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to fetch unread count: $e');
    }
  }

  // Mark notification as read
  Future<ApiResponse<NotificationItem>> markAsRead(int notificationId) async {
    try {
      final response = await _apiService.post<NotificationItem>(
        '${ApiConfig.notifications}/$notificationId/mark-read',
        parser: (data) =>
            NotificationItem.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to mark notification as read: $e');
    }
  }

  // Mark all notifications as read
  Future<ApiResponse<void>> markAllAsRead() async {
    try {
      final response = await _apiService.post<void>(
        '${ApiConfig.notifications}/mark-all-read',
        parser: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to mark all as read: $e');
    }
  }

  // Delete notification
  Future<ApiResponse<void>> deleteNotification(int notificationId) async {
    try {
      final response = await _apiService.delete<void>(
        '${ApiConfig.notifications}/$notificationId',
        parser: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to delete notification: $e');
    }
  }

  // Delete all notifications
  Future<ApiResponse<void>> deleteAllNotifications() async {
    try {
      final response = await _apiService.delete<void>(
        '${ApiConfig.notifications}/delete-all',
        parser: (_) => null,
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to delete all notifications: $e');
    }
  }
}

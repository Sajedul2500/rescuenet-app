import 'package:dio/dio.dart';
import '../core/api/api_config.dart';
import '../core/api/api_response.dart';
import '../core/api/api_service.dart';

/// User Profile Service
/// Handles user profile-related API calls
class UserProfileService {
  final ApiService _apiService;

  UserProfileService({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// Get user profile
  Future<ApiResponse<UserProfile>> getProfile() async {
    final response = await _apiService.get<UserProfile>(
      ApiConfig.profile,
      parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Update user profile
  Future<ApiResponse<UserProfile>> updateProfile({
    required String name,
    String? email,
    String? phone,
    String? username,
  }) async {
    final response = await _apiService.put<UserProfile>(
      ApiConfig.profile,
      data: {
        'name': name,
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        if (username != null && username.isNotEmpty) 'username': username,
      },
      parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
    );

    return response;
  }

  /// Update password
  Future<ApiResponse<void>> updatePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    final response = await _apiService.put<void>(
      ApiConfig.updatePassword,
      data: {
        'current_password': currentPassword,
        'new_password': newPassword,
        'new_password_confirmation': newPasswordConfirmation,
      },
    );

    return response;
  }

  /// Verify profile with NID images
  Future<ApiResponse<UserProfile>> verifyProfile({
    required String nidFrontImagePath,
    required String selfieWithNidImagePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'nid_front_image': await MultipartFile.fromFile(
          nidFrontImagePath,
          filename: 'nid_front_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
        'selfie_with_nid_image': await MultipartFile.fromFile(
          selfieWithNidImagePath,
          filename: 'selfie_nid_${DateTime.now().millisecondsSinceEpoch}.jpg',
        ),
      });

      final response = await _apiService.postMultipart<UserProfile>(
        ApiConfig.verifyProfile,
        data: formData,
        parser: (data) => UserProfile.fromJson(data as Map<String, dynamic>),
      );

      return response;
    } catch (e) {
      return ApiResponse.error('Failed to upload images: $e');
    }
  }
}

/// User Profile Model
class UserProfile {
  final int id;
  final bool isVerified;
  final String name;
  final String? email;
  final String? phone;
  final String? username;
  final String? profilePicture;

  UserProfile({
    required this.id,
    required this.isVerified,
    required this.name,
    this.email,
    this.phone,
    this.username,
    this.profilePicture,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: json['id'] as int? ?? 0,
      isVerified: json['is_verified'] as bool? ?? false,
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
      profilePicture: json['profile_picture']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'is_verified': isVerified,
      'name': name,
      'email': email,
      'phone': phone,
      'username': username,
      'profile_picture': profilePicture,
    };
  }
}

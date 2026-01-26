import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/auth_storage.dart';

/// Authentication Service
/// Handles login, logout, and authentication-related API calls
class AuthService {
  final ApiService _apiService;
  final AuthStorage _authStorage;

  AuthService({
    ApiService? apiService,
    AuthStorage? authStorage,
  })  : _apiService = apiService ?? ApiService(),
        _authStorage = authStorage ?? AuthStorage();

  /// Login with email, phone, or username
  Future<ApiResponse<LoginResponse>> login({
    required String loginId,
    required String password,
  }) async {
    final response = await _apiService.post<LoginResponse>(
      ApiConfig.login,
      data: {
        'loginId': loginId,
        'password': password,
      },
      parser: (data) => LoginResponse.fromJson(data as Map<String, dynamic>),
    );

    // Save token and user info on success
    if (response.success && response.data != null) {
      await _authStorage.saveToken(response.data!.token);
      await _authStorage.saveUserId(response.data!.user.id.toString());
      await _authStorage.markRegistrationComplete();
    }

    return response;
  }

  /// Logout current user
  Future<ApiResponse<Map<String, dynamic>>> logout() async {
    final response = await _apiService.post(
      ApiConfig.logout,
      data: {},
      parser: (data) => data as Map<String, dynamic>,
    );

    // Clear local auth data regardless of API response
    await _authStorage.clearAuth();

    return response;
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    return await _authStorage.isAuthenticated();
  }
}

/// Login Response Model
class LoginResponse {
  final String message;
  final UserData user;
  final String token;
  final bool hasLocationInfo;

  LoginResponse({
    required this.message,
    required this.user,
    required this.token,
    required this.hasLocationInfo,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) {
    return LoginResponse(
      message: json['message']?.toString() ?? '',
      user: UserData.fromJson(json['user'] as Map<String, dynamic>),
      token: json['token']?.toString() ?? '',
      hasLocationInfo: json['hasLocationInfo'] as bool? ?? true,
    );
  }
}

/// User Data Model
class UserData {
  final int id;
  final String name;
  final String? email;
  final String? phone;
  final String? username;

  UserData({
    required this.id,
    required this.name,
    this.email,
    this.phone,
    this.username,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? 'User',
      email: json['email']?.toString(),
      phone: json['phone']?.toString(),
      username: json['username']?.toString(),
    );
  }
}

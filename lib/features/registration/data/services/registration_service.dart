import 'package:dio/dio.dart';
import '../../../../core/api/api_config.dart';
import '../../../../core/api/api_response.dart';
import '../../../../core/api/api_service.dart';
import '../../../../core/storage/auth_storage.dart';
import '../../domain/models/registration_models.dart';

/// Registration Service
/// Handles all registration-related API calls and state management
class RegistrationService {
  final ApiService _apiService;
  final AuthStorage _authStorage;

  RegistrationService({
    ApiService? apiService,
    AuthStorage? authStorage,
  })  : _apiService = apiService ?? ApiService(),
        _authStorage = authStorage ?? AuthStorage();

  /// Get current registration status from backend
  /// This is the SINGLE SOURCE OF TRUTH
  Future<ApiResponse<RegistrationStatus>> getRegistrationStatus() async {
    return await _apiService.get(
      ApiConfig.registerStatus,
      parser: (data) =>
          RegistrationStatus.fromJson(data as Map<String, dynamic>),
    );
  }

  /// Submit Step 1: Basic registration
  Future<ApiResponse<Step1Response>> submitStep1(Step1Data data) async {
    final response = await _apiService.post<Step1Response>(
      ApiConfig.registerStep1,
      data: data.toJson(),
      parser: (data) => Step1Response.fromJson(data as Map<String, dynamic>),
    );

    // Save auth_token, registration_token, and user_id on success
    if (response.success && response.data != null) {
      await _authStorage.saveToken(response.data!.authToken);
      await _authStorage
          .saveRegistrationToken(response.data!.registrationToken);
      await _authStorage.saveUserId(response.data!.userId);
    }

    return response;
  }

  /// Submit Step 2: Identity verification (optional)
  Future<ApiResponse<Map<String, dynamic>>> submitStep2(Step2Data data) async {
    // Get user_id and registration_token from storage
    final userId = await _authStorage.getUserId();
    final token = await _authStorage.getRegistrationToken();

    // Create FormData for file upload
    final formData = FormData.fromMap({
      'user_id': userId,
      'registration_token': token,
    });

    // Add files if they exist
    if (data.nidFrontImage != null) {
      formData.files.add(MapEntry(
        'nid_front_image',
        await MultipartFile.fromFile(
          data.nidFrontImage.path,
          filename: data.nidFrontImage.path.split('/').last,
        ),
      ));
    }

    if (data.nidBackImage != null) {
      formData.files.add(MapEntry(
        'nid_back_image',
        await MultipartFile.fromFile(
          data.nidBackImage.path,
          filename: data.nidBackImage.path.split('/').last,
        ),
      ));
    }

    if (data.selfieWithNidImage != null) {
      formData.files.add(MapEntry(
        'selfie_with_nid_image',
        await MultipartFile.fromFile(
          data.selfieWithNidImage.path,
          filename: data.selfieWithNidImage.path.split('/').last,
        ),
      ));
    }

    return await _apiService.post(
      ApiConfig.registerStep2,
      data: formData,
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Skip Step 2: Identity verification
  Future<ApiResponse<Map<String, dynamic>>> skipStep2() async {
    // Get user_id and registration_token from storage
    final userId = await _authStorage.getUserId();
    final token = await _authStorage.getRegistrationToken();

    return await _apiService.post(
      ApiConfig.registerSkipStep2,
      data: {
        'user_id': userId,
        'registration_token': token,
      },
      parser: (data) => data as Map<String, dynamic>,
    );
  }

  /// Submit Step 3: Emergency contact and location
  Future<ApiResponse<Map<String, dynamic>>> submitStep3(Step3Data data) async {
    // Get user_id and registration_token from storage
    final userId = await _authStorage.getUserId();
    final token = await _authStorage.getRegistrationToken();

    // Merge with step3 data
    final payload = {
      'user_id': userId,
      'registration_token': token,
      ...data.toJson(),
    };

    final response = await _apiService.post(
      ApiConfig.registerStep3,
      data: payload,
      parser: (data) => data as Map<String, dynamic>,
    );

    // Mark registration as complete on success
    if (response.success) {
      await _authStorage.markRegistrationComplete();
    }

    return response;
  }

  /// Check if user has an active token
  Future<bool> hasToken() async {
    return await _authStorage.isAuthenticated();
  }

  /// Check if registration is complete (local cache)
  Future<bool> isRegistrationComplete() async {
    return await _authStorage.isRegistrationComplete();
  }

  /// Logout - clear all auth data
  Future<void> logout() async {
    await _authStorage.clearAuth();
  }
}

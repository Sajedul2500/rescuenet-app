import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Secure storage for authentication data
/// Uses flutter_secure_storage for token security
class AuthStorage {
  static const String _keyToken = 'auth_token';
  static const String _keyRegistrationToken = 'registration_token';
  static const String _keyUserId = 'user_id';
  static const String _keyRegistrationComplete = 'registration_complete';

  final FlutterSecureStorage _storage;

  AuthStorage({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    return await _storage.read(key: _keyToken);
  }

  /// Save registration token (used for multi-step registration)
  Future<void> saveRegistrationToken(String token) async {
    await _storage.write(key: _keyRegistrationToken, value: token);
  }

  /// Get registration token
  Future<String?> getRegistrationToken() async {
    return await _storage.read(key: _keyRegistrationToken);
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _storage.write(key: _keyUserId, value: userId);
  }

  /// Get user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: _keyUserId);
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  /// Mark registration as complete
  Future<void> markRegistrationComplete() async {
    await _storage.write(key: _keyRegistrationComplete, value: 'true');
  }

  /// Check if registration is complete
  Future<bool> isRegistrationComplete() async {
    final value = await _storage.read(key: _keyRegistrationComplete);
    return value == 'true';
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    await _storage.delete(key: _keyToken);
    await _storage.delete(key: _keyRegistrationToken);
    await _storage.delete(key: _keyUserId);
    await _storage.delete(key: _keyRegistrationComplete);
  }

  /// Clear only registration status (keep token for resume)
  Future<void> clearRegistrationStatus() async {
    await _storage.delete(key: _keyRegistrationComplete);
  }
}

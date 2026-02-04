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
      : _storage = storage ??
            const FlutterSecureStorage(
              aOptions: AndroidOptions(
                encryptedSharedPreferences: true,
                resetOnError: true,
              ),
            );

  /// Save authentication token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _keyToken, value: token);
  }

  /// Get authentication token
  Future<String?> getToken() async {
    try {
      return await _storage.read(key: _keyToken);
    } catch (e) {
      // Handle decryption errors by clearing corrupted data
      print('Error reading token from secure storage: $e');
      await _handleStorageError();
      return null;
    }
  }

  /// Save registration token (used for multi-step registration)
  Future<void> saveRegistrationToken(String token) async {
    try {
      await _storage.write(key: _keyRegistrationToken, value: token);
    } catch (e) {
      print('Error saving registration token: $e');
      await _handleStorageError();
      rethrow;
    }
  }

  /// Get registration token
  Future<String?> getRegistrationToken() async {
    try {
      return await _storage.read(key: _keyRegistrationToken);
    } catch (e) {
      print('Error reading registration token: $e');
      await _handleStorageError();
      return null;
    }
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    try {
      await _storage.write(key: _keyUserId, value: userId);
    } catch (e) {
      print('Error saving user ID: $e');
      await _handleStorageError();
      rethrow;
    }
  }

  /// Get user ID
  Future<String?> getUserId() async {
    try {
      return await _storage.read(key: _keyUserId);
    } catch (e) {
      print('Error reading user ID: $e');
      await _handleStorageError();
      return null;
    }
  }

  /// Check if user is authenticated
  Future<bool> isAuthenticated() async {
    try {
      final token = await getToken();
      return token != null && token.isNotEmpty;
    } catch (e) {
      print('Error checking authentication: $e');
      return false;
    }
  }

  /// Mark registration as complete
  Future<void> markRegistrationComplete() async {
    try {
      await _storage.write(key: _keyRegistrationComplete, value: 'true');
    } catch (e) {
      print('Error marking registration complete: $e');
      await _handleStorageError();
      rethrow;
    }
  }

  /// Check if registration is complete
  Future<bool> isRegistrationComplete() async {
    try {
      final value = await _storage.read(key: _keyRegistrationComplete);
      return value == 'true';
    } catch (e) {
      print('Error checking registration status: $e');
      await _handleStorageError();
      return false;
    }
  }

  /// Clear all authentication data
  Future<void> clearAuth() async {
    try {
      await _storage.delete(key: _keyToken);
      await _storage.delete(key: _keyRegistrationToken);
      await _storage.delete(key: _keyUserId);
      await _storage.delete(key: _keyRegistrationComplete);
    } catch (e) {
      print('Error clearing auth data: $e');
      // If delete fails, try to delete all
      await _handleStorageError();
    }
  }

  /// Clear only registration status (keep token for resume)
  Future<void> clearRegistrationStatus() async {
    try {
      await _storage.delete(key: _keyRegistrationComplete);
    } catch (e) {
      print('Error clearing registration status: $e');
      await _handleStorageError();
    }
  }

  /// Handle storage errors by clearing all data
  Future<void> _handleStorageError() async {
    try {
      await _storage.deleteAll();
      print('Cleared all secure storage due to error');
    } catch (e) {
      print('Failed to clear secure storage: $e');
    }
  }
}

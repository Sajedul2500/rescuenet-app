import 'package:shared_preferences/shared_preferences.dart';

/// Service responsible for managing onboarding state.
/// Determines whether the user has completed the welcome flow.
class OnboardingService {
  static const String _onboardingKey = 'isOnboardingCompleted';

  /// Checks if the user has completed onboarding.
  /// Returns false on first install or if data is cleared.
  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_onboardingKey) ?? false;
    } catch (e) {
      // If any error occurs, assume onboarding not completed
      return false;
    }
  }

  /// Marks onboarding as completed.
  /// Call this after user finishes the welcome flow.
  Future<void> markOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_onboardingKey, true);
    } catch (e) {
      throw Exception('Failed to save onboarding state: $e');
    }
  }

  /// Resets onboarding state (useful for testing/debugging).
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_onboardingKey);
    } catch (e) {
      throw Exception('Failed to reset onboarding state: $e');
    }
  }

  /// Checks if this is the first time the app is launched.
  /// Useful for distinguishing between fresh install vs cache cleared.
  Future<bool> isFirstLaunch() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return !prefs.containsKey(_onboardingKey);
    } catch (e) {
      return true;
    }
  }
}

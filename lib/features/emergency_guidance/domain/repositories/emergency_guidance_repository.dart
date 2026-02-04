import '../entities/emergency_guidance.dart';

/// Repository interface for emergency guidance data.
/// Provides offline-first access to emergency instructions.
abstract class EmergencyGuidanceRepository {
  /// Get all available emergency guidance categories
  Future<List<EmergencyGuidance>> getAllGuidance({String languageCode});

  /// Get guidance by category
  Future<EmergencyGuidance?> getGuidanceByCategory(
    String category, {
    String languageCode,
  });

  /// Search guidance by keywords
  Future<List<EmergencyGuidance>> searchGuidance(
    String query, {
    String languageCode,
  });

  /// Check if offline data is available
  Future<bool> isOfflineDataAvailable();
}

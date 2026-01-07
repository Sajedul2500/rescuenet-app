import '../entities/emergency_guidance.dart';

/// Repository interface for emergency guidance data.
/// Provides offline-first access to emergency instructions.
abstract class EmergencyGuidanceRepository {
  /// Get all available emergency guidance categories
  Future<List<EmergencyGuidance>> getAllGuidance();

  /// Get guidance by category
  Future<EmergencyGuidance?> getGuidanceByCategory(String category);

  /// Search guidance by keywords
  Future<List<EmergencyGuidance>> searchGuidance(String query);

  /// Check if offline data is available
  Future<bool> isOfflineDataAvailable();
}

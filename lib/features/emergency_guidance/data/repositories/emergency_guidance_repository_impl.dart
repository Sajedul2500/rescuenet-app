import '../../domain/entities/emergency_guidance.dart';
import '../../domain/repositories/emergency_guidance_repository.dart';
import '../datasources/offline_guidance_datasource.dart';

/// Implementation of emergency guidance repository.
/// Uses offline datasource for guaranteed availability.
class EmergencyGuidanceRepositoryImpl implements EmergencyGuidanceRepository {
  final OfflineGuidanceDataSource _offlineDataSource;

  EmergencyGuidanceRepositoryImpl({
    OfflineGuidanceDataSource? offlineDataSource,
  }) : _offlineDataSource = offlineDataSource ?? OfflineGuidanceDataSource();

  @override
  Future<List<EmergencyGuidance>> getAllGuidance() async {
    try {
      return await _offlineDataSource.getAllGuidance();
    } catch (e) {
      throw Exception('Failed to load emergency guidance: $e');
    }
  }

  @override
  Future<EmergencyGuidance?> getGuidanceByCategory(String category) async {
    try {
      return await _offlineDataSource.getGuidanceByCategory(category);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<List<EmergencyGuidance>> searchGuidance(String query) async {
    try {
      if (query.trim().isEmpty) {
        return await getAllGuidance();
      }
      return await _offlineDataSource.searchGuidance(query);
    } catch (e) {
      return [];
    }
  }

  @override
  Future<bool> isOfflineDataAvailable() async {
    // Always true since we use embedded data
    return true;
  }
}

import 'package:flutter/foundation.dart';
import '../../domain/entities/emergency_guidance.dart';
import '../../domain/repositories/emergency_guidance_repository.dart';

/// ViewModel for emergency guidance list.
/// Manages state for guidance categories and search.
class EmergencyGuidanceViewModel extends ChangeNotifier {
  final EmergencyGuidanceRepository _repository;

  List<EmergencyGuidance> _allGuidance = [];
  List<EmergencyGuidance> _filteredGuidance = [];
  bool _isLoading = false;
  String? _errorMessage;
  String _searchQuery = '';
  String _currentLanguageCode = 'en';

  EmergencyGuidanceViewModel(this._repository);

  // Getters
  List<EmergencyGuidance> get guidance => _filteredGuidance;
  bool get isLoading => _isLoading;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => !_isLoading && _filteredGuidance.isEmpty;
  String get searchQuery => _searchQuery;

  /// Load all emergency guidance with language support
  Future<void> loadGuidance({String languageCode = 'en'}) async {
    _currentLanguageCode = languageCode;
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _allGuidance =
          await _repository.getAllGuidance(languageCode: languageCode);
      _filteredGuidance = List.from(_allGuidance);
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load guidance. Please try again.';
      notifyListeners();
    }
  }

  /// Search guidance by query with language support
  Future<void> searchGuidance(String query) async {
    _searchQuery = query;

    if (query.trim().isEmpty) {
      _filteredGuidance = List.from(_allGuidance);
      notifyListeners();
      return;
    }

    try {
      _filteredGuidance = await _repository.searchGuidance(
        query,
        languageCode: _currentLanguageCode,
      );
      notifyListeners();
    } catch (e) {
      // Keep current results on search error
      notifyListeners();
    }
  }

  /// Clear search
  void clearSearch() {
    _searchQuery = '';
    _filteredGuidance = List.from(_allGuidance);
    notifyListeners();
  }

  /// Retry loading
  Future<void> retry() async {
    await loadGuidance();
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/dashboard_header_state.dart';
import '../../domain/services/connectivity_service.dart';

/// ViewModel for dashboard header.
/// Manages header state and determines priority message to display.
class DashboardHeaderViewModel extends ChangeNotifier {
  final ConnectivityService _connectivityService;

  DashboardHeaderState _state = DashboardHeaderState.initial();
  HeaderMessage _currentMessage = HeaderMessage.none();
  StreamSubscription<bool>? _connectivitySubscription;

  DashboardHeaderViewModel({
    ConnectivityService? connectivityService,
  }) : _connectivityService = connectivityService ?? ConnectivityService() {
    _initialize();
  }

  // Getters
  DashboardHeaderState get state => _state;
  HeaderMessage get currentMessage => _currentMessage;

  /// Initialize the view model
  Future<void> _initialize() async {
    await _connectivityService.initialize();
    await _loadUserState();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivityService.connectivityStream.listen(
      (isOffline) {
        _state = _state.copyWith(isOffline: isOffline);
        _updateMessage();
      },
    );
  }

  /// Load user state from SharedPreferences
  Future<void> _loadUserState() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // TODO: Check from backend - for now always false until backend integration
      final isVerified = false; // prefs.getBool('isIdentityVerified') ?? false;
      final hasContact = prefs.getBool('hasEmergencyContact') ?? false;
      final userName = prefs.getString('userName');
      final userPhoto = prefs.getString('userPhotoUrl');

      _state = DashboardHeaderState(
        isIdentityVerified: isVerified,
        hasEmergencyContact: hasContact,
        isOffline: _connectivityService.isOffline,
        userName: userName,
        userPhotoUrl: userPhoto,
      );

      _updateMessage();
    } catch (e) {
      // Use default state on error
      _updateMessage();
    }
  }

  /// Update message based on priority logic
  void _updateMessage() {
    // Priority 1: Identity verification
    if (!_state.isIdentityVerified) {
      _currentMessage = HeaderMessage.verifyIdentity(_onVerifyIdentityTapped);
    }
    // Priority 2: Emergency contact
    else if (!_state.hasEmergencyContact) {
      _currentMessage = HeaderMessage.addEmergencyContact(_onAddContactTapped);
    }
    // Priority 3: Offline mode
    else if (_state.isOffline) {
      _currentMessage = HeaderMessage.offline();
    }
    // All ready
    else {
      _currentMessage = HeaderMessage.ready();
    }

    notifyListeners();
  }

  /// Callbacks for user actions (to be implemented by parent widget)
  VoidCallback? onVerifyIdentity;
  VoidCallback? onAddEmergencyContact;

  void _onVerifyIdentityTapped() {
    onVerifyIdentity?.call();
  }

  void _onAddContactTapped() {
    onAddEmergencyContact?.call();
  }

  /// Manually refresh state (e.g., after user adds contact)
  Future<void> refresh() async {
    await _loadUserState();
    await _connectivityService.refresh();
  }

  /// Update identity verification status
  Future<void> updateIdentityVerification(bool isVerified) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('isIdentityVerified', isVerified);
      _state = _state.copyWith(isIdentityVerified: isVerified);
      _updateMessage();
    } catch (e) {
      // Handle error silently
    }
  }

  /// Update emergency contact status
  Future<void> updateEmergencyContactStatus(bool hasContact) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasEmergencyContact', hasContact);
      _state = _state.copyWith(hasEmergencyContact: hasContact);
      _updateMessage();
    } catch (e) {
      // Handle error silently
    }
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}

import 'package:flutter/material.dart';
import 'features/onboarding/domain/onboarding_service.dart';
import 'pages/WelcomePage.dart';
import 'core/guards/registration_guard.dart';
import 'core/storage/auth_storage.dart';

/// Handles app startup routing logic.
/// Decides initial route based on onboarding and authentication state.
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  final OnboardingService _onboardingService = OnboardingService();
  final AuthStorage _authStorage = AuthStorage();
  bool _isLoading = true;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _determineStartupRoute();
  }

  /// Determines which screen to show on app startup.
  /// Priority: Authentication > Onboarding > Welcome
  Future<void> _determineStartupRoute() async {
    try {
      // First, check if user is authenticated
      final isAuthenticated = await _authStorage.isAuthenticated();

      if (isAuthenticated) {
        // User has token, let RegistrationGuard handle routing
        if (mounted) {
          setState(() {
            _showWelcome = false;
            _isLoading = false;
          });
        }
        return;
      }

      // No authentication, check onboarding state
      final isOnboardingCompleted =
          await _onboardingService.isOnboardingCompleted();

      if (mounted) {
        setState(() {
          _showWelcome = !isOnboardingCompleted;
          _isLoading = false;
        });
      }
    } catch (e) {
      // On error, show welcome page (fail-safe)
      if (mounted) {
        setState(() {
          _showWelcome = true;
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0D47A1),
        body: Center(
          child: CircularProgressIndicator(
            color: Colors.white,
          ),
        ),
      );
    }

    // Navigate to appropriate screen:
    // - WelcomePage: if onboarding not completed
    // - RegistrationGuard: if user has auth token (handles registration flow)
    return _showWelcome ? const WelcomePage() : const RegistrationGuard();
  }
}

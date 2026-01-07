import 'package:flutter/material.dart';
import 'features/onboarding/domain/onboarding_service.dart';
import 'pages/WelcomePage.dart';
import 'pages/LoginPage.dart';

/// Handles app startup routing logic.
/// Decides initial route based on onboarding state.
class AppStartup extends StatefulWidget {
  const AppStartup({super.key});

  @override
  State<AppStartup> createState() => _AppStartupState();
}

class _AppStartupState extends State<AppStartup> {
  final OnboardingService _onboardingService = OnboardingService();
  bool _isLoading = true;
  bool _showWelcome = false;

  @override
  void initState() {
    super.initState();
    _determineStartupRoute();
  }

  /// Determines which screen to show on app startup.
  /// This is where the routing decision happens - NOT in the Welcome Page.
  Future<void> _determineStartupRoute() async {
    try {
      // Check if onboarding is completed
      final isCompleted = await _onboardingService.isOnboardingCompleted();

      if (mounted) {
        setState(() {
          _showWelcome = !isCompleted;
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

    // Navigate to appropriate screen based on onboarding state
    return _showWelcome ? const WelcomePage() : const LoginPage();
  }
}

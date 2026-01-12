import 'package:flutter/material.dart';
import '../../features/registration/data/services/registration_service.dart';
import '../../features/registration/domain/models/registration_models.dart';
import '../../pages/WelcomePage.dart';
import '../../pages/RegistrationStep1Page.dart';
import '../../pages/RegistrationStep2Page.dart';
import '../../pages/RegistrationStep3Page.dart';
import '../../pages/UserDashboardPage.dart';

/// Registration Guard
/// Determines where to navigate on app startup based on backend status
class RegistrationGuard extends StatefulWidget {
  const RegistrationGuard({super.key});

  @override
  State<RegistrationGuard> createState() => _RegistrationGuardState();
}

class _RegistrationGuardState extends State<RegistrationGuard> {
  final RegistrationService _registrationService = RegistrationService();
  bool _isLoading = true;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _checkRegistrationStatus();
  }

  Future<void> _checkRegistrationStatus() async {
    try {
      // Check if user has token
      final hasToken = await _registrationService.hasToken();

      if (!hasToken) {
        // No token = new user → Welcome Page
        _navigateToWelcome();
        return;
      }

      // Check local registration status first
      final isRegistrationComplete =
          await _registrationService.isRegistrationComplete();

      if (isRegistrationComplete) {
        // Registration already complete, go straight to dashboard
        _navigateBasedOnStep(RegistrationStep.completed);
        return;
      }

      // Registration incomplete → Check backend status (SINGLE SOURCE OF TRUTH)
      final response = await _registrationService.getRegistrationStatus();

      if (!response.success) {
        // API error or 401 → Go to welcome
        if (response.statusCode == 401) {
          await _registrationService.logout();
          _navigateToWelcome();
          return;
        }

        // Other error → Show error and retry
        setState(() {
          _errorMessage =
              response.message ?? 'Failed to check registration status';
          _isLoading = false;
        });
        return;
      }

      // Navigate based on backend step
      final status = response.data!;
      _navigateBasedOnStep(status.step);
    } catch (e) {
      setState(() {
        _errorMessage = 'Unexpected error: $e';
        _isLoading = false;
      });
    }
  }

  void _navigateBasedOnStep(RegistrationStep step) {
    Widget destination;

    switch (step) {
      case RegistrationStep.step1:
        destination = const RegistrationStep1Page();
        break;
      case RegistrationStep.step2:
        destination = RegistrationStep2Page(registrationData: const {});
        break;
      case RegistrationStep.step3:
        destination = RegistrationStep3Page(registrationData: const {});
        break;
      case RegistrationStep.completed:
        destination = const UserDashboardPage();
        break;
    }

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => destination),
      );
    }
  }

  void _navigateToWelcome() {
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const WelcomePage()),
      );
    }
  }

  void _retry() {
    setState(() {
      _isLoading = true;
      _errorMessage = '';
    });
    _checkRegistrationStatus();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Color(0xFFD32F2F)),
              ),
              SizedBox(height: 16),
              Text(
                'Loading...',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    // Show error with retry option
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                _errorMessage,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _retry,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () async {
                  await _registrationService.logout();
                  _navigateToWelcome();
                },
                child: const Text('Start Fresh'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

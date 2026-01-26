import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:async';
import 'dart:io';
import '../../features/emergency_guidance/presentation/screens/emergency_guidance_list_screen.dart';
import '../storage/auth_storage.dart';
import '../guards/registration_guard.dart';
import '../../pages/LoginPage.dart';

/// Connectivity Wrapper
///
/// Handles app-wide connectivity state management:
///
/// **OFFLINE MODE:**
/// - Shows emergency guidance screen with offline banner
/// - Provides access to critical emergency information without internet
///
/// **ONLINE MODE:**
/// - Shows normal app flow (RegistrationGuard → Dashboard/Login)
///
/// **TRANSITION (Offline → Online):**
/// - Displays "Back Online" dialog
/// - Checks authentication status
/// - If authenticated: Redirects to RegistrationGuard (then Dashboard)
/// - If not authenticated: Redirects to LoginPage
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({
    super.key,
    required this.child,
  });

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  final Connectivity _connectivity = Connectivity();
  final AuthStorage _authStorage = AuthStorage();
  late StreamSubscription<List<ConnectivityResult>> _connectivitySubscription;
  bool _isOnline = true;
  bool _isCheckingConnectivity = true;
  bool _hasShownOnlineDialog = false;

  @override
  void initState() {
    super.initState();
    _initConnectivity();
    _setupConnectivityListener();
  }

  @override
  void dispose() {
    _connectivitySubscription.cancel();
    super.dispose();
  }

  /// Initialize connectivity check with actual internet verification
  Future<void> _initConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final hasConnectivity = _checkIfConnected(results);

      // If we have connectivity type, verify actual internet access
      bool actuallyOnline = false;
      if (hasConnectivity) {
        actuallyOnline = await _verifyInternetAccess();
      }

      print('🌐 Initial connectivity check:');
      print('   Connectivity type: $results');
      print('   Has connectivity: $hasConnectivity');
      print('   Actual internet: $actuallyOnline');

      if (mounted) {
        setState(() {
          _isOnline = actuallyOnline;
          _isCheckingConnectivity = false;
        });
      }
    } catch (e) {
      print('❌ Error checking connectivity: $e');
      // On error, assume online to allow app to proceed
      // The app will show errors if truly offline
      if (mounted) {
        setState(() {
          _isOnline = true;
          _isCheckingConnectivity = false;
        });
      }
    }
  }

  /// Verify actual internet access by attempting to lookup a reliable host
  Future<bool> _verifyInternetAccess() async {
    try {
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } on TimeoutException catch (_) {
      return false;
    } catch (e) {
      print('⚠️ Internet verification error: $e');
      // On unexpected error, assume online
      return true;
    }
  }

  /// Check if device has connectivity type (not actual internet)
  bool _checkIfConnected(List<ConnectivityResult> results) {
    // If list is empty or contains only 'none', device is offline
    if (results.isEmpty ||
        (results.length == 1 && results.first == ConnectivityResult.none)) {
      return false;
    }

    // Check for actual connectivity (wifi, mobile, ethernet, etc.)
    return results.any((result) =>
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.ethernet ||
        result == ConnectivityResult.vpn);
  }

  /// Listen for connectivity changes
  void _setupConnectivityListener() {
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        if (!mounted) return;

        final wasOffline = !_isOnline;
        final hasConnectivity = _checkIfConnected(results);

        // Verify actual internet access
        bool isNowOnline = false;
        if (hasConnectivity) {
          isNowOnline = await _verifyInternetAccess();
        }

        print('🌐 Connectivity changed: $results');
        print('📶 Was offline: $wasOffline, Is now online: $isNowOnline');

        if (!mounted) return;

        setState(() {
          _isOnline = isNowOnline;
        });

        // If transitioned from offline to online, show dialog and redirect
        if (wasOffline && isNowOnline && !_hasShownOnlineDialog) {
          print('✅ Showing online transition dialog');
          _hasShownOnlineDialog = true;
          _handleOnlineTransition();
        } else if (!isNowOnline) {
          // Reset flag when going offline
          print('❌ Going offline');
          _hasShownOnlineDialog = false;
        }
      },
    );
  }

  /// Handle transition from offline to online
  Future<void> _handleOnlineTransition() async {
    if (!mounted) return;

    // Show dialog
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.wifi, color: Colors.green, size: 28),
            const SizedBox(width: 12),
            Text(
              'Back Online',
              style: GoogleFonts.poppins(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ],
        ),
        content: Text(
          'Internet connection restored. Redirecting you to the app...',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
            child: Text(
              'Continue',
              style: GoogleFonts.poppins(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );

    // Check authentication and redirect
    await _redirectBasedOnAuth();
  }

  /// Redirect based on authentication status
  Future<void> _redirectBasedOnAuth() async {
    if (!mounted) return;

    try {
      final isAuthenticated = await _authStorage.isAuthenticated();

      if (isAuthenticated) {
        // User is authenticated, go to registration guard (which handles dashboard routing)
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const RegistrationGuard()),
          (route) => false,
        );
      } else {
        // User not authenticated, go to login
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    } catch (e) {
      // On error, go to login
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (route) => false,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingConnectivity) {
      return Scaffold(
        backgroundColor: Colors.white,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: Color(0xFFD32F2F),
              ),
              const SizedBox(height: 16),
              Text(
                'Checking connection...',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
      );
    }

    // If offline, show emergency guidance
    if (!_isOnline) {
      return Scaffold(
        body: Column(
          children: [
            _buildOfflineBanner(),
            const Expanded(
              child: EmergencyGuidanceListScreen(),
            ),
          ],
        ),
      );
    }

    // If online, show the child widget (normal app flow)
    return widget.child;
  }

  Widget _buildOfflineBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: Colors.orange[700],
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            const Icon(
              Icons.wifi_off,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Offline Mode',
                    style: GoogleFonts.poppins(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    'Emergency guidance available offline',
                    style: GoogleFonts.poppins(
                      color: Colors.white.withOpacity(0.9),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            // Add retry button
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white, size: 20),
              onPressed: () async {
                setState(() {
                  _isCheckingConnectivity = true;
                });
                await _initConnectivity();
              },
              tooltip: 'Retry connection',
            ),
          ],
        ),
      ),
    );
  }
}
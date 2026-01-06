import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RescueNetApp/services/geocoding_service.dart';
import 'UserDashboardPage.dart';

class RegistrationStep3Page extends StatefulWidget {
  final Map<String, dynamic> registrationData;

  const RegistrationStep3Page({super.key, required this.registrationData});

  @override
  State<RegistrationStep3Page> createState() => _RegistrationStep3PageState();
}

class _RegistrationStep3PageState extends State<RegistrationStep3Page>
    with TickerProviderStateMixin {
  bool _isLocationPermissionGranted = false;
  bool _isLoadingLocation = false;
  String? _currentLocation;
  double? _latitude;
  double? _longitude;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.15),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animController,
        curve: Curves.easeIn,
      ),
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(const Duration(milliseconds: 100), () {
      _animController.forward();
    });
  }

  @override
  void dispose() {
    _animController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  Future<void> _requestLocationPermission() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      // Check if location service is enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _isLoadingLocation = false;
        });

        // Show dialog prompting user to enable location service
        if (mounted) {
          _showEnableLocationServiceDialog();
        }
        return;
      }

      // Check current permission status first
      var currentStatus = await Permission.location.status;

      // If already granted, just get the location
      if (currentStatus.isGranted) {
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Fetch place name from OpenStreetMap
          final locationData = await GeocodingService.getPlaceFromCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
          );

          String placeName = 'Location detected';
          if (locationData != null) {
            placeName = GeocodingService.getShortPlaceName(locationData);
          }

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', placeName);
          await prefs.setDouble('latitude', position.latitude);
          await prefs.setDouble('longitude', position.longitude);
          if (locationData != null) {
            await prefs.setString(
                'fullAddress', locationData['address'] ?? placeName);
          }

          setState(() {
            _isLocationPermissionGranted = true;
            _latitude = position.latitude;
            _longitude = position.longitude;
            _currentLocation = placeName;
            _isLoadingLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location access granted',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        } catch (e) {
          // Could not get position, but permission is granted
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', 'Location permission granted');

          setState(() {
            _isLocationPermissionGranted = true;
            _currentLocation = 'Location permission granted';
            _isLoadingLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location access granted',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
          return;
        }
      }

      // If permanently denied, go straight to app settings
      if (currentStatus.isPermanentlyDenied) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          _showOpenAppSettingsDialog();
        }
        return;
      }

      // Request app permission if not already granted
      final status = await Permission.location.request();

      if (status.isGranted) {
        // Permission granted, try to get location
        try {
          Position position = await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          );

          // Fetch place name from OpenStreetMap
          final locationData = await GeocodingService.getPlaceFromCoordinates(
            latitude: position.latitude,
            longitude: position.longitude,
          );

          String placeName = 'Location detected';
          if (locationData != null) {
            placeName = GeocodingService.getShortPlaceName(locationData);
          }

          // Save location permission and data to SharedPreferences
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', placeName);
          await prefs.setDouble('latitude', position.latitude);
          await prefs.setDouble('longitude', position.longitude);
          if (locationData != null) {
            await prefs.setString(
                'fullAddress', locationData['address'] ?? placeName);
          }

          setState(() {
            _isLocationPermissionGranted = true;
            _latitude = position.latitude;
            _longitude = position.longitude;
            _currentLocation = placeName;
            _isLoadingLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location access granted',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        } catch (e) {
          // Could not get position, but permission is granted
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', 'Location permission granted');

          setState(() {
            _isLocationPermissionGranted = true;
            _currentLocation = 'Location permission granted';
            _isLoadingLocation = false;
          });

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location access granted',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      } else if (status.isPermanentlyDenied) {
        setState(() {
          _isLoadingLocation = false;
        });
        if (mounted) {
          _showOpenAppSettingsDialog();
        }
      } else if (status.isDenied) {
        setState(() {
          _isLoadingLocation = false;
        });

        if (mounted) {
          // Check if it became permanently denied
          final recheckStatus = await Permission.location.status;
          if (recheckStatus.isPermanentlyDenied) {
            _showOpenAppSettingsDialog();
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Location permission is required. Please allow when prompted.',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 3),
              ),
            );
          }
        }
      }
    } catch (e) {
      setState(() {
        _isLoadingLocation = false;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showEnableLocationServiceDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.orange, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Enable Location Service',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Location service is turned off on your device.',
              style: GoogleFonts.poppins(fontSize: 14),
            ),
            const SizedBox(height: 12),
            Text(
              'Please enable it in your device settings:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '1. Go to Settings\n2. Open Location\n3. Turn on Location Services',
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await Geolocator.openLocationSettings();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(
              'Open Settings',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showOpenAppSettingsDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Row(
          children: [
            const Icon(Icons.settings, color: Colors.red, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Permission Required',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'Location permission is permanently denied. Please enable it from app settings to continue registration.',
          style: GoogleFonts.poppins(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(color: Colors.grey[600]),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              await openAppSettings();
              Navigator.of(context).pop();
            },
            icon: const Icon(Icons.settings, size: 18),
            label: Text(
              'Open Settings',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
              foregroundColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _completeRegistration() {
    if (!_isLocationPermissionGranted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please allow location access to continue',
            style: GoogleFonts.poppins(),
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Add location data to registration data
    final finalData = {
      ...widget.registrationData,
      'latitude': _latitude,
      'longitude': _longitude,
      'location': _currentLocation,
      'registrationCompleted': true,
      'registrationDate': DateTime.now().toIso8601String(),
    };

    // Show success dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Registration Complete!',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        content: Text(
          'Welcome to RescueNet! Your account has been created successfully.',
          style: GoogleFonts.poppins(fontSize: 14),
          textAlign: TextAlign.center,
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                // Navigate to Dashboard
                Navigator.of(context).pushAndRemoveUntil(
                  PageRouteBuilder(
                    transitionDuration: const Duration(milliseconds: 700),
                    pageBuilder: (_, __, ___) =>
                        UserDashboardPage(userData: finalData),
                    transitionsBuilder: (_, animation, __, child) {
                      return FadeTransition(
                        opacity: animation,
                        child: child,
                      );
                    },
                  ),
                  (route) => false,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'Go to Dashboard',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        centerTitle: true,
        title: Text(
          'Registration - Step 3 of 3',
          style: GoogleFonts.poppins(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        automaticallyImplyLeading: false,
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: SlideTransition(
            position: _slideAnimation,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  'Location Permission',
                  style: GoogleFonts.poppins(
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'This helps us connect you with nearby volunteers',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Location Icon with Animation
                Center(
                  child: ScaleTransition(
                    scale: _pulseAnimation,
                    child: Container(
                      padding: const EdgeInsets.all(32),
                      decoration: BoxDecoration(
                        color: _isLocationPermissionGranted
                            ? Colors.green[50]
                            : Colors.red[50],
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: (_isLocationPermissionGranted
                                    ? Colors.green
                                    : Colors.red)
                                .withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Icon(
                        _isLocationPermissionGranted
                            ? Icons.location_on
                            : Icons.location_off,
                        size: 80,
                        color: _isLocationPermissionGranted
                            ? Colors.green
                            : Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Info Card
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[700]),
                          const SizedBox(width: 8),
                          Text(
                            'Why we need location access?',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.blue[900],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _buildInfoPoint(
                          'Find nearby volunteers during emergencies'),
                      _buildInfoPoint(
                          'Send accurate location in help requests'),
                      _buildInfoPoint('Receive location-based alerts'),
                      _buildInfoPoint('Connect with local rescue teams'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // Current Location Display
                if (_isLocationPermissionGranted && _currentLocation != null)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: Colors.green),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Location Detected',
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.green[900],
                                ),
                              ),
                              Text(
                                _currentLocation!,
                                style: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.green[800],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 32),

                // Allow Location Button
                if (!_isLocationPermissionGranted)
                  ElevatedButton.icon(
                    onPressed:
                        _isLoadingLocation ? null : _requestLocationPermission,
                    icon: _isLoadingLocation
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.location_on),
                    label: Text(
                      _isLoadingLocation
                          ? 'Getting Location...'
                          : 'Allow Location Access',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFD32F2F),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),

                // Complete Registration Button
                if (_isLocationPermissionGranted)
                  ElevatedButton.icon(
                    onPressed: _completeRegistration,
                    icon: const Icon(Icons.check_circle),
                    label: Text(
                      'Complete Registration',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoPoint(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(Icons.check, size: 16, color: Colors.blue[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(
                fontSize: 13,
                color: Colors.blue[900],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

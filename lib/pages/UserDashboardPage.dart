import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RescueNetApp/services/geocoding_service.dart';
import 'package:RescueNetApp/services/weather_service.dart';
import 'package:RescueNetApp/features/dashboard/presentation/widgets/dashboard_bottom_nav.dart';
import 'package:RescueNetApp/features/dashboard/presentation/widgets/dashboard_header.dart';
import 'package:RescueNetApp/features/dashboard/presentation/viewmodels/dashboard_header_viewmodel.dart';
import 'package:RescueNetApp/features/dashboard/data/services/dashboard_service.dart';
import 'package:RescueNetApp/pages/EmergencyContactPage.dart';
import 'package:RescueNetApp/pages/UserProfilePage.dart';
import 'package:RescueNetApp/pages/HelpRequestDetailsPage.dart';

class UserDashboardPage extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const UserDashboardPage({super.key, this.userData});

  @override
  State<UserDashboardPage> createState() => _UserDashboardPageState();
}

class _UserDashboardPageState extends State<UserDashboardPage>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final DashboardService _dashboardService = DashboardService();

  bool _isLocationEnabled = false;
  bool _isCheckingLocation = false;
  String? _placeName;
  double? _latitude;
  double? _longitude;
  bool _isFetchingPlaceName = false;
  Map<String, dynamic>? _weatherData;
  bool _isFetchingWeather = false;

  // Dashboard data
  UserInfo? _userInfo;
  List<HelpRequest> _helpRequests = [];
  bool _isFetchingDashboard = false;

  // Header ViewModel
  DashboardHeaderViewModel? _headerViewModel;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    // Initialize header view model
    _headerViewModel = DashboardHeaderViewModel();
    _headerViewModel?.onVerifyIdentity = _handleVerifyIdentity;
    _headerViewModel?.onAddEmergencyContact = _handleAddEmergencyContact;

    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _headerViewModel?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // Check location when app comes back to foreground
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    if (_isCheckingLocation) return;

    setState(() {
      _isCheckingLocation = true;
    });

    try {
      // Check if location service is enabled on device
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        // Location service is disabled on device
        setState(() {
          _isLocationEnabled = false;
          _isCheckingLocation = false;
        });
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      // Check if app has location permission
      final permission = await Permission.location.status;

      if (!permission.isGranted) {
        // App doesn't have permission (denied, permanently denied, restricted, limited)
        setState(() {
          _isLocationEnabled = false;
          _isCheckingLocation = false;
        });
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      // Both service and permission are granted
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('locationEnabled', true);

      setState(() {
        _isLocationEnabled = true;
        _isCheckingLocation = false;
      });

      // Fetch current location and get place name
      _fetchLocationAndPlaceName();
    } catch (e) {
      // Handle error
      setState(() {
        _isLocationEnabled = false;
        _isCheckingLocation = false;
      });
      if (mounted) {
        _showLocationPermissionDialog();
      }
    }
  }

  Future<void> _fetchDashboardData() async {
    if (_isFetchingDashboard) return;

    setState(() {
      _isFetchingDashboard = true;
    });

    try {
      final response = await _dashboardService.getDashboardData(
        latitude: _latitude,
        longitude: _longitude,
      );

      if (response.success && response.data != null && mounted) {
        setState(() {
          _userInfo = response.data!.user;
          _helpRequests = response.data!.helpRequests;
          _isFetchingDashboard = false;
        });

        // Update header view model with verification status
        _headerViewModel?.updateVerificationStatus(
          isVerified: _userInfo!.isVerified,
          hasEmergencyContact: _userInfo!.hasEmergencyContact,
        );

        print('Dashboard data loaded: ${_helpRequests.length} help requests');
      } else {
        setState(() {
          _isFetchingDashboard = false;
        });
        print('Failed to fetch dashboard data: ${response.message}');
      }
    } catch (e) {
      print('Error fetching dashboard data: $e');
      setState(() {
        _isFetchingDashboard = false;
      });
    }
  }

  Future<void> _fetchLocationAndPlaceName() async {
    if (_isFetchingPlaceName) return;

    setState(() {
      _isFetchingPlaceName = true;
    });

    try {
      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

      // Fetch place name from OpenStreetMap
      final locationData = await GeocodingService.getPlaceFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (locationData != null && mounted) {
        final placeName = GeocodingService.getShortPlaceName(locationData);

        setState(() {
          _placeName = placeName;
          _isFetchingPlaceName = false;
        });

        // Save to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userLocation', placeName);
        await prefs.setString(
            'fullAddress', locationData['address'] ?? placeName);
        await prefs.setDouble('latitude', position.latitude);
        await prefs.setDouble('longitude', position.longitude);

        print('Location: $placeName');
        print('Coordinates: ${position.latitude}, ${position.longitude}');

        // Fetch weather data
        _fetchWeatherData();

        // Fetch dashboard data
        _fetchDashboardData();
      } else {
        setState(() {
          _placeName = 'Location unavailable';
          _isFetchingPlaceName = false;
        });
      }
    } catch (e) {
      print('Error fetching location: $e');
      setState(() {
        _placeName = 'Unable to fetch location';
        _isFetchingPlaceName = false;
      });
    }
  }

  Future<void> _fetchWeatherData() async {
    if (_latitude == null || _longitude == null || _isFetchingWeather) return;

    setState(() {
      _isFetchingWeather = true;
    });

    try {
      final weather = await WeatherService.getCurrentWeather(
        latitude: _latitude!,
        longitude: _longitude!,
      );

      if (weather != null && mounted) {
        setState(() {
          _weatherData = weather;
          _isFetchingWeather = false;
        });
      } else {
        setState(() {
          _isFetchingWeather = false;
        });
      }
    } catch (e) {
      print('Error fetching weather: $e');
      setState(() {
        _isFetchingWeather = false;
      });
    }
  }

  void _showLocationPermissionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              const Icon(Icons.location_off, color: Colors.red, size: 28),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Location Required',
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
                'RescueNet needs location access to:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 12),
              _buildPermissionReason(
                Icons.emergency,
                'Send accurate location in emergencies',
              ),
              _buildPermissionReason(
                Icons.people,
                'Find nearby volunteers and help requests',
              ),
              _buildPermissionReason(
                Icons.notifications_active,
                'Receive location-based alerts',
              ),
              _buildPermissionReason(
                Icons.shield,
                'Connect with local rescue teams',
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_amber,
                        color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'You cannot use the app without enabling location',
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.orange[900],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _requestLocationPermission(context),
                icon: const Icon(Icons.location_on),
                label: Text(
                  'Enable Location',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionReason(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.green[700]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: GoogleFonts.poppins(fontSize: 13),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _requestLocationPermission(BuildContext dialogContext) async {
    try {
      // First check if location service is enabled on device
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        // Close dialog first
        Navigator.of(dialogContext).pop();

        // Show dialog prompting user to enable location service in device settings
        if (mounted) {
          showDialog(
            context: context,
            barrierDismissible: false,
            builder: (context) => WillPopScope(
              onWillPop: () async => false,
              child: AlertDialog(
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
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        // Open location settings
                        await Geolocator.openLocationSettings();
                        Navigator.of(context).pop();
                        // Recheck after a delay
                        await Future.delayed(const Duration(seconds: 2));
                        _checkLocationPermission();
                      },
                      icon: const Icon(Icons.settings),
                      label: Text(
                        'Open Settings',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFD32F2F),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _checkLocationPermission();
                    },
                    child: Text(
                      'I\'ve Enabled It',
                      style: GoogleFonts.poppins(
                        color: const Color(0xFFD32F2F),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        return;
      }

      // Check current permission status first
      var currentStatus = await Permission.location.status;

      // If already granted, just proceed with location check
      if (currentStatus.isGranted) {
        Navigator.of(dialogContext).pop();
        await _checkLocationPermission();
        return;
      }

      // If permanently denied, go straight to app settings
      if (currentStatus.isPermanentlyDenied) {
        Navigator.of(dialogContext).pop();
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

          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation',
              'Lat: ${position.latitude.toStringAsFixed(4)}, Lng: ${position.longitude.toStringAsFixed(4)}');

          setState(() {
            _isLocationEnabled = true;
          });

          // Close dialog
          Navigator.of(dialogContext).pop();

          // Show success message
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Row(
                  children: [
                    const Icon(Icons.check_circle, color: Colors.white),
                    const SizedBox(width: 8),
                    Text(
                      'Location enabled successfully',
                      style: GoogleFonts.poppins(),
                    ),
                  ],
                ),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        } catch (e) {
          // Could not get position, but permission is granted
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', 'Location permission granted');

          setState(() {
            _isLocationEnabled = true;
          });

          Navigator.of(dialogContext).pop();
        }
      } else if (status.isPermanentlyDenied) {
        // Permission permanently denied, prompt to open settings
        Navigator.of(dialogContext).pop();
        if (mounted) {
          _showOpenAppSettingsDialog();
        }
      } else if (status.isDenied) {
        // Permission was just denied (not permanently), but might need settings if dialog didn't show
        Navigator.of(dialogContext).pop();
        if (mounted) {
          // Check again if it's actually permanently denied now
          final recheckStatus = await Permission.location.status;
          if (recheckStatus.isPermanentlyDenied) {
            _showOpenAppSettingsDialog();
          } else {
            // Try one more time with a delay
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Please allow location permission when prompted',
                  style: GoogleFonts.poppins(fontSize: 13),
                ),
                backgroundColor: Colors.orange,
                behavior: SnackBarBehavior.floating,
                duration: const Duration(seconds: 2),
              ),
            );
            Future.delayed(const Duration(seconds: 2), () {
              if (mounted && !_isLocationEnabled) {
                _showLocationPermissionDialog();
              }
            });
          }
        }
      }
    } catch (e) {
      // Handle error - close dialog and show error
      try {
        Navigator.of(dialogContext).pop();
      } catch (_) {
        // Dialog might already be closed
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error: ${e.toString()}',
              style: GoogleFonts.poppins(),
            ),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
            duration: const Duration(seconds: 3),
          ),
        );

        // Show dialog again after error
        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isLocationEnabled) {
            _showLocationPermissionDialog();
          }
        });
      }
    }
  }

  void _showOpenAppSettingsDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
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
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location permission is required to use RescueNet.',
                style: GoogleFonts.poppins(fontSize: 14),
              ),
              const SizedBox(height: 12),
              Text(
                'Please enable it manually:',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '1. Tap "Open Settings" below\n2. Find "Permissions" or "App permissions"\n3. Enable "Location" permission',
                style: GoogleFonts.poppins(fontSize: 13),
              ),
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await openAppSettings();
                  Navigator.of(context).pop();
                  // Give user time to change settings
                  await Future.delayed(const Duration(seconds: 1));
                  _checkLocationPermission();
                },
                icon: const Icon(Icons.settings),
                label: Text(
                  'Open App Settings',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFD32F2F),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _checkLocationPermission();
              },
              child: Text(
                'I\'ve Enabled It',
                style: GoogleFonts.poppins(
                  color: const Color(0xFFD32F2F),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Header action handlers
  void _handleVerifyIdentity() {
    // Navigate to user profile page for identity verification
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    ).then((_) {
      // Refresh header after returning
      _headerViewModel?.refresh();
    });
  }

  void _handleAddEmergencyContact() {
    // Navigate to emergency contact page
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const EmergencyContactPage()),
    ).then((_) {
      // Refresh header after returning
      _headerViewModel?.refresh();
    });
  }

  void _handleProfileTap() {
    // Navigate to user profile
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const UserProfilePage()),
    ).then((_) {
      // Refresh header after returning
      _headerViewModel?.refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: Column(
        children: [
          // Context-aware header
          if (_headerViewModel != null)
            DashboardHeader(
              viewModel: _headerViewModel!,
              onProfileTap: _handleProfileTap,
            ),

          // Main content
          Expanded(
            child: !_isLocationEnabled
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.location_off,
                            size: 80, color: Colors.grey),
                        const SizedBox(height: 16),
                        Text(
                          'Location Required',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : RefreshIndicator(
                    onRefresh: () async {
                      await _fetchLocationAndPlaceName();
                      await _fetchDashboardData();
                      await _headerViewModel?.refresh();
                    },
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      child: Column(
                        children: [
                          // Weather Card
                          _buildWeatherCard(),

                          // Help Requests Feed
                          _buildRequestsFeed(),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: DashboardBottomNav(
        latitude: _latitude,
        longitude: _longitude,
        placeName: _placeName,
      ),
    );
  }

  Widget _buildWeatherCard() {
    if (_weatherData == null && _isFetchingWeather) {
      return Container(
        margin: const EdgeInsets.all(16),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    if (_weatherData == null) {
      return const SizedBox.shrink();
    }

    final temp = _weatherData!['temperature'] as double;
    final description = _weatherData!['description'] as String;
    final main = _weatherData!['main'] as String;
    final emoji = WeatherService.getWeatherEmoji(main);
    final alert = WeatherService.getWeatherAlert(_weatherData!);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.red.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${temp.toStringAsFixed(0)}°C',
                    style: GoogleFonts.poppins(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    description.toUpperCase(),
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      color: Colors.white70,
                      letterSpacing: 1,
                    ),
                  ),
                ],
              ),
              Text(
                emoji,
                style: const TextStyle(fontSize: 64),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white70, size: 16),
              const SizedBox(width: 4),
              Expanded(
                child: Text(
                  _placeName ?? 'Unknown Location',
                  style: GoogleFonts.poppins(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (alert != null) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber,
                      color: Colors.white, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      alert,
                      style: GoogleFonts.poppins(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRequestsFeed() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Help Requests',
            style: GoogleFonts.poppins(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 16),

          if (_isFetchingDashboard)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(32.0),
                child: CircularProgressIndicator(),
              ),
            )
          else if (_helpRequests.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    Icon(Icons.inbox_outlined,
                        size: 64, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text(
                      'No help requests nearby',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            ..._helpRequests.map((request) => _buildRequestCard(
                  name: request.userName,
                  category: request.category,
                  description: request.description,
                  time: request.timeAgo,
                  distance: request.distanceText,
                  icon: _getCategoryIcon(request.category),
                  color: _getCategoryColor(request.category),
                  request: request,
                )),

          const SizedBox(height: 80), // Space for bottom nav
        ],
      ),
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
      case 'medical emergency':
        return Icons.medical_services;
      case 'accident':
      case 'car accident':
        return Icons.car_crash;
      case 'fire':
      case 'fire emergency':
        return Icons.local_fire_department;
      case 'flood':
        return Icons.water;
      case 'earthquake':
        return Icons.crisis_alert;
      default:
        return Icons.emergency;
    }
  }

  Color _getCategoryColor(String category) {
    switch (category.toLowerCase()) {
      case 'medical':
      case 'medical emergency':
        return Colors.red;
      case 'accident':
      case 'car accident':
        return Colors.orange;
      case 'fire':
      case 'fire emergency':
        return Colors.deepOrange;
      case 'flood':
        return Colors.blue;
      case 'earthquake':
        return Colors.purple;
      default:
        return Colors.red;
    }
  }

  Widget _buildRequestCard({
    required String name,
    required String category,
    required String description,
    required String time,
    required String distance,
    required IconData icon,
    required Color color,
    HelpRequest? request,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      category,
                      style: GoogleFonts.poppins(
                        fontSize: 12,
                        color: color,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    time,
                    style: GoogleFonts.poppins(
                      fontSize: 11,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on,
                          size: 12, color: Colors.grey[600]),
                      Text(
                        distance,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            description,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black87,
            ),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () {
                    if (request != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => HelpRequestDetailsPage(
                            request: request,
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.info_outline, size: 18),
                  label: Text(
                    'Details',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: color,
                    side: BorderSide(color: color),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () {},
                  icon: const Icon(Icons.volunteer_activism, size: 18),
                  label: Text(
                    'Help',
                    style: GoogleFonts.poppins(fontSize: 13),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: color,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

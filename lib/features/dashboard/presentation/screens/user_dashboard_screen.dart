import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:RescueNetApp/services/geocoding_service.dart';
import 'package:RescueNetApp/services/weather_service.dart';
import '../widgets/dashboard_bottom_nav.dart';

/// Clean refactored user dashboard screen.
/// Follows clean architecture principles with separation of concerns.
/// Contains only the main UI logic and delegates navigation to child widgets.
class UserDashboardScreen extends StatefulWidget {
  final Map<String, dynamic>? userData;

  const UserDashboardScreen({super.key, this.userData});

  @override
  State<UserDashboardScreen> createState() => _UserDashboardScreenState();
}

class _UserDashboardScreenState extends State<UserDashboardScreen>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  bool _isLocationEnabled = false;
  bool _isCheckingLocation = false;
  String? _placeName;
  double? _latitude;
  double? _longitude;
  bool _isFetchingPlaceName = false;
  Map<String, dynamic>? _weatherData;
  bool _isFetchingWeather = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkLocationPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkLocationPermission();
    }
  }

  Future<void> _checkLocationPermission() async {
    if (_isCheckingLocation) return;

    setState(() {
      _isCheckingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() {
          _isLocationEnabled = false;
          _isCheckingLocation = false;
        });
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      final permission = await Permission.location.status;

      if (!permission.isGranted) {
        setState(() {
          _isLocationEnabled = false;
          _isCheckingLocation = false;
        });
        if (mounted) {
          _showLocationPermissionDialog();
        }
        return;
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('locationEnabled', true);

      setState(() {
        _isLocationEnabled = true;
        _isCheckingLocation = false;
      });

      _fetchLocationAndPlaceName();
    } catch (e) {
      setState(() {
        _isLocationEnabled = false;
        _isCheckingLocation = false;
      });
      if (mounted) {
        _showLocationPermissionDialog();
      }
    }
  }

  Future<void> _fetchLocationAndPlaceName() async {
    if (_isFetchingPlaceName) return;

    setState(() {
      _isFetchingPlaceName = true;
    });

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
      });

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

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('userLocation', placeName);
        await prefs.setString(
            'fullAddress', locationData['address'] ?? placeName);
        await prefs.setDouble('latitude', position.latitude);
        await prefs.setDouble('longitude', position.longitude);

        _fetchWeatherData();
      } else {
        setState(() {
          _placeName = 'Location unavailable';
          _isFetchingPlaceName = false;
        });
      }
    } catch (e) {
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
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        Navigator.of(dialogContext).pop();
        if (mounted) {
          _showOpenLocationSettingsDialog();
        }
        return;
      }

      var currentStatus = await Permission.location.status;

      if (currentStatus.isGranted) {
        Navigator.of(dialogContext).pop();
        await _checkLocationPermission();
        return;
      }

      if (currentStatus.isPermanentlyDenied) {
        Navigator.of(dialogContext).pop();
        if (mounted) {
          _showOpenAppSettingsDialog();
        }
        return;
      }

      final status = await Permission.location.request();

      if (status.isGranted) {
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

          Navigator.of(dialogContext).pop();

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
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool('locationEnabled', true);
          await prefs.setString('userLocation', 'Location permission granted');

          setState(() {
            _isLocationEnabled = true;
          });

          Navigator.of(dialogContext).pop();
        }
      } else if (status.isPermanentlyDenied) {
        Navigator.of(dialogContext).pop();
        if (mounted) {
          _showOpenAppSettingsDialog();
        }
      } else if (status.isDenied) {
        Navigator.of(dialogContext).pop();
        if (mounted) {
          final recheckStatus = await Permission.location.status;
          if (recheckStatus.isPermanentlyDenied) {
            _showOpenAppSettingsDialog();
          } else {
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
      try {
        Navigator.of(dialogContext).pop();
      } catch (_) {}

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

        Future.delayed(const Duration(seconds: 3), () {
          if (mounted && !_isLocationEnabled) {
            _showLocationPermissionDialog();
          }
        });
      }
    }
  }

  void _showOpenLocationSettingsDialog() {
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
                  await Geolocator.openLocationSettings();
                  Navigator.of(context).pop();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        elevation: 0,
        title: Row(
          children: [
            const Icon(Icons.emergency, color: Colors.white, size: 24),
            const SizedBox(width: 8),
            Text(
              'RescueNet',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ],
        ),
        automaticallyImplyLeading: false,
      ),
      body: !_isLocationEnabled
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.location_off, size: 80, color: Colors.grey),
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
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildWeatherCard(),
                    _buildRequestsFeed(),
                  ],
                ),
              ),
            ),
      bottomNavigationBar: const DashboardBottomNav(),
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
          _buildRequestCard(
            name: 'John Doe',
            category: 'Medical Emergency',
            description: 'Need urgent medical assistance at home',
            time: '5 min ago',
            distance: '1.2 km',
            icon: Icons.medical_services,
            color: Colors.red,
          ),
          _buildRequestCard(
            name: 'Sarah Ahmed',
            category: 'Accident',
            description: 'Car accident near the highway, need help',
            time: '12 min ago',
            distance: '3.5 km',
            icon: Icons.car_crash,
            color: Colors.orange,
          ),
          _buildRequestCard(
            name: 'Mike Rahman',
            category: 'Fire Emergency',
            description: 'Small fire in apartment building',
            time: '25 min ago',
            distance: '5.8 km',
            icon: Icons.local_fire_department,
            color: Colors.deepOrange,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }

  Widget _buildRequestCard({
    required String name,
    required String category,
    required String description,
    required String time,
    required String distance,
    required IconData icon,
    required Color color,
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
                  onPressed: () {},
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

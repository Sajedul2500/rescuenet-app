import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../../services/geocoding_service.dart';
import '../../data/repositories/offline_request_repository.dart';
import '../../services/sms_service.dart';
import '../../services/connectivity_service.dart';
import '../../services/background_sync_service.dart';

/// Offline-capable emergency request page
/// Works without internet, sends SMS, stores locally, and syncs when online
class OfflineCreateRequestPage extends StatefulWidget {
  const OfflineCreateRequestPage({super.key});

  @override
  State<OfflineCreateRequestPage> createState() =>
      _OfflineCreateRequestPageState();
}

class _OfflineCreateRequestPageState extends State<OfflineCreateRequestPage> {
  final _formKey = GlobalKey<FormState>();
  final _descriptionController = TextEditingController();

  // Lazy initialization to avoid plugin errors
  OfflineRequestRepository? _repository;
  final ConnectivityService _connectivityService = ConnectivityService();
  final BackgroundSyncService _syncService = BackgroundSyncService();

  OfflineRequestRepository get repository {
    _repository ??= OfflineRequestRepository();
    return _repository!;
  }

  String _selectedCategory = 'medical';
  bool _isGettingLocation = false;
  bool _isSubmitting = false;
  bool _isConnected = false;
  int _pendingCount = 0;

  // Location data
  double? _latitude;
  double? _longitude;
  String? _locationName;

  // Permission states
  bool _hasLocationPermission = false;
  bool _hasSmsPermission = false;
  bool _permissionsChecked = false;

  final List<Map<String, dynamic>> _categories = [
    {
      'value': 'medical',
      'label': 'Medical Emergency',
      'icon': Icons.medical_services,
    },
    {
      'value': 'fire',
      'label': 'Fire Emergency',
      'icon': Icons.local_fire_department,
    },
    {'value': 'accident', 'label': 'Accident', 'icon': Icons.car_crash},
    {'value': 'flood', 'label': 'Flood', 'icon': Icons.water},
    {'value': 'earthquake', 'label': 'Earthquake', 'icon': Icons.crisis_alert},
    {'value': 'rescue', 'label': 'Rescue Needed', 'icon': Icons.security},
    {'value': 'other', 'label': 'Other Emergency', 'icon': Icons.emergency},
  ];

  @override
  void initState() {
    super.initState();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    try {
      // Initialize connectivity service (non-blocking)
      _connectivityService.initialize().catchError((e) {
        print('Connectivity service init error: $e');
      });

      // Initialize background sync service (non-blocking)
      _syncService.initialize().catchError((e) {
        print('Background sync init error: $e');
      });

      // Check connectivity
      _isConnected = await _connectivityService.checkConnectivity();

      // Listen to connectivity changes
      _connectivityService.connectivityStream.listen((isConnected) {
        if (mounted) {
          setState(() {
            _isConnected = isConnected;
          });
        }
      });

      // Check permissions
      await _checkPermissions();

      // Get current location
      await _getCurrentLocation();

      // Load pending count
      await _loadPendingCount();
    } catch (e) {
      print('Error initializing services: $e');
      // Continue even if initialization fails
      if (mounted) {
        setState(() {
          _permissionsChecked = true;
        });
      }
    }
  }

  Future<void> _loadPendingCount() async {
    try {
      final count = await repository.getPendingCount();
      if (mounted) {
        setState(() {
          _pendingCount = count;
        });
      }
    } catch (e) {
      print('Error loading pending count: $e');
      // Ignore errors during count loading
    }
  }

  Future<void> _checkPermissions() async {
    try {
      final locationStatus = await Permission.location.status;
      final smsStatus = await Permission.sms.status;

      if (mounted) {
        setState(() {
          _hasLocationPermission = locationStatus.isGranted;
          _hasSmsPermission = smsStatus.isGranted;
          _permissionsChecked = true;
        });
      }
    } catch (e) {
      print('Error checking permissions: $e');
      if (mounted) {
        setState(() {
          _permissionsChecked = true;
        });
      }
    }
  }

  Future<void> _requestPermissions() async {
    try {
      // Request location permission
      if (!_hasLocationPermission) {
        final status = await Permission.location.request();
        if (mounted) {
          setState(() {
            _hasLocationPermission = status.isGranted;
          });
        }

        // If location permission denied, show message
        if (status.isDenied || status.isPermanentlyDenied) {
          if (mounted) {
            _showErrorSnackbar(
              'Location permission is required for emergency requests. Please enable it in settings.',
            );
          }
        }
      }

      // Request SMS permission using permission_handler
      if (!_hasSmsPermission) {
        final status = await Permission.sms.request();
        if (mounted) {
          setState(() {
            _hasSmsPermission = status.isGranted;
          });
        }

        // Handle SMS permission result
        if (status.isGranted) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '\u2705 SMS permission granted! You can now send emergency SMS.',
                  style: GoogleFonts.poppins(),
                ),
                backgroundColor: Colors.green,
                duration: const Duration(seconds: 2),
              ),
            );
          }
        } else if (status.isDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '\u26a0\ufe0f SMS permission denied. Emergency SMS won\'t be sent, but requests will be saved and synced online.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: Colors.orange,
                duration: const Duration(seconds: 4),
              ),
            );
          }
        } else if (status.isPermanentlyDenied) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  '\u26a0\ufe0f SMS permission permanently denied. Enable it in app settings to send emergency SMS.',
                  style: GoogleFonts.poppins(fontSize: 12),
                ),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 4),
                action: SnackBarAction(
                  label: 'Settings',
                  textColor: Colors.white,
                  onPressed: () => openAppSettings(),
                ),
              ),
            );
          }
        }
      }

      // Get location after permissions granted
      if (_hasLocationPermission) {
        await _getCurrentLocation();
      }
    } catch (e) {
      print('Error requesting permissions: $e');
      _showErrorSnackbar(
        'Failed to request permissions. Please enable manually in settings.',
      );
    }
  }

  Future<void> _getCurrentLocation() async {
    if (!_hasLocationPermission) return;

    if (mounted) {
      setState(() {
        _isGettingLocation = true;
      });
    }

    try {
      final position =
          await Geolocator.getCurrentPosition(
            desiredAccuracy: LocationAccuracy.high,
          ).timeout(
            const Duration(seconds: 10),
            onTimeout: () => throw TimeoutException('Location timeout'),
          );

      final locationData = await GeocodingService.getPlaceFromCoordinates(
        latitude: position.latitude,
        longitude: position.longitude,
      );

      if (mounted) {
        setState(() {
          _latitude = position.latitude;
          _longitude = position.longitude;
          _locationName = locationData != null
              ? GeocodingService.getShortPlaceName(locationData)
              : 'Location detected';
          _isGettingLocation = false;
        });
      }
    } catch (e) {
      print('Error getting location: $e');
      if (mounted) {
        setState(() {
          _isGettingLocation = false;
        });
      }
    }
  }

  Future<void> _submitRequest() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if location is available
    if (_latitude == null || _longitude == null) {
      _showErrorSnackbar(
        'Location is required. Please wait for location or enable GPS.',
      );
      return;
    }

    if (mounted) {
      setState(() {
        _isSubmitting = true;
      });
    }

    bool smsSent = false;
    bool savedLocally = false;
    String? smsError;

    try {
      final description = _descriptionController.text.trim();

      // 1. Try to send SMS if permission granted
      if (_hasSmsPermission) {
        try {
          smsSent = await SmsService.sendEmergencySms(
            requestType: _selectedCategory,
            description: description,
            latitude: _latitude!,
            longitude: _longitude!,
            locationName: _locationName,
          );

          if (!smsSent) {
            smsError =
                'SMS failed to send. This could be due to insufficient balance or network issues.';
          }
        } catch (e) {
          print('SMS sending error: $e');
          smsError = 'Unable to send SMS: ${e.toString()}';
        }
      }

      // 2. Store request locally (critical - must succeed)
      try {
        await repository.createRequest(
          type: _selectedCategory,
          description: description,
          latitude: _latitude!,
          longitude: _longitude!,
          locationName: _locationName,
        );
        savedLocally = true;
      } catch (e) {
        print('Database error: $e');
        throw Exception('Failed to save request locally: ${e.toString()}');
      }

      // 3. Try to sync immediately if online
      if (_isConnected) {
        try {
          await _syncService.syncNow();
        } catch (e) {
          print('Sync error: $e');
          // Non-critical error, continue
        }
      }

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Build comprehensive success/warning message
        String message;
        Color backgroundColor;

        if (savedLocally && smsSent) {
          // Best case: both succeeded
          message =
              '✅ Emergency SMS sent! Request saved and ${_isConnected ? "synced online" : "will sync when you're back online"}.';
          backgroundColor = Colors.green;
        } else if (savedLocally && !_hasSmsPermission) {
          // No SMS permission
          message =
              '✅ Request saved! It will be synced when you\'re online.\n💡 Grant SMS permission for emergency alerts.';
          backgroundColor = Colors.orange;
        } else if (savedLocally && smsError != null) {
          // SMS failed but saved locally
          message =
              '✅ Request saved locally and will sync when online.\n⚠️ $smsError';
          backgroundColor = Colors.orange;
        } else {
          // Saved locally, SMS not sent
          message =
              '✅ Request saved! It\'s in the queue and will be sent to emergency services when you have internet connection.';
          backgroundColor = Colors.orange;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(message, style: GoogleFonts.poppins(fontSize: 13)),
            backgroundColor: backgroundColor,
            duration: const Duration(seconds: 5),
            behavior: SnackBarBehavior.floating,
            action: !_isConnected
                ? SnackBarAction(
                    label: 'OK',
                    textColor: Colors.white,
                    onPressed: () {},
                  )
                : null,
          ),
        );

        // Navigate back
        Navigator.pop(context, true);
      }
    } catch (e) {
      print('Error submitting request: $e');

      if (mounted) {
        setState(() {
          _isSubmitting = false;
        });

        // Show user-friendly error
        String errorMessage = 'Failed to save request. ';
        if (e.toString().contains('sqflite') ||
            e.toString().contains('database') ||
            e.toString().contains('MissingPluginException')) {
          errorMessage +=
              'Database error. Please restart the app and try again.';
        } else {
          errorMessage +=
              'Please try again or contact support if the issue persists.';
        }

        _showErrorSnackbar(errorMessage);
      }
    }
  }

  void _showErrorSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.poppins()),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.security, color: Color(0xFFD32F2F)),
            const SizedBox(width: 8),
            Text(
              'Permission',
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'This offline emergency feature requires:',
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            _buildPermissionItem(
              Icons.location_on,
              'Location',
              'To send your precise coordinates in emergencies',
              _hasLocationPermission,
            ),
            const SizedBox(height: 8),
            _buildPermissionItem(
              Icons.sms,
              'SMS',
              'To send emergency alerts even without internet',
              _hasSmsPermission,
            ),
            const SizedBox(height: 12),
            Text(
              'These permissions are requested only once and help ensure your safety.',
              style: GoogleFonts.poppins(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: GoogleFonts.poppins()),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _requestPermissions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFD32F2F),
            ),
            child: Text('Grant Permissions', style: GoogleFonts.poppins()),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem(
    IconData icon,
    String title,
    String description,
    bool granted,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: granted ? Colors.green : Colors.orange),
        const SizedBox(width: 8),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: GoogleFonts.poppins(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                description,
                style: GoogleFonts.poppins(
                  fontSize: 11,
                  color: Colors.grey[600],
                ),
              ),
            ],
          ),
        ),
        if (granted)
          const Icon(Icons.check_circle, size: 16, color: Colors.green),
      ],
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: const Color(0xFFD32F2F),
        foregroundColor: Colors.white,
        title: Text(
          'Emergency Request (Offline)',
          style: GoogleFonts.poppins(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        actions: [
          // Connectivity indicator
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _isConnected ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _isConnected ? Icons.wifi : Icons.wifi_off,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _isConnected ? 'Online' : 'Offline',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Info banner
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              border: Border(bottom: BorderSide(color: Colors.blue[200]!)),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: Colors.blue[800], size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    '📱 Works offline • Sends SMS • Auto-syncs when online',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: Colors.blue[900],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Pending requests banner
          if (_pendingCount > 0)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border(bottom: BorderSide(color: Colors.orange[200]!)),
              ),
              child: Row(
                children: [
                  Icon(Icons.cloud_upload, color: Colors.orange[800], size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '$_pendingCount request(s) pending sync',
                      style: GoogleFonts.poppins(
                        fontSize: 11,
                        color: Colors.orange[900],
                      ),
                    ),
                  ),
                  if (_isConnected)
                    TextButton(
                      onPressed: () async {
                        await _syncService.syncNow();
                        await _loadPendingCount();
                      },
                      child: Text(
                        'Sync Now',
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),

          // Main content
          Expanded(
            child: !_permissionsChecked
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Permissions card
                          if (!_hasLocationPermission || !_hasSmsPermission)
                            Card(
                              elevation: 2,
                              color: Colors.orange[50],
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                                side: BorderSide(color: Colors.orange[300]!),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Icon(
                                          Icons.warning_amber,
                                          color: Colors.orange[800],
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          'Permissions Needed',
                                          style: GoogleFonts.poppins(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'For full offline functionality, please grant required permissions.',
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                    const SizedBox(height: 12),
                                    SizedBox(
                                      width: double.infinity,
                                      child: ElevatedButton.icon(
                                        onPressed: _showPermissionDialog,
                                        icon: const Icon(
                                          Icons.security,
                                          size: 18,
                                        ),
                                        label: Text(
                                          'Grant Permissions',
                                          style: GoogleFonts.poppins(),
                                        ),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.orange[700],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          const SizedBox(height: 16),

                          // Location card
                          Card(
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.location_on,
                                        color: _latitude != null
                                            ? Colors.green
                                            : Colors.grey,
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _isGettingLocation
                                              ? 'Getting location...'
                                              : _locationName ??
                                                    'Location not available',
                                          style: GoogleFonts.poppins(
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      if (_isGettingLocation)
                                        const SizedBox(
                                          width: 16,
                                          height: 16,
                                          child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                          ),
                                        ),
                                    ],
                                  ),
                                  if (_latitude != null && _longitude != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 8),
                                      child: Text(
                                        'Lat: ${_latitude!.toStringAsFixed(6)}, Lng: ${_longitude!.toStringAsFixed(6)}',
                                        style: GoogleFonts.poppins(
                                          fontSize: 11,
                                          color: Colors.grey[600],
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Category selection
                          Text(
                            'Emergency Type *',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: _categories.map((category) {
                              final isSelected =
                                  _selectedCategory == category['value'];
                              return FilterChip(
                                label: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      category['icon'] as IconData,
                                      size: 16,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.grey[700],
                                    ),
                                    const SizedBox(width: 6),
                                    Text(
                                      category['label'] as String,
                                      style: GoogleFonts.poppins(fontSize: 12),
                                    ),
                                  ],
                                ),
                                selected: isSelected,
                                onSelected: (selected) {
                                  setState(() {
                                    _selectedCategory =
                                        category['value'] as String;
                                  });
                                },
                                selectedColor: const Color(0xFFD32F2F),
                                labelStyle: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.black87,
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 20),

                          // Description
                          Text(
                            'Description *',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          TextFormField(
                            controller: _descriptionController,
                            maxLines: 5,
                            maxLength: 250,
                            decoration: InputDecoration(
                              hintText: 'Describe the emergency situation...',
                              hintStyle: GoogleFonts.poppins(fontSize: 14),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              filled: true,
                              fillColor: Colors.white,
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Description is required';
                              }
                              if (value.trim().length < 10) {
                                return 'Description must be at least 10 characters';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 30),

                          // Submit button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isSubmitting ? null : _submitRequest,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFD32F2F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isSubmitting
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      '🚨 Send Emergency Request',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}

class TimeoutException implements Exception {
  final String message;
  TimeoutException(this.message);

  @override
  String toString() => message;
}

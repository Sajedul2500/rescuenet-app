import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:RescueNetBD/pages/CreateRequestPage.dart';
import 'package:RescueNetBD/pages/HelpRequestHistoryPage.dart';
import 'package:RescueNetBD/pages/NotificationPage.dart';
import 'package:RescueNetBD/services/notification_service.dart';
import 'package:RescueNetBD/features/offline_request/presentation/pages/offline_create_request_page.dart';
import 'more_bottom_sheet.dart';
import '../../../emergency_services/presentation/widgets/services_bottom_sheet.dart';

/// Emergency-first bottom navigation widget.
/// Prioritizes critical emergency actions over non-essential features.
class DashboardBottomNav extends StatefulWidget {
  final double? latitude;
  final double? longitude;
  final String? placeName;

  const DashboardBottomNav({
    super.key,
    this.latitude,
    this.longitude,
    this.placeName,
  });

  @override
  State<DashboardBottomNav> createState() => _DashboardBottomNavState();
}

class _DashboardBottomNavState extends State<DashboardBottomNav> {
  int _currentIndex = 0;
  final NotificationService _notificationService = NotificationService();
  int _unreadCount = 0;

  @override
  void initState() {
    super.initState();
    _loadUnreadCount();
  }

  Future<void> _loadUnreadCount() async {
    final response = await _notificationService.getUnreadCount();
    if (response.success && response.data != null) {
      if (mounted) {
        setState(() {
          _unreadCount = response.data as int;
        });
      }
    }
  }

  void _navigateToPage(Widget page, int index) {
    if (!mounted) return;
    setState(() {
      _currentIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showNearbyHelp() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 1;
    });

    // Check if location data is available
    if (widget.latitude != null && widget.longitude != null) {
      ServicesBottomSheet.show(
        context,
        latitude: widget.latitude!,
        longitude: widget.longitude!,
        placeName: widget.placeName ?? 'Your Location',
      );
    } else {
      // Fallback: show error snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('Location not available. Please enable location services.'),
          backgroundColor: Color(0xFFD32F2F),
        ),
      );
    }
  }

  void _showMoreOptions() {
    if (!mounted) return;
    setState(() {
      _currentIndex = 4;
    });
    MoreBottomSheet.show(context);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavItem(
                icon: Icons.notifications,
                label: 'Updates',
                index: 0,
                showBadge: _unreadCount > 0,
                badgeCount: _unreadCount,
                onTap: () {
                  if (!mounted) return;
                  setState(() {
                    _currentIndex = 0;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const NotificationPage(),
                    ),
                  ).then((_) => _loadUnreadCount());
                },
              ),
              _buildNavItem(
                icon: Icons.location_on,
                label: 'Nearby Help',
                index: 1,
                onTap: _showNearbyHelp,
              ),
              _buildCenterFAB(),
              _buildNavItem(
                icon: Icons.assignment,
                label: 'My Request',
                index: 3,
                onTap: () => _navigateToPage(
                  const HelpRequestHistoryPage(),
                  3,
                ),
              ),
              _buildNavItem(
                icon: Icons.more_horiz,
                label: 'More',
                index: 4,
                onTap: _showMoreOptions,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required VoidCallback onTap,
    bool showBadge = false,
    int badgeCount = 0,
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Icon(
                  icon,
                  color:
                      isSelected ? const Color(0xFFD32F2F) : Colors.grey[600],
                  size: 24,
                ),
                if (showBadge && badgeCount > 0)
                  Positioned(
                    right: -8,
                    top: -4,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(
                        minWidth: 18,
                        minHeight: 18,
                      ),
                      decoration: const BoxDecoration(
                        color: Color(0xFFD32F2F),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          badgeCount > 99 ? '99+' : badgeCount.toString(),
                          style: GoogleFonts.poppins(
                            fontSize: 10,
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: isSelected ? const Color(0xFFD32F2F) : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterFAB() {
    return GestureDetector(
      onTap: () async {
        if (!mounted) return;
        setState(() {
          _currentIndex = 2;
        });

        // Check connectivity and navigate to appropriate page
        try {
          final connectivity = await Connectivity().checkConnectivity();
          final isOnline = connectivity.any((result) =>
              result == ConnectivityResult.wifi ||
              result == ConnectivityResult.mobile ||
              result == ConnectivityResult.ethernet);

          if (mounted) {
            if (isOnline) {
              // Navigate to online request page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const CreateRequestPage(),
                ),
              );
            } else {
              // Navigate to offline request page
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const OfflineCreateRequestPage(),
                ),
              );
            }
          }
        } catch (e) {
          // On error, default to online page
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateRequestPage(),
              ),
            );
          }
        }
      },
      child: Container(
        width: 55,
        height: 55,
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFD32F2F), Color(0xFFF44336)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD32F2F).withOpacity(0.4),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add,
              color: Colors.white,
              size: 28,
            ),
          ],
        ),
      ),
    );
  }

  void _showRequestTypeSelection() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20),
            topRight: Radius.circular(20),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Create Emergency Request',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Choose how you want to send your emergency request',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.poppins(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              // Online request option
              _buildRequestOption(
                context: context,
                icon: Icons.cloud_upload,
                iconColor: const Color(0xFFD32F2F),
                title: 'Online Request',
                description: 'Full features with images and videos',
                onTap: () {
                  Navigator.pop(context);
                  if (!mounted) return;
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateRequestPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 12),
              // Offline request option
              _buildRequestOption(
                context: context,
                icon: Icons.offline_bolt,
                iconColor: Colors.orange,
                title: 'Offline Request (SMS)',
                description: 'Works without internet • Auto-syncs later',
                badge: 'NEW',
                onTap: () {
                  Navigator.pop(context);
                  if (!mounted) return;
                  setState(() {
                    _currentIndex = 2;
                  });
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OfflineCreateRequestPage(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRequestOption({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String description,
    required VoidCallback onTap,
    String? badge,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Material(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(icon, color: iconColor, size: 28),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            title,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          if (badge != null) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                badge,
                                style: GoogleFonts.poppins(
                                  fontSize: 9,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        description,
                        style: GoogleFonts.poppins(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.arrow_forward_ios,
                    size: 16, color: Colors.grey[400]),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

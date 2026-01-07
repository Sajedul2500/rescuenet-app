import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:RescueNetApp/pages/CreateRequestPage.dart';
import 'package:RescueNetApp/pages/AlertPage.dart';
import 'more_bottom_sheet.dart';
import '../../../emergency_services/presentation/widgets/services_bottom_sheet.dart';
import '../../../emergency_guidance/presentation/screens/emergency_guidance_list_screen.dart';

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

  void _navigateToPage(Widget page, int index) {
    setState(() {
      _currentIndex = index;
    });
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => page),
    );
  }

  void _showNearbyHelp() {
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
                icon: Icons.health_and_safety,
                label: 'Guidance',
                index: 0,
                onTap: () => _navigateToPage(
                  const EmergencyGuidanceListScreen(),
                  0,
                ),
              ),
              _buildNavItem(
                icon: Icons.location_on,
                label: 'Nearby Help',
                index: 1,
                onTap: _showNearbyHelp,
              ),
              _buildCenterFAB(),
              _buildNavItem(
                icon: Icons.warning_amber,
                label: 'Alerts',
                index: 3,
                onTap: () => _navigateToPage(
                  const AlertPage(),
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
  }) {
    final isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFFD32F2F) : Colors.grey[600],
              size: 24,
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
      onTap: () {
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
      child: Container(
        width: 60,
        height: 60,
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
}

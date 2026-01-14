import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../domain/models/dashboard_header_state.dart';
import '../viewmodels/dashboard_header_viewmodel.dart';

/// Context-aware dashboard header with priority-based messaging.
/// Displays the most important readiness message based on user state.
class DashboardHeader extends StatefulWidget {
  final DashboardHeaderViewModel viewModel;
  final VoidCallback onProfileTap;

  const DashboardHeader({
    super.key,
    required this.viewModel,
    required this.onProfileTap,
  });

  @override
  State<DashboardHeader> createState() => _DashboardHeaderState();
}

class _DashboardHeaderState extends State<DashboardHeader> {
  @override
  void initState() {
    super.initState();
    widget.viewModel.addListener(_onViewModelChanged);
  }

  @override
  void dispose() {
    widget.viewModel.removeListener(_onViewModelChanged);
    super.dispose();
  }

  void _onViewModelChanged() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final message = widget.viewModel.currentMessage;
    final state = widget.viewModel.state;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                // Left: App branding
                _buildAppBranding(),

                // Center: Dynamic message
                Expanded(
                  child: _buildCenterMessage(message),
                ),

                // Right: Profile icon
                _buildProfileIcon(),
              ],
            ),
            // Show location and role badge if both verified and has emergency contact
            if (state.isIdentityVerified && state.hasEmergencyContact) ...[
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Location
                  if (state.locationName != null) ...[
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.locationName!,
                        style: GoogleFonts.poppins(
                          fontSize: 11,
                          color: Colors.grey[700],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                  // Role badge
                  if (state.userRole != null) ...[
                    if (state.locationName != null) const SizedBox(width: 8),
                    _buildRoleBadge(state.userRole!),
                  ],
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppBranding() {
    return Image.asset(
      'assets/images/logo.png',
      height: 40,
      fit: BoxFit.contain,
    );
  }

  Widget _buildCenterMessage(HeaderMessage message) {
    if (message.type == HeaderMessageType.none) {
      return const SizedBox.shrink();
    }

    final color = _getMessageColor(message.type);
    final icon = _getMessageIcon(message.type);

    return GestureDetector(
      onTap: message.onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        margin: const EdgeInsets.symmetric(horizontal: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 14, color: color),
            const SizedBox(width: 6),
            Flexible(
              child: Text(
                message.text,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: color,
                ),
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (message.onTap != null) ...[
              const SizedBox(width: 4),
              Icon(Icons.chevron_right, size: 14, color: color),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildProfileIcon() {
    final state = widget.viewModel.state;

    return GestureDetector(
      onTap: widget.onProfileTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          color: Colors.grey[200],
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[300]!,
            width: 2,
          ),
        ),
        child: state.userPhotoUrl != null
            ? ClipOval(
                child: Image.network(
                  state.userPhotoUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildDefaultProfileIcon(),
                ),
              )
            : _buildDefaultProfileIcon(),
      ),
    );
  }

  Widget _buildDefaultProfileIcon() {
    return Icon(
      Icons.person,
      color: Colors.grey[600],
      size: 20,
    );
  }

  Widget _buildRoleBadge(String role) {
    // Determine role display based on verification and role
    final state = widget.viewModel.state;
    String displayRole;
    Color badgeColor;
    IconData roleIcon;

    if (role == 'police') {
      displayRole = 'Police';
      badgeColor = Colors.blue[700]!;
      roleIcon = Icons.local_police;
    } else if (role == 'ambulance' || role == 'ambulance_service') {
      displayRole = 'Ambulance';
      badgeColor = Colors.red[700]!;
      roleIcon = Icons.local_hospital;
    } else if (state.isIdentityVerified && state.hasEmergencyContact) {
      // Verified member becomes volunteer
      displayRole = 'Volunteer';
      badgeColor = Colors.green[700]!;
      roleIcon = Icons.volunteer_activism;
    } else {
      // Unverified or no emergency contact = member
      displayRole = 'Member';
      badgeColor = Colors.grey[600]!;
      roleIcon = Icons.person;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(roleIcon, size: 12, color: badgeColor),
          const SizedBox(width: 4),
          Text(
            displayRole,
            style: GoogleFonts.poppins(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: badgeColor,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMessageColor(HeaderMessageType type) {
    switch (type) {
      case HeaderMessageType.warning:
        return Colors.amber[700]!;
      case HeaderMessageType.action:
        return Colors.blue[700]!;
      case HeaderMessageType.info:
        return Colors.grey[600]!;
      case HeaderMessageType.success:
        return Colors.green[600]!;
      case HeaderMessageType.none:
        return Colors.transparent;
    }
  }

  IconData _getMessageIcon(HeaderMessageType type) {
    switch (type) {
      case HeaderMessageType.warning:
        return Icons.warning_amber_rounded;
      case HeaderMessageType.action:
        return Icons.info_outline;
      case HeaderMessageType.info:
        return Icons.wifi_off;
      case HeaderMessageType.success:
        return Icons.check_circle_outline;
      case HeaderMessageType.none:
        return Icons.circle;
    }
  }
}

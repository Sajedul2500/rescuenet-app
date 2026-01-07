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
        child: Row(
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

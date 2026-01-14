import 'package:flutter/foundation.dart';

/// Represents the current state of the dashboard header.
/// Used to determine which message to display based on priority.
class DashboardHeaderState {
  final bool isIdentityVerified;
  final bool hasEmergencyContact;
  final bool isOffline;
  final String? userName;
  final String? userPhotoUrl;
  final String? userRole;
  final String? locationName;

  const DashboardHeaderState({
    required this.isIdentityVerified,
    required this.hasEmergencyContact,
    required this.isOffline,
    this.userName,
    this.userPhotoUrl,
    this.userRole,
    this.locationName,
  });

  /// Factory for initial/loading state
  factory DashboardHeaderState.initial() {
    return const DashboardHeaderState(
      isIdentityVerified: true,
      hasEmergencyContact: true,
      isOffline: false,
    );
  }

  /// Copy with method for state updates
  DashboardHeaderState copyWith({
    bool? isIdentityVerified,
    bool? hasEmergencyContact,
    bool? isOffline,
    String? userName,
    String? userPhotoUrl,
    String? userRole,
    String? locationName,
  }) {
    return DashboardHeaderState(
      isIdentityVerified: isIdentityVerified ?? this.isIdentityVerified,
      hasEmergencyContact: hasEmergencyContact ?? this.hasEmergencyContact,
      isOffline: isOffline ?? this.isOffline,
      userName: userName ?? this.userName,
      userPhotoUrl: userPhotoUrl ?? this.userPhotoUrl,
      userRole: userRole ?? this.userRole,
      locationName: locationName ?? this.locationName,
    );
  }
}

/// Represents the priority message to display in the header.
class HeaderMessage {
  final String text;
  final HeaderMessageType type;
  final VoidCallback? onTap;

  const HeaderMessage({
    required this.text,
    required this.type,
    this.onTap,
  });

  /// Factory: No message to display
  factory HeaderMessage.none() {
    return const HeaderMessage(
      text: '',
      type: HeaderMessageType.none,
    );
  }

  /// Factory: Identity verification required
  factory HeaderMessage.verifyIdentity(VoidCallback onTap) {
    return HeaderMessage(
      text: 'Verify your ID',
      type: HeaderMessageType.warning,
      onTap: onTap,
    );
  }

  /// Factory: Emergency contact needed
  factory HeaderMessage.addEmergencyContact(VoidCallback onTap) {
    return HeaderMessage(
      text: 'Add emergency contacts',
      type: HeaderMessageType.action,
      onTap: onTap,
    );
  }

  /// Factory: Offline mode
  factory HeaderMessage.offline() {
    return const HeaderMessage(
      text: 'Offline mode active',
      type: HeaderMessageType.info,
    );
  }

  /// Factory: Ready state
  factory HeaderMessage.ready() {
    return const HeaderMessage(
      text: 'Emergency ready',
      type: HeaderMessageType.success,
    );
  }
}

/// Types of header messages with different visual treatments
enum HeaderMessageType {
  none, // No message
  warning, // Critical action needed (red/amber)
  action, // Important action needed (blue)
  info, // Informational (gray)
  success, // Everything is ready (green)
}

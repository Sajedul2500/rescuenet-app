/// Emergency service entity representing a location-based service.
/// Domain layer - pure business logic, no dependencies on external libraries.
class EmergencyService {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String address;
  final double? distance; // Distance from user in km
  final String? phone;
  final String? openingHours;
  final Map<String, dynamic>? additionalInfo;

  const EmergencyService({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.distance,
    this.phone,
    this.openingHours,
    this.additionalInfo,
  });

  /// Creates a copy with updated fields
  EmergencyService copyWith({
    String? id,
    String? name,
    String? type,
    double? latitude,
    double? longitude,
    String? address,
    double? distance,
    String? phone,
    String? openingHours,
    Map<String, dynamic>? additionalInfo,
  }) {
    return EmergencyService(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      address: address ?? this.address,
      distance: distance ?? this.distance,
      phone: phone ?? this.phone,
      openingHours: openingHours ?? this.openingHours,
      additionalInfo: additionalInfo ?? this.additionalInfo,
    );
  }

  @override
  String toString() {
    return 'EmergencyService(id: $id, name: $name, type: $type, distance: ${distance?.toStringAsFixed(2)}km)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is EmergencyService && other.id == id && other.type == type;
  }

  @override
  int get hashCode => id.hashCode ^ type.hashCode;
}

/// Service type constants
class ServiceType {
  static const String police = 'police';
  static const String fire = 'fire';
  static const String medical = 'medical';
  static const String shelter = 'shelter';
  static const String bloodBank = 'blood_bank';
  static const String ngo = 'ngo';
  static const String reliefCenter = 'relief_center';

  /// Get display name for service type
  static String getDisplayName(String type) {
    switch (type) {
      case police:
        return 'Police Stations';
      case fire:
        return 'Fire Stations';
      case medical:
        return 'Medical / Hospitals';
      case shelter:
        return 'Emergency Shelters';
      case bloodBank:
        return 'Blood Banks';
      case ngo:
        return 'NGOs';
      case reliefCenter:
        return 'Relief Centers';
      default:
        return type;
    }
  }

  /// Get icon name for service type
  static String getIconName(String type) {
    switch (type) {
      case police:
        return 'shield';
      case fire:
        return 'fire';
      case medical:
        return 'medical';
      case shelter:
        return 'shelter';
      case bloodBank:
        return 'blood';
      case ngo:
        return 'organization';
      case reliefCenter:
        return 'relief';
      default:
        return 'location';
    }
  }
}

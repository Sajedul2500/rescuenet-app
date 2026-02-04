/// Emergency guidance entity representing a category of emergency situations.
/// Contains instructions and safety information for handling specific emergencies.
class EmergencyGuidance {
  final String id;
  final String category;
  final String title;
  final String description;
  final String iconEmoji;
  final List<String> steps;
  final List<String> dos;
  final List<String> donts;
  final String? emergencyNumber;
  final bool isOfflineAvailable;

  const EmergencyGuidance({
    required this.id,
    required this.category,
    required this.title,
    required this.description,
    required this.iconEmoji,
    required this.steps,
    required this.dos,
    required this.donts,
    this.emergencyNumber,
    this.isOfflineAvailable = true,
  });
}

/// Emergency category types
class EmergencyCategory {
  static const String fire = 'fire';
  static const String flood = 'flood';
  static const String earthquake = 'earthquake';
  static const String medical = 'medical';
  static const String accident = 'accident';
  static const String violence = 'violence';
  static const String naturalDisaster = 'natural_disaster';
  static const String chemicalSpill = 'chemical_spill';

  static List<String> get all => [
        fire,
        flood,
        earthquake,
        medical,
        accident,
        violence,
        naturalDisaster,
        chemicalSpill,
      ];

  static String getDisplayName(String category) {
    switch (category) {
      case fire:
        return 'Fire Emergency';
      case flood:
        return 'Flood';
      case earthquake:
        return 'Earthquake';
      case medical:
        return 'Medical Emergency';
      case accident:
        return 'Road Accident';
      case violence:
        return 'Violence/Crime';
      case naturalDisaster:
        return 'Natural Disaster';
      case chemicalSpill:
        return 'Chemical Spill';
      default:
        return category;
    }
  }

  static String getIcon(String category) {
    switch (category) {
      case fire:
        return '🔥';
      case flood:
        return '🌊';
      case earthquake:
        return '🏚️';
      case medical:
        return '🚑';
      case accident:
        return '🚗';
      case violence:
        return '🚨';
      case naturalDisaster:
        return '⚠️';
      case chemicalSpill:
        return '☢️';
      default:
        return '⚠️';
    }
  }
}

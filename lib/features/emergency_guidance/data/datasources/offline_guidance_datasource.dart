import '../../domain/entities/emergency_guidance.dart';

/// Offline data source containing hardcoded emergency guidance.
/// Content is embedded in the app for offline access.
class OfflineGuidanceDataSource {
  static final List<EmergencyGuidance> _guidanceData = [
    // Fire Emergency
    EmergencyGuidance(
      id: 'fire_001',
      category: EmergencyCategory.fire,
      title: 'Fire Emergency',
      description: 'Steps to take during a fire emergency',
      iconEmoji: '🔥',
      emergencyNumber: '999',
      steps: [
        'Alert everyone nearby by shouting "FIRE!"',
        'If fire is small, use fire extinguisher (P.A.S.S method)',
        'Evacuate immediately if fire is spreading',
        'Feel doors before opening - if hot, use alternate route',
        'Stay low to avoid smoke inhalation',
        'Close doors behind you to slow fire spread',
        'Use stairs, never elevators',
        'Call 999 once you are safe',
        'Do not re-enter the building',
      ],
      dos: [
        'Activate fire alarm if available',
        'Cover your mouth with wet cloth',
        'Know your escape routes',
        'Meet at designated assembly point',
        'Help others if it\'s safe to do so',
        'Stop, drop, and roll if clothes catch fire',
      ],
      donts: [
        'Don\'t use elevators',
        'Don\'t go back for belongings',
        'Don\'t open doors that are hot',
        'Don\'t hide - evacuate immediately',
        'Don\'t waste time gathering items',
        'Don\'t break windows unless necessary',
      ],
    ),

    // Flood
    EmergencyGuidance(
      id: 'flood_001',
      category: EmergencyCategory.flood,
      title: 'Flood Emergency',
      description: 'Actions to take during flooding',
      iconEmoji: '🌊',
      emergencyNumber: '999',
      steps: [
        'Move to higher ground immediately',
        'Avoid walking through moving water',
        'Turn off utilities if instructed',
        'Evacuate if told by authorities',
        'Do not drive through flooded roads',
        'Stay away from downed power lines',
        'Listen to emergency broadcasts',
        'Prepare emergency kit with essentials',
      ],
      dos: [
        'Keep emergency supplies ready',
        'Document property damage',
        'Follow evacuation orders',
        'Keep phone charged',
        'Store important documents in waterproof container',
        'Have a family communication plan',
      ],
      donts: [
        'Don\'t walk through flowing water',
        'Don\'t drive through flood waters',
        'Don\'t touch electrical equipment if wet',
        'Don\'t eat contaminated food',
        'Don\'t return home until authorities say it\'s safe',
      ],
    ),

    // Earthquake
    EmergencyGuidance(
      id: 'earthquake_001',
      category: EmergencyCategory.earthquake,
      title: 'Earthquake Emergency',
      description: 'What to do during and after an earthquake',
      iconEmoji: '🏚️',
      emergencyNumber: '999',
      steps: [
        'DROP to the ground',
        'Take COVER under sturdy furniture',
        'HOLD ON until shaking stops',
        'If outdoors, move to open area',
        'If in car, pull over and stay inside',
        'After shaking, check for injuries',
        'Inspect home for damage',
        'Be ready for aftershocks',
      ],
      dos: [
        'Protect your head and neck',
        'Stay away from windows',
        'Exit building if severely damaged',
        'Use stairs, not elevators',
        'Turn off gas if you smell leak',
        'Listen to emergency broadcasts',
      ],
      donts: [
        'Don\'t use elevators',
        'Don\'t stand in doorways',
        'Don\'t run outside during shaking',
        'Don\'t use matches/lighters if gas leak suspected',
        'Don\'t touch power lines',
      ],
    ),

    // Medical Emergency
    EmergencyGuidance(
      id: 'medical_001',
      category: EmergencyCategory.medical,
      title: 'Medical Emergency',
      description: 'First response to medical emergencies',
      iconEmoji: '🚑',
      emergencyNumber: '999',
      steps: [
        'Assess the situation for safety',
        'Call 999 immediately',
        'Check if person is breathing',
        'Perform CPR if trained and necessary',
        'Control bleeding with pressure',
        'Keep person calm and still',
        'Do not move person if spine injury suspected',
        'Stay on line with emergency services',
      ],
      dos: [
        'Check for medical alert bracelet',
        'Note time symptoms started',
        'Gather medical history if possible',
        'Keep airway clear',
        'Cover person with blanket to prevent shock',
        'Reassure the person',
      ],
      donts: [
        'Don\'t give food or drinks',
        'Don\'t move injured person unnecessarily',
        'Don\'t remove embedded objects',
        'Don\'t try procedures you\'re not trained for',
        'Don\'t leave person alone',
      ],
    ),

    // Road Accident
    EmergencyGuidance(
      id: 'accident_001',
      category: EmergencyCategory.accident,
      title: 'Road Accident',
      description: 'Steps after a traffic accident',
      iconEmoji: '🚗',
      emergencyNumber: '999',
      steps: [
        'Stop immediately and check for injuries',
        'Call 999 if anyone is hurt',
        'Turn on hazard lights',
        'Set up warning triangles if safe',
        'Do not move injured unless in immediate danger',
        'Exchange information with other driver',
        'Take photos of scene and damage',
        'Report to police within 24 hours',
      ],
      dos: [
        'Check on all passengers',
        'Get witness contact information',
        'Note exact location and time',
        'Stay calm and polite',
        'Move to safe location if possible',
      ],
      donts: [
        'Don\'t admit fault at scene',
        'Don\'t leave scene without exchanging info',
        'Don\'t sign documents you don\'t understand',
        'Don\'t argue with other driver',
        'Don\'t post on social media immediately',
      ],
    ),

    // Violence/Crime
    EmergencyGuidance(
      id: 'violence_001',
      category: EmergencyCategory.violence,
      title: 'Violence/Crime Emergency',
      description: 'Safety actions during violent situations',
      iconEmoji: '🚨',
      emergencyNumber: '999',
      steps: [
        'Remove yourself from danger immediately',
        'Call 999 when safe to do so',
        'Lock doors and windows',
        'Go to a safe location',
        'Do not confront the aggressor',
        'Preserve evidence if possible',
        'Write down details while fresh',
        'Seek medical attention if injured',
      ],
      dos: [
        'Trust your instincts',
        'Alert neighbors if safe',
        'Document injuries with photos',
        'Contact support services',
        'File police report',
      ],
      donts: [
        'Don\'t provoke attacker',
        'Don\'t return to dangerous location alone',
        'Don\'t destroy evidence',
        'Don\'t confront suspects',
      ],
    ),

    // Natural Disaster
    EmergencyGuidance(
      id: 'disaster_001',
      category: EmergencyCategory.naturalDisaster,
      title: 'Natural Disaster',
      description: 'General natural disaster preparedness',
      iconEmoji: '⚠️',
      emergencyNumber: '999',
      steps: [
        'Follow official evacuation orders',
        'Gather emergency supplies',
        'Turn off utilities if instructed',
        'Secure your property',
        'Move to designated shelter',
        'Stay informed via radio/official sources',
        'Keep emergency kit accessible',
        'Have family communication plan ready',
      ],
      dos: [
        'Keep important documents safe',
        'Charge all devices',
        'Fill bathtubs with water',
        'Have cash on hand',
        'Know your evacuation routes',
      ],
      donts: [
        'Don\'t ignore warnings',
        'Don\'t wait until last minute',
        'Don\'t spread unverified information',
        'Don\'t return until authorities say safe',
      ],
    ),

    // Chemical Spill
    EmergencyGuidance(
      id: 'chemical_001',
      category: EmergencyCategory.chemicalSpill,
      title: 'Chemical Spill',
      description: 'Response to hazardous material incidents',
      iconEmoji: '☢️',
      emergencyNumber: '999',
      steps: [
        'Evacuate the area immediately',
        'Call 999 and report chemical type if known',
        'Move upwind and uphill from spill',
        'Remove contaminated clothing',
        'Rinse exposed skin with water',
        'Avoid contact with spill or vapors',
        'Follow decontamination instructions',
        'Seek medical attention',
      ],
      dos: [
        'Alert others in the area',
        'Close windows and doors',
        'Turn off ventilation systems',
        'Follow official instructions',
      ],
      donts: [
        'Don\'t touch or walk through spill',
        'Don\'t eat or drink anything',
        'Don\'t return to area until cleared',
        'Don\'t try to clean up yourself',
      ],
    ),
  ];

  /// Get all guidance
  Future<List<EmergencyGuidance>> getAllGuidance() async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    return List.unmodifiable(_guidanceData);
  }

  /// Get guidance by category
  Future<EmergencyGuidance?> getGuidanceByCategory(String category) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      return _guidanceData.firstWhere((g) => g.category == category);
    } catch (e) {
      return null;
    }
  }

  /// Search guidance
  Future<List<EmergencyGuidance>> searchGuidance(String query) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    return _guidanceData.where((g) {
      return g.title.toLowerCase().contains(lowerQuery) ||
          g.description.toLowerCase().contains(lowerQuery) ||
          g.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

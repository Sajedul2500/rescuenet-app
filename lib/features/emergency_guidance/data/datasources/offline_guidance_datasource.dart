import '../../domain/entities/emergency_guidance.dart';

class OfflineGuidanceDataSource {
  // English guidance data
  static final List<EmergencyGuidance> _guidanceDataEn = [
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

  // Bangla guidance data
  static final List<EmergencyGuidance> _guidanceDataBn = [
    // Fire Emergency - অগ্নিকাণ্ড জরুরি
    EmergencyGuidance(
      id: 'fire_001',
      category: EmergencyCategory.fire,
      title: 'অগ্নিকাণ্ড জরুরি',
      description: 'অগ্নিকাণ্ডের সময় করণীয়',
      iconEmoji: '🔥',
      emergencyNumber: '999',
      steps: [
        '"আগুন!" চিৎকার করে আশেপাশের সবাইকে সতর্ক করুন',
        'আগুন ছোট হলে, অগ্নিনির্বাপক যন্ত্র ব্যবহার করুন (P.A.S.S পদ্ধতি)',
        'আগুন ছড়িয়ে পড়লে অবিলম্বে সরে যান',
        'দরজা খোলার আগে অনুভব করুন - গরম হলে বিকল্প পথ ব্যবহার করুন',
        'ধোঁয়া শ্বাস নেওয়া এড়াতে নিচু হয়ে থাকুন',
        'আগুন ছড়ানো কমাতে পেছনে দরজা বন্ধ করুন',
        'সিঁড়ি ব্যবহার করুন, কখনও লিফট নয়',
        'নিরাপদে পৌঁছানোর পর ৯৯৯ কল করুন',
        'ভবনে পুনরায় প্রবেশ করবেন না',
      ],
      dos: [
        'ফায়ার অ্যালার্ম সক্রিয় করুন যদি থাকে',
        'ভেজা কাপড় দিয়ে মুখ ঢাকুন',
        'আপনার পালানোর পথ জানুন',
        'নির্ধারিত সমাবেশ স্থানে মিলিত হন',
        'নিরাপদ হলে অন্যদের সাহায্য করুন',
        'কাপড়ে আগুন লাগলে থামুন, মাটিতে শুয়ে পড়ুন এবং গড়িয়ে যান',
      ],
      donts: [
        'লিফট ব্যবহার করবেন না',
        'জিনিসপত্রের জন্য ফিরে যাবেন না',
        'গরম দরজা খুলবেন না',
        'লুকাবেন না - অবিলম্বে সরে যান',
        'জিনিস সংগ্রহ করতে সময় নষ্ট করবেন না',
        'প্রয়োজন না হলে জানালা ভাঙবেন না',
      ],
    ),

    // Flood - বন্যা
    EmergencyGuidance(
      id: 'flood_001',
      category: EmergencyCategory.flood,
      title: 'বন্যা জরুরি অবস্থা',
      description: 'বন্যার সময় করণীয়',
      iconEmoji: '🌊',
      emergencyNumber: '999',
      steps: [
        'অবিলম্বে উঁচু স্থানে যান',
        'প্রবাহিত পানিতে হাঁটা এড়িয়ে চলুন',
        'নির্দেশ দিলে ইউটিলিটি বন্ধ করুন',
        'কর্তৃপক্ষ নির্দেশ দিলে সরে যান',
        'প্লাবিত রাস্তা দিয়ে গাড়ি চালাবেন না',
        'পড়ে থাকা বিদ্যুৎ তার থেকে দূরে থাকুন',
        'জরুরি সম্প্রচার শুনুন',
        'প্রয়োজনীয় জিনিস সহ জরুরি কিট প্রস্তুত করুন',
      ],
      dos: [
        'জরুরি সরবরাহ প্রস্তুত রাখুন',
        'সম্পত্তির ক্ষতির নথি রাখুন',
        'সরিয়ে নেওয়ার আদেশ অনুসরণ করুন',
        'ফোন চার্জ রাখুন',
        'গুরুত্বপূর্ণ নথি জলরোধী পাত্রে রাখুন',
        'পরিবারের যোগাযোগ পরিকল্পনা রাখুন',
      ],
      donts: [
        'প্রবাহিত পানিতে হাঁটবেন না',
        'বন্যার পানিতে গাড়ি চালাবেন না',
        'ভিজে থাকলে বৈদ্যুতিক যন্ত্র স্পর্শ করবেন না',
        'দূষিত খাবার খাবেন না',
        'কর্তৃপক্ষ নিরাপদ বলার আগে বাড়ি ফিরবেন না',
      ],
    ),

    // Earthquake - ভূমিকম্প
    EmergencyGuidance(
      id: 'earthquake_001',
      category: EmergencyCategory.earthquake,
      title: 'ভূমিকম্প জরুরি অবস্থা',
      description: 'ভূমিকম্পের সময় এবং পরে করণীয়',
      iconEmoji: '🏚️',
      emergencyNumber: '999',
      steps: [
        'মাটিতে শুয়ে পড়ুন',
        'মজবুত আসবাবপত্রের নিচে আশ্রয় নিন',
        'কাঁপুনি বন্ধ না হওয়া পর্যন্ত ধরে রাখুন',
        'বাইরে থাকলে খোলা জায়গায় যান',
        'গাড়িতে থাকলে পাশে থামুন এবং ভেতরে থাকুন',
        'কাঁপুনির পর আঘাত পরীক্ষা করুন',
        'বাড়ির ক্ষতি পরিদর্শন করুন',
        'আফটারশকের জন্য প্রস্তুত থাকুন',
      ],
      dos: [
        'আপনার মাথা এবং ঘাড় রক্ষা করুন',
        'জানালা থেকে দূরে থাকুন',
        'মারাত্মক ক্ষতিগ্রস্ত হলে ভবন ছাড়ুন',
        'সিঁড়ি ব্যবহার করুন, লিফট নয়',
        'গ্যাসের গন্ধ পেলে বন্ধ করুন',
        'জরুরি সম্প্রচার শুনুন',
      ],
      donts: [
        'লিফট ব্যবহার করবেন না',
        'দরজার ফ্রেমে দাঁড়াবেন না',
        'কাঁপানোর সময় বাইরে দৌড়াবেন না',
        'গ্যাস লিক সন্দেহ হলে ম্যাচ/লাইটার ব্যবহার করবেন না',
        'বিদ্যুৎ তার স্পর্শ করবেন না',
      ],
    ),

    // Medical Emergency - চিকিৎসা জরুরি
    EmergencyGuidance(
      id: 'medical_001',
      category: EmergencyCategory.medical,
      title: 'চিকিৎসা জরুরি অবস্থা',
      description: 'চিকিৎসা জরুরি অবস্থায় প্রথম প্রতিক্রিয়া',
      iconEmoji: '🚑',
      emergencyNumber: '999',
      steps: [
        'নিরাপত্তার জন্য পরিস্থিতি মূল্যায়ন করুন',
        'অবিলম্বে ৯৯৯ কল করুন',
        'ব্যক্তি শ্বাস নিচ্ছে কিনা পরীক্ষা করুন',
        'প্রশিক্ষিত এবং প্রয়োজন হলে CPR করুন',
        'চাপ দিয়ে রক্তপাত নিয়ন্ত্রণ করুন',
        'ব্যক্তিকে শান্ত এবং স্থির রাখুন',
        'মেরুদণ্ডের আঘাত সন্দেহ হলে নাড়াবেন না',
        'জরুরি সেবার সাথে লাইনে থাকুন',
      ],
      dos: [
        'মেডিকেল অ্যালার্ট ব্রেসলেট পরীক্ষা করুন',
        'লক্ষণ শুরু হওয়ার সময় নোট করুন',
        'সম্ভব হলে চিকিৎসা ইতিহাস সংগ্রহ করুন',
        'শ্বাসনালী পরিষ্কার রাখুন',
        'শক প্রতিরোধে কম্বল দিয়ে ঢেকে দিন',
        'ব্যক্তিকে আশ্বস্ত করুন',
      ],
      donts: [
        'খাবার বা পানীয় দেবেন না',
        'অপ্রয়োজনে আহত ব্যক্তিকে নাড়াবেন না',
        'প্রবেশিত বস্তু সরাবেন না',
        'প্রশিক্ষণ নেই এমন পদ্ধতি চেষ্টা করবেন না',
        'ব্যক্তিকে একা রাখবেন না',
      ],
    ),

    // Road Accident - সড়ক দুর্ঘটনা
    EmergencyGuidance(
      id: 'accident_001',
      category: EmergencyCategory.accident,
      title: 'সড়ক দুর্ঘটনা',
      description: 'যানবাহন দুর্ঘটনার পরে করণীয়',
      iconEmoji: '🚗',
      emergencyNumber: '999',
      steps: [
        'অবিলম্বে থামুন এবং আঘাত পরীক্ষা করুন',
        'কেউ আহত হলে ৯৯৯ কল করুন',
        'হ্যাজার্ড লাইট চালু করুন',
        'নিরাপদ হলে সতর্কীকরণ ত্রিভুজ স্থাপন করুন',
        'তাৎক্ষণিক বিপদে না থাকলে আহতদের নাড়াবেন না',
        'অন্য ড্রাইভারের সাথে তথ্য বিনিময় করুন',
        'ঘটনাস্থল এবং ক্ষতির ফটো তুলুন',
        '২৪ ঘন্টার মধ্যে পুলিশে রিপোর্ট করুন',
      ],
      dos: [
        'সকল যাত্রী পরীক্ষা করুন',
        'সাক্ষীর যোগাযোগ তথ্য নিন',
        'সঠিক অবস্থান এবং সময় নোট করুন',
        'শান্ত এবং ভদ্র থাকুন',
        'সম্ভব হলে নিরাপদ স্থানে যান',
      ],
      donts: [
        'ঘটনাস্থলে দোষ স্বীকার করবেন না',
        'তথ্য বিনিময় না করে ছেড়ে যাবেন না',
        'বুঝতে না পারলে নথিতে স্বাক্ষর করবেন না',
        'অন্য ড্রাইভারের সাথে তর্ক করবেন না',
        'অবিলম্বে সোশ্যাল মিডিয়ায় পোস্ট করবেন না',
      ],
    ),

    // Violence/Crime - সহিংসতা/অপরাধ
    EmergencyGuidance(
      id: 'violence_001',
      category: EmergencyCategory.violence,
      title: 'সহিংসতা/অপরাধ জরুরি অবস্থা',
      description: 'সহিংস পরিস্থিতিতে নিরাপত্তা ব্যবস্থা',
      iconEmoji: '🚨',
      emergencyNumber: '999',
      steps: [
        'অবিলম্বে নিজেকে বিপদ থেকে সরিয়ে নিন',
        'নিরাপদ হলে ৯৯৯ কল করুন',
        'দরজা এবং জানালা লক করুন',
        'নিরাপদ স্থানে যান',
        'আক্রমণকারীর মুখোমুখি হবেন না',
        'সম্ভব হলে প্রমাণ সংরক্ষণ করুন',
        'তাজা থাকতে বিবরণ লিখে রাখুন',
        'আহত হলে চিকিৎসা নিন',
      ],
      dos: [
        'আপনার প্রবৃত্তি বিশ্বাস করুন',
        'নিরাপদ হলে প্রতিবেশীদের সতর্ক করুন',
        'আঘাতের ফটো দিয়ে নথিভুক্ত করুন',
        'সহায়তা সেবার সাথে যোগাযোগ করুন',
        'পুলিশ রিপোর্ট দাখিল করুন',
      ],
      donts: [
        'আক্রমণকারীকে উসকানি দেবেন না',
        'একা বিপজ্জনক স্থানে ফিরবেন না',
        'প্রমাণ ধ্বংস করবেন না',
        'সন্দেহভাজনদের মুখোমুখি হবেন না',
      ],
    ),

    // Natural Disaster - প্রাকৃতিক দুর্যোগ
    EmergencyGuidance(
      id: 'disaster_001',
      category: EmergencyCategory.naturalDisaster,
      title: 'প্রাকৃতিক দুর্যোগ',
      description: 'সাধারণ প্রাকৃতিক দুর্যোগ প্রস্তুতি',
      iconEmoji: '⚠️',
      emergencyNumber: '999',
      steps: [
        'সরকারি সরিয়ে নেওয়ার আদেশ অনুসরণ করুন',
        'জরুরি সরবরাহ সংগ্রহ করুন',
        'নির্দেশ দিলে ইউটিলিটি বন্ধ করুন',
        'আপনার সম্পত্তি সুরক্ষিত করুন',
        'নির্ধারিত আশ্রয়কেন্দ্রে যান',
        'রেডিও/সরকারি সূত্র দ্বারা অবহিত থাকুন',
        'জরুরি কিট সহজলভ্য রাখুন',
        'পরিবারের যোগাযোগ পরিকল্পনা প্রস্তুত রাখুন',
      ],
      dos: [
        'গুরুত্বপূর্ণ নথি নিরাপদ রাখুন',
        'সব ডিভাইস চার্জ করুন',
        'বাথটাব পানিতে পূর্ণ করুন',
        'নগদ অর্থ রাখুন',
        'আপনার সরিয়ে নেওয়ার পথ জানুন',
      ],
      donts: [
        'সতর্কতা উপেক্ষা করবেন না',
        'শেষ মুহূর্ত পর্যন্ত অপেক্ষা করবেন না',
        'যাচাই না করে তথ্য ছড়াবেন না',
        'কর্তৃপক্ষ নিরাপদ বলার আগে ফিরবেন না',
      ],
    ),

    // Chemical Spill - রাসায়নিক ছিটকে পড়া
    EmergencyGuidance(
      id: 'chemical_001',
      category: EmergencyCategory.chemicalSpill,
      title: 'রাসায়নিক ছিটকে পড়া',
      description: 'বিপজ্জনক পদার্থ ঘটনার প্রতিক্রিয়া',
      iconEmoji: '☢️',
      emergencyNumber: '999',
      steps: [
        'অবিলম্বে এলাকা ছেড়ে চলে যান',
        '৯৯৯ কল করুন এবং জানা থাকলে রাসায়নিকের ধরন জানান',
        'ছিটকে পড়া থেকে বাতাসের দিকে এবং উঁচুতে সরে যান',
        'দূষিত কাপড় খুলে ফেলুন',
        'উন্মুক্ত ত্বক পানি দিয়ে ধুয়ে ফেলুন',
        'ছিটকে পড়া বা বাষ্পের সংস্পর্শ এড়িয়ে চলুন',
        'দূষণমুক্তকরণ নির্দেশনা অনুসরণ করুন',
        'চিকিৎসা সহায়তা নিন',
      ],
      dos: [
        'এলাকার অন্যদের সতর্ক করুন',
        'জানালা এবং দরজা বন্ধ করুন',
        'বায়ুচলাচল ব্যবস্থা বন্ধ করুন',
        'সরকারি নির্দেশনা অনুসরণ করুন',
      ],
      donts: [
        'ছিটকে পড়া স্পর্শ বা দিয়ে হাঁটবেন না',
        'কিছু খাবেন বা পান করবেন না',
        'পরিষ্কার না হওয়া পর্যন্ত এলাকায় ফিরবেন না',
        'নিজে পরিষ্কার করার চেষ্টা করবেন না',
      ],
    ),
  ];

  /// Get all guidance based on language
  Future<List<EmergencyGuidance>> getAllGuidance(
      {String languageCode = 'en'}) async {
    // Simulate async operation
    await Future.delayed(const Duration(milliseconds: 100));
    final data = languageCode == 'bn' ? _guidanceDataBn : _guidanceDataEn;
    return List.unmodifiable(data);
  }

  /// Get guidance by category with language support
  Future<EmergencyGuidance?> getGuidanceByCategory(
    String category, {
    String languageCode = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 50));
    try {
      final data = languageCode == 'bn' ? _guidanceDataBn : _guidanceDataEn;
      return data.firstWhere((g) => g.category == category);
    } catch (e) {
      return null;
    }
  }

  /// Search guidance with language support
  Future<List<EmergencyGuidance>> searchGuidance(
    String query, {
    String languageCode = 'en',
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final lowerQuery = query.toLowerCase();
    final data = languageCode == 'bn' ? _guidanceDataBn : _guidanceDataEn;
    return data.where((g) {
      return g.title.toLowerCase().contains(lowerQuery) ||
          g.description.toLowerCase().contains(lowerQuery) ||
          g.category.toLowerCase().contains(lowerQuery);
    }).toList();
  }
}

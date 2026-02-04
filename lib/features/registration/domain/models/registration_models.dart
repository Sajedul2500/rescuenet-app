/// Registration step status from backend
enum RegistrationStep {
  step1(1),
  step2(2),
  step3(3),
  completed(0);

  final int value;
  const RegistrationStep(this.value);

  static RegistrationStep fromInt(int value) {
    switch (value) {
      case 1:
        return RegistrationStep.step1;
      case 2:
        return RegistrationStep.step2;
      case 3:
        return RegistrationStep.step3;
      case 0:
        return RegistrationStep.completed;
      default:
        return RegistrationStep.step1;
    }
  }
}

/// Registration status response from backend
class RegistrationStatus {
  final RegistrationStep step;
  final bool isCompleted;
  final String? message;

  RegistrationStatus({
    required this.step,
    required this.isCompleted,
    this.message,
  });

  factory RegistrationStatus.fromJson(Map<String, dynamic> json) {
    final stepValue = json['step'] as int? ?? 1;
    final completed = json['completed'] as bool? ?? false;

    return RegistrationStatus(
      step: completed
          ? RegistrationStep.completed
          : RegistrationStep.fromInt(stepValue),
      isCompleted: completed,
      message: json['message'] as String?,
    );
  }
}

/// Step 1 registration data
class Step1Data {
  final String fullName;
  final String gender;
  final String? email;
  final String? phone;
  final String password;
  final String passwordConfirmation;

  Step1Data({
    required this.fullName,
    required this.gender,
    this.email,
    this.phone,
    required this.password,
    required this.passwordConfirmation,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'name': fullName,
      'gender': gender.toLowerCase(), // Send as lowercase: male, female, other
      'password': password,
      'password_confirmation': passwordConfirmation,
    };

    // Only include email if provided
    if (email != null && email!.isNotEmpty) {
      data['email'] = email;
    }

    // Only include phone if provided
    if (phone != null && phone!.isNotEmpty) {
      data['phone'] = phone;
    }
    return data;
  }
}

/// Step 1 registration response
class Step1Response {
  final String registrationToken;
  final String authToken;
  final String userId;
  final String message;

  Step1Response({
    required this.registrationToken,
    required this.authToken,
    required this.userId,
    required this.message,
  });

  factory Step1Response.fromJson(Map<String, dynamic> json) {
    return Step1Response(
      registrationToken:
          (json['registration_token'] ?? json['token'] ?? '').toString(),
      authToken: (json['auth_token'] ?? json['token'] ?? '').toString(),
      userId: (json['user_id'] ?? '').toString(),
      message: (json['message'] ?? 'Registration step 1 completed').toString(),
    );
  }
}

/// Step 2 registration data (verification documents)
class Step2Data {
  final dynamic nidFrontImage; // Can be File or null
  final dynamic nidBackImage; // Can be File or null
  final dynamic selfieWithNidImage; // Can be File or null

  Step2Data({
    this.nidFrontImage,
    this.nidBackImage,
    this.selfieWithNidImage,
  });

  // Note: For file uploads, we don't use toJson()
  // Instead, we create FormData directly in the service
}

/// Step 3 registration data (emergency contacts and location)
class Step3Data {
  final String emergencyContactName;
  final String emergencyContactPhone;
  final String emergencyContactRelation;
  final double latitude;
  final double longitude;
  final String? location;

  Step3Data({
    required this.emergencyContactName,
    required this.emergencyContactPhone,
    required this.emergencyContactRelation,
    required this.latitude,
    required this.longitude,
    this.location,
  });

  Map<String, dynamic> toJson() => {
        'name': emergencyContactName,
        'phone': emergencyContactPhone,
        'relationship': emergencyContactRelation,
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
      };
}

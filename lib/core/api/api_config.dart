/// API Configuration Constants
class ApiConfig {
  static const String baseUrl = 'http://YOUR_API_URL/api/v1';

  // Authentication Endpoints
  static const String login = '/login';
  static const String logout = '/logout';

  // Dashboard Endpoint
  static const String dashboard = '/dashboard';

  // Help Requests Endpoints
  static const String helpRequests = '/help-requests';

  // Flag Reports Endpoint
  static const String flagReports = '/flag-reports';

  // User Profile Endpoints
  static const String profile = '/profile';
  static const String updatePassword = '/update-password';
  static const String verifyProfile = '/verify-profile';

  // Notification Endpoints
  static const String notifications = '/notifications';

  // Registration Endpoints
  static const String registerStep1 = '/register/step1';
  static const String registerStep2 = '/register/step2';
  static const String registerStep3 = '/register/step3';
  static const String registerSkipStep2 = '/register/skip-step2';
  static const String registerStatus = '/register/status';
  static const String completeRegistration = '/complete-registration';

  // More Services Endpoints
  static const String emergencyContacts = '/more-service/emergency-contacts';
  static const String nearbyVolunteers = '/more-service/nearby-volunteers';
  static const String userOverview =
      '/more-service/user'; // Append /{user_id}/overview

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

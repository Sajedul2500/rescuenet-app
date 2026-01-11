/// API Configuration Constants
class ApiConfig {
  // ⚠️ IMPORTANT: Configure the correct base URL for your environment
  //
  // 📱 Android Emulator: Use 10.0.2.2 (maps to host machine's localhost)
  //    Example: 'http://10.0.2.2:8000/api/v1'
  //
  // 📲 Physical Device: Use your computer's local IP address
  //    Find your IP:
  //      - Windows: Open CMD, run 'ipconfig', look for IPv4 Address
  //      - Mac/Linux: Open Terminal, run 'ifconfig' or 'ip addr'
  //    Example: 'http://192.168.1.100:8000/api/v1'
  //
  // 🌐 Production: Use your actual domain
  //    Example: 'https://api.rescuenet.com/api/v1'
  //
  // 🔧 Make sure your Laravel backend is running on port 8000:
  //    Run: php artisan serve --host=0.0.0.0 --port=8000

  static const String baseUrl = 'http://192.168.68.119:8000/api/v1';

  // Authentication Endpoints
  static const String login = '/login';
  static const String logout = '/logout';

  // Dashboard Endpoint
  static const String dashboard = '/dashboard';

  // Help Requests Endpoints
  static const String helpRequests = '/help-requests';

  // User Profile Endpoints
  static const String profile = '/profile';
  static const String updatePassword = '/update-password';
  static const String verifyProfile = '/verify-profile';

  // Registration Endpoints
  static const String registerStep1 = '/register/step1';
  static const String registerStep2 = '/register/step2';
  static const String registerStep3 = '/register/step3';
  static const String registerSkipStep2 = '/register/skip-step2';
  static const String registerStatus = '/register/status';

  // Timeouts
  static const Duration connectionTimeout = Duration(seconds: 30);
  static const Duration receiveTimeout = Duration(seconds: 30);
}

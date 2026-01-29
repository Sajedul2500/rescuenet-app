import 'dart:io';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

/// SMS service for sending emergency requests via SMS (Android only)
class SmsService {
  static const MethodChannel _channel = MethodChannel('rescuenet/sms');

  // Predefined emergency contact number
  // TODO: Replace with actual emergency number or make configurable
  static const String emergencyNumber = '+8801234567890';

  /// Check if SMS permission is granted
  static Future<bool> hasSmsPermission() async {
    if (!Platform.isAndroid) return false;

    final status = await Permission.sms.status;
    return status.isGranted;
  }

  /// Request SMS permission (one-time, non-aggressive)
  static Future<bool> requestSmsPermission() async {
    if (!Platform.isAndroid) return false;

    // Check if already granted
    if (await hasSmsPermission()) return true;

    // Request permission
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  /// Send emergency SMS with request details
  /// Returns true if SMS was sent successfully
  static Future<bool> sendEmergencySms({
    required String requestType,
    required String description,
    required double latitude,
    required double longitude,
    String? locationName,
  }) async {
    if (!Platform.isAndroid) {
      print('SMS service is only available on Android');
      return false;
    }

    try {
      // Check permission first
      if (!await hasSmsPermission()) {
        print('SMS permission not granted');
        return false;
      }

      // Format the SMS message
      final timestamp = DateTime.now().toIso8601String();
      final mapsLink = 'https://maps.google.com/?q=$latitude,$longitude';

      final message = '''
🚨 RESCUENET EMERGENCY REQUEST 🚨

REQUEST TYPE: $requestType
DESCRIPTION: $description
${locationName != null ? 'LOCATION: $locationName\n' : ''}
COORDINATES: $latitude, $longitude
MAP: $mapsLink
TIME: $timestamp

Please respond immediately.
''';

      // Send SMS via platform channel
      final result = await _channel.invokeMethod('sendSms', {
        'phoneNumber': emergencyNumber,
        'message': message,
      });

      return result == true;
    } on PlatformException catch (e) {
      print('Failed to send SMS: ${e.message}');
      return false;
    } catch (e) {
      print('Error sending SMS: $e');
      return false;
    }
  }

  /// Check if device can send SMS
  static Future<bool> canSendSms() async {
    if (!Platform.isAndroid) return false;

    try {
      final result = await _channel.invokeMethod('canSendSms');
      return result == true;
    } catch (e) {
      print('Error checking SMS capability: $e');
      return false;
    }
  }
}

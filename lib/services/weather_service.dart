import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // Get your free API key from https://openweathermap.org/api
  static const String _apiKey = 'YOUR_API_KEY_HERE'; // Replace with actual key
  static const String _baseUrl = 'https://api.openweathermap.org/data/2.5';

  /// Get current weather by coordinates
  static Future<Map<String, dynamic>?> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final url = Uri.parse(
        '$_baseUrl/weather?lat=$latitude&lon=$longitude&appid=$_apiKey&units=metric',
      );

      final response = await http.get(url).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Request timeout');
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return _formatWeatherData(data);
      } else {
        throw Exception('Failed to fetch weather: ${response.statusCode}');
      }
    } catch (e) {
      print('Weather error: $e');
      return null;
    }
  }

  /// Format weather data
  static Map<String, dynamic> _formatWeatherData(Map<String, dynamic> data) {
    return {
      'temperature': data['main']['temp']?.toDouble() ?? 0.0,
      'feelsLike': data['main']['feels_like']?.toDouble() ?? 0.0,
      'tempMin': data['main']['temp_min']?.toDouble() ?? 0.0,
      'tempMax': data['main']['temp_max']?.toDouble() ?? 0.0,
      'humidity': data['main']['humidity'] ?? 0,
      'pressure': data['main']['pressure'] ?? 0,
      'description': data['weather']?[0]?['description'] ?? 'Unknown',
      'main': data['weather']?[0]?['main'] ?? 'Unknown',
      'icon': data['weather']?[0]?['icon'] ?? '01d',
      'windSpeed': data['wind']?['speed']?.toDouble() ?? 0.0,
      'cityName': data['name'] ?? 'Unknown',
      'country': data['sys']?['country'] ?? '',
      'sunrise': data['sys']?['sunrise'] ?? 0,
      'sunset': data['sys']?['sunset'] ?? 0,
    };
  }

  /// Get weather icon emoji
  static String getWeatherEmoji(String main) {
    switch (main.toLowerCase()) {
      case 'clear':
        return '☀️';
      case 'clouds':
        return '☁️';
      case 'rain':
      case 'drizzle':
        return '🌧️';
      case 'thunderstorm':
        return '⛈️';
      case 'snow':
        return '❄️';
      case 'mist':
      case 'fog':
      case 'haze':
        return '🌫️';
      default:
        return '🌤️';
    }
  }

  /// Get weather alerts (if any severe weather)
  static String? getWeatherAlert(Map<String, dynamic> weather) {
    final main = weather['main']?.toString().toLowerCase() ?? '';
    final temp = weather['temperature'] as double? ?? 0.0;

    if (main.contains('thunderstorm')) {
      return '⚠️ Thunderstorm Alert: Stay indoors and avoid travel';
    } else if (main.contains('rain') && weather['humidity'] > 80) {
      return '⚠️ Heavy Rain Alert: Flood risk, stay cautious';
    } else if (temp > 38) {
      return '🌡️ Heat Wave Alert: Stay hydrated and avoid sun exposure';
    } else if (temp < 5) {
      return '❄️ Cold Alert: Dress warmly';
    }
    return null;
  }
}

import 'dart:convert';
import 'package:http/http.dart' as http;

import 'logger.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Start a pause timer
  Future<Map<String, dynamic>?> startPause({
    required String type, // "shortBreak" or "longBreak"
    required int minutes,
    required int cycle,
    required int pauseNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pause/start'),
        headers: _headers,
        body: jsonEncode({
          'type': type,
          'minutes': minutes,
          'cycle': cycle,
          'pauseNumber': pauseNumber,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      Logger.log('Error starting pause: $e');
      return null;
    }
  }

  // Start work session
  Future<Map<String, dynamic>?> startWork({
    required int cycle,
    required int interval,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/work/start'),
        headers: _headers,
        body: jsonEncode({
          'cycle': cycle,
          'interval': interval,
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Logger.log('Failed to start work: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Logger.log('Error starting work: $e');
      return null;
    }
  }

  // Cancel current pause
  Future<Map<String, dynamic>?> cancelPause() async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pause/cancel'),
        headers: _headers,
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Logger.log('Failed to cancel pause: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Logger.log('Error cancelling pause: $e');
      return null;
    }
  }
}

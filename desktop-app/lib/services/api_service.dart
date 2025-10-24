import 'dart:convert';
import 'package:http/http.dart' as http;

import 'logger.dart';

enum PauseType { shortBreak, longBreak }

class ApiService {
  static const String baseUrl = 'http://localhost:8080';

  Map<String, String> get _headers => {
    'Content-Type': 'application/json',
  };

  // Start a pause timer
  Future<Map<String, dynamic>?> startPause({
    required PauseType type,
    required int minutes,
    required int cycle,
    required int pauseNumber,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pause/start'),
        headers: _headers,
        body: jsonEncode({
          'type': type.name,
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
  Future<Map<String, dynamic>?> startWork() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/work/start'), headers: _headers);

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

  Future<Map<String, dynamic>?> endWork() async {
    try {
      final response = await http.post(Uri.parse('$baseUrl/api/work/end'), headers: _headers);
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        Logger.log('Failed to end work: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      Logger.log('Error ending work: $e');
      return null;
    }
  }

  // Cancel current pause
  Future<Map<String, dynamic>?> endPause({required PauseType pauseType}) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/api/pause/end'),
        headers: _headers,
        body: jsonEncode({
          'pauseType': pauseType.name,
        }),
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

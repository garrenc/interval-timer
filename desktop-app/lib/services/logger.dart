import 'dart:developer' as developer;

class Logger {
  static void log(String message) {
    var currentTime = DateTime.now().toIso8601String();
    developer.log('[$currentTime] $message');
  }
}

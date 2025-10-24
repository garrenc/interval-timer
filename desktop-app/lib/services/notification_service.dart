import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications = FlutterLocalNotificationsPlugin();
  bool _isInitialized = false;

  Future<void> initialize() async {
    if (_isInitialized) return;

    const initializationSettings = InitializationSettings(
      macOS: DarwinInitializationSettings(),
      windows: WindowsInitializationSettings(appName: 'Interval timer', appUserModelId: 'Com.Garrenc.IntervalTimer', guid: 'd49b0314-ee7a-4626-bf69-97cdb8a9913f'),
    );

    await _notifications.initialize(initializationSettings);

    _isInitialized = true;
  }

  Future<void> showWorkStartedNotification() async {
    if (!_isInitialized) return;

    await _notifications.show(
      1,
      'Work Session Started',
      'Time to focus! Your work session has begun.',
      NotificationDetails(
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()),
      ),
    );
  }

  Future<void> showShortBreakStartedNotification() async {
    if (!_isInitialized) return;

    await _notifications.show(
      2,
      'Short Break Started',
      'Take a short break to recharge!',
      NotificationDetails(
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()),
      ),
    );
  }

  Future<void> showLongBreakStartedNotification() async {
    if (!_isInitialized) return;

    await _notifications.show(
      3,
      'Long Break Started',
      'Enjoy your longer break! You\'ve earned it.',
      NotificationDetails(
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()),
      ),
    );
  }

  Future<void> showSessionCompletedNotification() async {
    if (!_isInitialized) return;

    await _notifications.show(
      4,
      'Session Completed!',
      'Great job! You\'ve completed all your work cycles.',
      NotificationDetails(
        macOS: DarwinNotificationDetails(),
        windows: WindowsNotificationDetails(audio: WindowsNotificationAudio.silent()),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:interval_timer/services/storage_service.dart';

// Class for managing the app state between screens
class AppState extends ChangeNotifier {
  int workMinutes;
  int shortBreakMinutes;
  int longBreakMinutes;
  int intervalsUntilLongBreak;
  int totalCycles;
  bool enableCountdown;
  bool enableNotifications;

  Color workColor;
  Color shortBreakColor;
  Color longBreakColor;

  // Eye Protector settings
  bool enableEyeProtector;
  int eyeProtectorWorkMinutes;
  int eyeProtectorBreakMinutes;
  int eyeProtectorBreakDurationSeconds;

  AppState({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.intervalsUntilLongBreak = 3,
    this.totalCycles = 2,
    this.enableCountdown = true,
    this.enableNotifications = true,
    this.workColor = const Color.fromARGB(255, 186, 73, 73),
    this.shortBreakColor = const Color(0xFF388E3C),
    this.longBreakColor = const Color(0xFF1565C0),
    this.enableEyeProtector = false,
    this.eyeProtectorWorkMinutes = 20,
    this.eyeProtectorBreakMinutes = 20,
    this.eyeProtectorBreakDurationSeconds = 20,
  });

  static Future<AppState> create() async {
    final settings = await StorageService.loadSettings();
    return AppState(
      workMinutes: settings['workMinutes'],
      shortBreakMinutes: settings['shortBreakMinutes'],
      longBreakMinutes: settings['longBreakMinutes'],
      intervalsUntilLongBreak: settings['intervalsUntilLongBreak'],
      totalCycles: settings['totalCycles'],
      enableCountdown: settings['enableCountdown'],
      enableNotifications: settings['enableNotifications'],
      workColor: settings['workColor'],
      shortBreakColor: settings['shortBreakColor'],
      longBreakColor: settings['longBreakColor'],
      enableEyeProtector: settings['enableEyeProtector'],
      eyeProtectorWorkMinutes: settings['eyeProtectorWorkMinutes'],
      eyeProtectorBreakMinutes: settings['eyeProtectorBreakMinutes'],
      eyeProtectorBreakDurationSeconds: settings['eyeProtectorBreakDurationSeconds'],
    );
  }

  void updateWorkMinutes(int minutes) {
    workMinutes = minutes;
    _saveSettings();
    notifyListeners();
  }

  void updateShortBreakMinutes(int minutes) {
    shortBreakMinutes = minutes;
    _saveSettings();
    notifyListeners();
  }

  void updateLongBreakMinutes(int minutes) {
    longBreakMinutes = minutes;
    _saveSettings();
    notifyListeners();
  }

  void updateIntervalsUntilLongBreak(int intervals) {
    intervalsUntilLongBreak = intervals;
    _saveSettings();
    notifyListeners();
  }

  void updateTotalCycles(int cycles) {
    totalCycles = cycles;
    _saveSettings();
    notifyListeners();
  }

  void setCountdownEnabled(bool enabled) {
    enableCountdown = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setNotificationsEnabled(bool enabled) {
    enableNotifications = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setWorkColor(Color color) {
    workColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setShortBreakColor(Color color) {
    shortBreakColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setLongBreakColor(Color color) {
    longBreakColor = color;
    _saveSettings();
    notifyListeners();
  }

  void setEyeProtectorEnabled(bool enabled) {
    enableEyeProtector = enabled;
    _saveSettings();
    notifyListeners();
  }

  void setEyeProtectorWorkMinutes(int minutes) {
    eyeProtectorWorkMinutes = minutes;
    _saveSettings();
    notifyListeners();
  }

  void setEyeProtectorBreakMinutes(int minutes) {
    eyeProtectorBreakMinutes = minutes;
    _saveSettings();
    notifyListeners();
  }

  void setEyeProtectorBreakDurationSeconds(int seconds) {
    eyeProtectorBreakDurationSeconds = seconds;
    _saveSettings();
    notifyListeners();
  }

  void _saveSettings() {
    StorageService.saveSettings(
      workMinutes: workMinutes,
      shortBreakMinutes: shortBreakMinutes,
      longBreakMinutes: longBreakMinutes,
      intervalsUntilLongBreak: intervalsUntilLongBreak,
      totalCycles: totalCycles,
      enableCountdown: enableCountdown,
      enableNotifications: enableNotifications,
      workColor: workColor,
      shortBreakColor: shortBreakColor,
      longBreakColor: longBreakColor,
      enableEyeProtector: enableEyeProtector,
      eyeProtectorWorkMinutes: eyeProtectorWorkMinutes,
      eyeProtectorBreakMinutes: eyeProtectorBreakMinutes,
      eyeProtectorBreakDurationSeconds: eyeProtectorBreakDurationSeconds,
    );
  }
}

class AppStateScope extends InheritedNotifier<AppState> {
  const AppStateScope({
    super.key,
    required AppState super.notifier,
    required super.child,
  });

  static AppState of(BuildContext context) {
    final scope = context.dependOnInheritedWidgetOfExactType<AppStateScope>();
    assert(scope != null, 'AppStateScope not found in widget tree');
    return scope!.notifier!;
  }
}

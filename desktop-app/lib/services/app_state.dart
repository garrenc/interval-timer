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

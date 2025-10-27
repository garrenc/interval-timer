import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum StorageKey {
  workMinutes,
  shortBreakMinutes,
  longBreakMinutes,
  intervalsUntilLongBreak,
  totalCycles,
  enableCountdown,
  enableNotifications,
  workColor,
  shortBreakColor,
  longBreakColor,
  enableEyeProtector,
  eyeProtectorWorkMinutes,
  eyeProtectorBreakMinutes,
  eyeProtectorBreakDurationSeconds,
}

class StorageService {
  static Future<void> saveSettings({
    required int workMinutes,
    required int shortBreakMinutes,
    required int longBreakMinutes,
    required int intervalsUntilLongBreak,
    required int totalCycles,
    required bool enableCountdown,
    required bool enableNotifications,
    required Color workColor,
    required Color shortBreakColor,
    required Color longBreakColor,
    required bool enableEyeProtector,
    required int eyeProtectorWorkMinutes,
    required int eyeProtectorBreakMinutes,
    required int eyeProtectorBreakDurationSeconds,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setInt(StorageKey.workMinutes.name, workMinutes);
    await prefs.setInt(StorageKey.shortBreakMinutes.name, shortBreakMinutes);
    await prefs.setInt(StorageKey.longBreakMinutes.name, longBreakMinutes);
    await prefs.setInt(StorageKey.intervalsUntilLongBreak.name, intervalsUntilLongBreak);
    await prefs.setInt(StorageKey.totalCycles.name, totalCycles);
    await prefs.setBool(StorageKey.enableCountdown.name, enableCountdown);
    await prefs.setBool(StorageKey.enableNotifications.name, enableNotifications);
    await prefs.setInt(StorageKey.workColor.name, workColor.toARGB32());
    await prefs.setInt(StorageKey.shortBreakColor.name, shortBreakColor.toARGB32());
    await prefs.setInt(StorageKey.longBreakColor.name, longBreakColor.toARGB32());
    await prefs.setBool(StorageKey.enableEyeProtector.name, enableEyeProtector);
    await prefs.setInt(StorageKey.eyeProtectorWorkMinutes.name, eyeProtectorWorkMinutes);
    await prefs.setInt(StorageKey.eyeProtectorBreakMinutes.name, eyeProtectorBreakMinutes);
    await prefs.setInt(StorageKey.eyeProtectorBreakDurationSeconds.name, eyeProtectorBreakDurationSeconds);
  }

  static Future<Map<String, dynamic>> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'workMinutes': prefs.getInt(StorageKey.workMinutes.name) ?? 25,
      'shortBreakMinutes': prefs.getInt(StorageKey.shortBreakMinutes.name) ?? 5,
      'longBreakMinutes': prefs.getInt(StorageKey.longBreakMinutes.name) ?? 15,
      'intervalsUntilLongBreak': prefs.getInt(StorageKey.intervalsUntilLongBreak.name) ?? 3,
      'totalCycles': prefs.getInt(StorageKey.totalCycles.name) ?? 2,
      'enableCountdown': prefs.getBool(StorageKey.enableCountdown.name) ?? true,
      'enableNotifications': prefs.getBool(StorageKey.enableNotifications.name) ?? true,
      'workColor': Color(prefs.getInt(StorageKey.workColor.name) ?? const Color.fromARGB(255, 186, 73, 73).toARGB32()),
      'shortBreakColor': Color(prefs.getInt(StorageKey.shortBreakColor.name) ?? const Color(0xFF388E3C).toARGB32()),
      'longBreakColor': Color(prefs.getInt(StorageKey.longBreakColor.name) ?? const Color(0xFF1565C0).toARGB32()),
      'enableEyeProtector': prefs.getBool(StorageKey.enableEyeProtector.name) ?? false,
      'eyeProtectorWorkMinutes': prefs.getInt(StorageKey.eyeProtectorWorkMinutes.name) ?? 20,
      'eyeProtectorBreakMinutes': prefs.getInt(StorageKey.eyeProtectorBreakMinutes.name) ?? 20,
      'eyeProtectorBreakDurationSeconds': prefs.getInt(StorageKey.eyeProtectorBreakDurationSeconds.name) ?? 20,
    };
  }
}

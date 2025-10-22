import 'dart:io';
import 'package:system_tray/system_tray.dart';
import 'package:bitsdojo_window/bitsdojo_window.dart';

class SystemTrayService {
  static final SystemTrayService _instance = SystemTrayService._internal();
  factory SystemTrayService() => _instance;
  SystemTrayService._internal();

  SystemTray? _systemTray;

  Future<void> initialize() async {
    if (!Platform.isWindows) return;

    _systemTray = SystemTray();

    // Initialize system tray first
    await _systemTray!.initSystemTray(
      title: "Interval Timer",
      iconPath: "assets/app_logo.ico",
    );

    // Create and set context menu
    final menu = Menu();
    await menu.buildFrom([
      MenuItemLabel(
        label: 'Show Interval Timer',
        onClicked: (menuItem) => _showWindow(),
      ),
      MenuItemLabel(
        label: 'Exit',
        onClicked: (menuItem) => _exitApp(),
      ),
    ]);

    await _systemTray!.setContextMenu(menu);

    // Register event handlers
    _systemTray!.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick) {
        // Left click - show/hide window
        _showWindow();
      } else if (eventName == kSystemTrayEventRightClick) {
        // Right click - show context menu
        _systemTray!.popUpContextMenu();
      }
    });
  }

  void _showWindow() {
    appWindow.show();
  }

  void _exitApp() {
    // Force exit the app completely
    exit(0);
  }

  Future<void> updateTrayTitle(String title) async {
    if (Platform.isWindows && _systemTray != null) {
      await _systemTray!.setTitle(title);
    }
  }
}

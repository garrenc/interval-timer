import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:interval_timer/helpers/colors.dart';
import 'package:interval_timer/screens/settings.dart';

class TopBarWidget extends StatelessWidget {
  final bool showSettings;
  TopBarWidget({super.key, this.showSettings = true});

  final _buttonColors = WindowButtonColors(
    iconNormal: Colors.white,
    iconMouseOver: AppColors.primaryRed,
    iconMouseDown: AppColors.primaryRed,
    mouseOver: Colors.white,
    mouseDown: Colors.grey.shade400,
  );

  @override
  Widget build(BuildContext context) {
    return WindowBorder(
      color: Colors.transparent,
      width: 0,
      child: Row(
        children: [
          Expanded(
            child: MoveWindow(), // draggable area
          ),
          if (showSettings)
            IconButton(
              icon: const Icon(Icons.settings, color: Colors.white, size: 16),
              tooltip: 'Settings',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const SettingsScreen()),
                );
              },
            ),
          MinimizeWindowButton(colors: _buttonColors),
          CloseWindowButton(colors: _buttonColors),
        ],
      ),
    );
  }
}

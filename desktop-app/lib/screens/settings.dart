import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:interval_timer/services/app_state.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = AppStateScope.of(context);
    return Scaffold(
      backgroundColor: Colors.black.withValues(alpha: 0.05),
      appBar: AppBar(
        backgroundColor: Colors.black12,
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ColorTile(
            title: 'Work color',
            color: app.workColor,
            onPick: (c) => app.setWorkColor(c),
          ),
          const SizedBox(height: 12),
          _ColorTile(
            title: 'Short break color',
            color: app.shortBreakColor,
            onPick: (c) => app.setShortBreakColor(c),
          ),
          const SizedBox(height: 12),
          _ColorTile(
            title: 'Long break color',
            color: app.longBreakColor,
            onPick: (c) => app.setLongBreakColor(c),
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable countdown', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Show 3-2-1 countdown before timer starts', style: TextStyle(color: Colors.white70)),
            value: app.enableCountdown,
            onChanged: app.setCountdownEnabled,
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            title: const Text('Enable notifications', style: TextStyle(color: Colors.white)),
            subtitle: const Text('Receive notifications for timer phase changes', style: TextStyle(color: Colors.white70)),
            value: app.enableNotifications,
            onChanged: app.setNotificationsEnabled,
            activeThumbColor: Colors.white,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withValues(alpha: 0.3),
          ),
        ],
      ),
    );
  }
}

class _ColorTile extends StatelessWidget {
  final String title;
  final Color color;
  final ValueChanged<Color> onPick;

  const _ColorTile({required this.title, required this.color, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      tileColor: Colors.white10,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      title: Text(title, style: const TextStyle(color: Colors.white)),
      trailing: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: Colors.white24),
        ),
      ),
      onTap: () async {
        Color temp = color;
        await showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              backgroundColor: const Color(0xFF2C2C2C),
              title: Text(title, style: const TextStyle(color: Colors.white)),
              content: SingleChildScrollView(
                child: ColorPicker(
                  pickerColor: temp,
                  onColorChanged: (c) => temp = c,
                  enableAlpha: false,
                  labelTypes: const [],
                  pickerAreaBorderRadius: const BorderRadius.all(Radius.circular(8)),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    onPick(temp);
                    Navigator.pop(context);
                  },
                  child: const Text('Save'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}

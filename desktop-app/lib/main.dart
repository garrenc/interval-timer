import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:flutter/material.dart';
import 'package:interval_timer/helpers/colors.dart';
import 'package:interval_timer/screens/home.dart';
import 'package:interval_timer/services/app_state.dart';
import 'package:interval_timer/services/notification_service.dart';
import 'package:interval_timer/services/system_tray_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize notifications
  await NotificationService().initialize();

  doWhenWindowReady(() {
    const initialSize = Size(400, 950);
    appWindow.minSize = Size(350, 400);
    appWindow.size = initialSize;
    appWindow.alignment = Alignment.center;
    appWindow.show();

    SystemTrayService().initialize();
  });

  // Load settings from storage
  final appState = await AppState.create();

  runApp(MyApp(appState: appState));
}

class MyApp extends StatelessWidget {
  final AppState appState;

  const MyApp({super.key, required this.appState});

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      notifier: appState,
      child: MaterialApp(
        title: 'Interval Timer',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          scaffoldBackgroundColor: AppColors.primaryRed,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
            ),
          ),
          colorScheme: ColorScheme.fromSeed(seedColor: AppColors.primaryRed, brightness: Brightness.dark),
          useMaterial3: true,
        ),
        home: HomeScreen(),
      ),
    );
  }
}

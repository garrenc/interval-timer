// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:interval_timer/main.dart';
import 'package:interval_timer/services/app_state.dart';

void main() {
  testWidgets('Interval Timer app smoke test', (WidgetTester tester) async {
    // Create a test app state
    final appState = AppState();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(appState: appState));

    // Verify that our app loads with the expected title
    expect(find.text('Interval Timer'), findsOneWidget);

    // Verify that the Start button is present
    expect(find.text('Start'), findsOneWidget);
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:am5vendor/main.dart';
import 'package:am5vendor/core/di/injection_container.dart' as di;

void main() {
  testWidgets('Smoke test - Verify app loads', (WidgetTester tester) async {
    // Initialize Mock SharedPreferences
    SharedPreferences.setMockInitialValues({});
    
    // Initialize dependency injection locator
    await di.init();

    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: MyApp(),
      ),
    );

    // Wait for the mock network delay to complete and state to render
    await tester.pumpAndSettle();

    // Verify that our login page is displayed
    expect(find.text('Mobile / Email'), findsOneWidget);
  });
}

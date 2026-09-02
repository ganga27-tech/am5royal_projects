import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_ui/am5_ui.dart';

void main() {
  test('Hindi strings resolve', () {
    final s = LivoraStrings(const Locale('hi'));
    expect(s.settings, 'सेटिंग्स');
    expect(s.profile, 'प्रोफ़ाइल');
  });

  test('English strings resolve', () {
    final s = LivoraStrings(const Locale('en'));
    expect(s.settings, 'Settings');
  });

  testWidgets('LivoraButton primary renders label', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LivoraTheme.light(),
        home: Scaffold(
          body: LivoraButton(label: 'Continue', onPressed: () {}),
        ),
      ),
    );
    expect(find.text('Continue'), findsOneWidget);
  });
}

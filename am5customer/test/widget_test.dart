import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:am5_ui/am5_ui.dart';

void main() {
  testWidgets('login form validates empty email', (tester) async {
    final email = TextEditingController();
    final formKey = GlobalKey<FormState>();

    await tester.pumpWidget(
      MaterialApp(
        theme: LivoraTheme.light(),
        home: Scaffold(
          body: Form(
            key: formKey,
            child: LivoraTextField(
              controller: email,
              label: 'Email',
              validator: (v) => v == null || v.isEmpty ? 'Email is required' : null,
            ),
          ),
        ),
      ),
    );

    expect(formKey.currentState!.validate(), isFalse);
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
  });

  testWidgets('LivoraLogo renders wordmark', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: LivoraTheme.light(),
        home: const Scaffold(body: LivoraLogo()),
      ),
    );
    expect(find.text('LIVORA'), findsOneWidget);
  });
}

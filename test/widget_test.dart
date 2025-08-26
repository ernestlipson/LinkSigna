// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sign_language_app/main.dart';

void main() {
  testWidgets('Main app displays correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const Main(initialRoute: '/signup'));

    // Verify that the signup screen displays correctly.
    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Student'), findsOneWidget);
    expect(find.text('Interpreter'), findsOneWidget);
  });
}

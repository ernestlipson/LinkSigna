import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';
import 'package:sign_language_app/infrastructure/navigation/bindings/global.binding.dart';
import 'package:sign_language_app/presentation/sessions/controllers/sessions.controller.dart';
import 'package:sign_language_app/presentation/sessions/sessions.screen.dart';

void main() {
  group('SessionsScreen Tests', () {
    setUp(() {
      Get.testMode = true;
      Get.reset();
      Get.put(GlobalBinding());
    });

    tearDown(() {
      Get.reset();
    });

    testWidgets('SessionsScreen displays correctly',
        (WidgetTester tester) async {
      // Arrange
      Get.put(SessionsController());

      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: const SessionsScreen(),
        ),
      );

      // Assert
      expect(find.text('Upcoming Sessions'), findsOneWidget);
      expect(find.text('Search'), findsOneWidget);
      expect(find.byType(ListView), findsOneWidget);
    });

    testWidgets('Session cards display correctly', (WidgetTester tester) async {
      // Arrange
      final controller = Get.put(SessionsController());

      // Act
      await tester.pumpWidget(
        GetMaterialApp(
          home: const SessionsScreen(),
        ),
      );

      // Wait for the controller to load sessions
      await tester.pump();

      // Assert
      expect(find.text('Session with Arlene McCoy'), findsNWidgets(5));
      expect(find.text('Join Video Call'), findsNWidgets(5));
      expect(find.text('Cancel Session'), findsNWidgets(5));
    });
  });
}

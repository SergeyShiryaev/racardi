// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:racardi/main.dart';
import 'package:racardi/models/discount_card.dart';
import 'package:racardi/services/language_service.dart';

void main() {
  testWidgets('App initialization smoke test', (WidgetTester tester) async {
    // Initialize Hive for testing
    await Hive.initFlutter();
    Hive.registerAdapter(DiscountCardAdapter());
    
    try {
      await Hive.openBox<DiscountCard>('cards');
    } catch (e) {
      // Ignore if already exists
    }

    // Initialize LanguageService
    final languageService = LanguageService();
    await languageService.load();

    // Build our app and trigger a frame.
    await tester.pumpWidget(MyApp(languageService: languageService));
    await tester.pumpAndSettle();

    // Verify that the app starts without errors
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}


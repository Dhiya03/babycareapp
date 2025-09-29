// This is a basic Flutter widget test.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:babycareapp/app.dart';

void main() {
  testWidgets('App starts and renders HomeScreen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ProviderScope(child: BabyCareApp()));

    // Verify that the app bar title is present.
    expect(find.text('BabyCare 🍼💖'), findsOneWidget);

    // Verify that the main action buttons are present.
    expect(find.byType(ElevatedButton), findsWidgets);
  });
}

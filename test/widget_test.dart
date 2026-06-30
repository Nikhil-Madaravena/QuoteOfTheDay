import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qod/core/providers/shared_preferences_provider.dart';
import 'package:qod/main.dart';

void main() {
  testWidgets('App launches and renders without errors', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          sharedPreferencesProvider.overrideWithValue(prefs),
        ],
        child: const QODApp(),
      ),
    );

    await tester.pump();
    // App renders without throwing
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}

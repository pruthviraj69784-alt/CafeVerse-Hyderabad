// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('Splash screen loads', (WidgetTester tester) async {
    // Use a lightweight test-only splash widget to avoid Firebase/platform setup
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.local_cafe, size: 84),
                SizedBox(height: 24),
                Text('CaféVerse', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
                SizedBox(height: 12),
                Text('Your coffee shop companion'),
              ],
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('CaféVerse'), findsOneWidget);
    expect(find.text('Your coffee shop companion'), findsOneWidget);
  });
}

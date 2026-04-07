// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:habit_tracker/main.dart';

void main() {
  testWidgets('renders the habit tracker home screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HabitTrackerApp()));

    await tester.pumpAndSettle();

    expect(find.text('Today'), findsOneWidget);
    expect(find.text('Challenges'), findsOneWidget);
    expect(find.text('Stats'), findsOneWidget);
    expect(find.text('Explore'), findsOneWidget);
    expect(find.byIcon(Icons.add_rounded), findsOneWidget);
  });
}

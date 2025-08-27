// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:artha/main.dart';

void main() {
  testWidgets('Wallet app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const ArthaDiamondWalletApp());

    // Wait for the widget to settle
    await tester.pumpAndSettle();

    // Verify that key elements are present
    expect(find.text('Home'), findsOneWidget);
    expect(find.text('List of accounts'), findsOneWidget);
    expect(find.text('Balance Trend'), findsOneWidget);
    expect(find.text('Cash Flow'), findsOneWidget);
    expect(find.text('RECORDS'), findsOneWidget);

    // Verify the floating action button exists
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}

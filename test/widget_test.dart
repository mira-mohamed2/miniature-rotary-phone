// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:bill_validator/main.dart';

void main() {
  testWidgets('App loads home screen with main actions', (WidgetTester tester) async {
    // Build the updated app
    await tester.pumpWidget(const BillValidatorApp());

    // Verify home screen title and buttons exist
    expect(find.text('Bill Validator'), findsWidgets); // App bar + headline
    expect(find.text('Take Photo'), findsOneWidget);
    expect(find.text('Select from Gallery'), findsOneWidget);
  });
}

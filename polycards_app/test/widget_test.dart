// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';

import 'package:polycards_app/main.dart';

void main() {
  testWidgets('App starts with welcome screen', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const PolyCardsApp());

    // Verify that welcome text is displayed
    expect(find.text('Welcome to PolyCards'), findsOneWidget);
    expect(find.text('Learn 1000 words in multiple languages'), findsOneWidget);

    // Verify Get Started button exists
    expect(find.text('Get Started'), findsOneWidget);
  });
}

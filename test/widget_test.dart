// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:kabaddi_app/main.dart';

void main() {
  testWidgets('App starts correctly', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: KabaddiApp(),
      ),
    );

    // Verify that our app shows the home screen
    expect(find.text('カバディスコア'), findsWidgets);
    expect(find.text('新規試合を開始'), findsOneWidget);
    expect(find.text('デモ試合で体験'), findsOneWidget);
  });
}

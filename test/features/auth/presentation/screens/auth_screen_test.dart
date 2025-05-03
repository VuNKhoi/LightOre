import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/screens/auth_screen.dart';
import 'package:flutter/material.dart';

void main() {
  testWidgets('AuthScreen has login button', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(home: AuthScreen()),
    );

    expect(find.text('Continue to Home'), findsOneWidget);
  });
}

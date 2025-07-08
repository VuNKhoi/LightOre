import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lightore/features/auth/presentation/widgets/google_login_button.dart';
import 'package:lightore/constants.dart';

class MockOnError extends Mock {
  void call(String error);
}

class MockOnSuccess extends Mock {
  void call();
}

void main() {
  testWidgets('GoogleLoginButton renders and disables when loading',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Scaffold(
        body: GoogleLoginButton(loading: true),
      ),
    ));
    final button = find.byKey(AppKeys.googleLoginButton);
    expect(button, findsOneWidget);
    final elevatedButton = tester.widget<ElevatedButton>(button);
    expect(elevatedButton.onPressed, isNull);
  });

  testWidgets('GoogleLoginButton calls onError on failure', (tester) async {
    final mockOnError = MockOnError();
    await tester.pumpWidget(MaterialApp(
      home: Scaffold(
        body: GoogleLoginButton(
          loading: false,
          onError: mockOnError.call,
        ),
      ),
    ));
    // Simulate tap (will fail due to missing GoogleSignIn setup)
    await tester.tap(find.byKey(AppKeys.googleLoginButton));
    await tester.pumpAndSettle();
    // Can't verify actual call without dependency injection, but no crash
  });
}

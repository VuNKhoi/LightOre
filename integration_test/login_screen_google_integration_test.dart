import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:lightore/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Google login button triggers real sign-in flow', (tester) async {
    app.main();
    await tester.pumpAndSettle();
    final googleButton = find.byKey(const Key('google_login_button'));
    expect(googleButton, findsOneWidget);
    await tester.tap(googleButton);
    // NOTE: This will launch the real Google sign-in UI. Manual interaction may be required.
    // You can add more checks here if running on a real device with test credentials.
  });
}

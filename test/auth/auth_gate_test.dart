import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter/material.dart';
import 'package:lightore/screens/splash_screen.dart';
import 'package:lightore/auth/auth_gate.dart';
import 'package:lightore/repositories/auth_repository.dart';

import 'auth_notifier_test.dart';

void main() {
  testWidgets('shows SplashScreen while loading AuthGate state',
      (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository())
        ],
        child: const MaterialApp(home: AuthGate()),
      ),
    );
    expect(find.byType(SplashScreen), findsOneWidget);
  });
}

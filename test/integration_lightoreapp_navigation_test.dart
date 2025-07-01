import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/app.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:mocktail/mocktail.dart';
import 'test_helpers.dart';

void main() {
  group('Integration: LightOreApp navigation and access control', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    testWidgets(
        'Unauthenticated user can navigate from login to register and back',
        (tester) async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider
                .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
          ],
          child: const LightOreApp(),
        ),
      );
      await tester.pumpAndSettle();
      // Should start on login
      expect(find.widgetWithText(AppBar, 'Login or Pay'), findsOneWidget);
      // Tap register button
      final registerButton =
          find.textContaining("Don't have an account? Register");
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();
      // Should see register screen (AppBar title)
      expect(find.widgetWithText(AppBar, 'Register'), findsOneWidget);
      // Tap login button on register screen
      final loginButton = find.textContaining('Already have an account? Login');
      expect(loginButton, findsOneWidget);
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
      // Should be back on login (AppBar title)
      expect(find.widgetWithText(AppBar, 'Login or Pay'), findsOneWidget);
    });

    testWidgets(
        'Authenticated user can logout from home and is navigated to login',
        (tester) async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      final notifier = MockAuthNotifier(mockAuthRepository)
        ..state = AuthState.authenticated();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => notifier),
          ],
          child: const LightOreApp(),
        ),
      );
      await tester.pumpAndSettle();
      // Should start on home
      expect(find.widgetWithText(AppBar, 'Home'), findsOneWidget);
      // Tap logout button
      final logoutButton = find.byKey(const Key('logout_button'));
      expect(logoutButton, findsOneWidget);
      await tester.tap(logoutButton);
      await tester.pumpAndSettle();
      // Should be back on login (AppBar title)
      expect(find.widgetWithText(AppBar, 'Login or Pay'), findsOneWidget);
    });
  });
}

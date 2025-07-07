import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/app.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';
import 'package:mocktail/mocktail.dart';
import 'test_helpers.dart';

void main() {
  group('Integration: LightOreApp navigation and access control', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
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
      // Should start on home (no AppBar, just map and option bubble)
      expect(find.byType(BaseMapView), findsOneWidget);
      expect(find.byType(OptionBubble), findsOneWidget);
      // Tap the OptionBubble to expand
      await tester.tap(find.byIcon(Icons.menu));
      await tester.pumpAndSettle();
      // Tap the Account tile
      await tester.tap(find.text('Account'));
      await tester.pumpAndSettle();
      // Should be on account page with logout button
      expect(find.text('Logout'), findsOneWidget);
      await tester.tap(find.text('Logout'));
      await tester.pumpAndSettle();
      // Extra pump to ensure navigation is complete
      await tester.pumpAndSettle();
      // Should be back on login screen (check for login button by key)
      expect(find.byKey(const ValueKey('login_button')), findsOneWidget);
    });
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/home/presentation/screens/home_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

/// A [MockAuthNotifier] that tracks if logout() was called for test assertions.
class TrackingAuthNotifier extends MockAuthNotifier {
  bool logoutCalled = false;
  TrackingAuthNotifier(super.mock);
  @override
  Future<bool> logout() async {
    logoutCalled = true;
    return true;
  }
}

Future<void> pumpHomeScreenWithProvider(
  WidgetTester tester, {
  required MockAuthNotifier notifier,
  Widget? homeScreen,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp(
        home: homeScreen ?? const HomeScreen(),
      ),
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('displays title and logout button', (tester) async {
      await pumpWidgetWithRouter(
        tester: tester,
        initialLocation: '/home',
        routes: {
          '/home': const HomeScreen(),
        },
      );

      // Verify the title is shown
      expect(find.text('Home'), findsOneWidget);
      // Verify the logout button is shown
      expect(find.byKey(const Key('logout_button')), findsOneWidget);
      expect(find.text('Logout'), findsOneWidget);
      // No redundant crash test: only meaningful behavior is tested
    });

    testWidgets('Tapping logout button calls logout on notifier',
        (tester) async {
      final mockAuthRepository = MockAuthRepository();
      // Ensure isAuthenticated returns a Future as expected by AuthNotifier
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => null);
      final notifier = TrackingAuthNotifier(mockAuthRepository);
      await pumpHomeScreenWithProvider(tester, notifier: notifier);

      await tester.tap(find.byKey(const Key('logout_button')));
      await tester.pump();
      expect(notifier.logoutCalled, isTrue);
    });
  });
}

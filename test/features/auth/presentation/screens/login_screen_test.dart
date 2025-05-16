import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/core/presentation/auth_gate.dart';
import 'package:lightore/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = createMockAuthRepository();
    container = createTestProviderContainer(mockAuthRepository);
  });

  tearDown(() {
    container.dispose();
  });

  group('LoginScreen Tests', () {
    testWidgets('LoginScreen shows button and navigates on press',
        (tester) async {
      // Arrange
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                AuthGate(child: const Scaffold(body: Text('Home Screen'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => AuthGate(child: const LoginScreen()),
          ),
        ],
        refreshListenable: ValueNotifier(mockAuthRepository),
      );
      await pumpLoginScreenWithRouter(tester, mockAuthRepository, router);

      // Ensure the mock returns unauthenticated initially
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      // Verify the "Continue to Home" button exists
      expect(find.text('Continue to Home'), findsOneWidget);

      // Act: Tap the login button
      await tester.tap(find.text('Continue to Home'));

      // After tapping, update the mock to return authenticated
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);

      // Allow the widget tree to rebuild and navigation to occur
      await tester.pumpAndSettle();

      // Assert: Should navigate to Home Screen
      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('LoginScreen shows error message on login failure',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                AuthGate(child: const Scaffold(body: Text('Home Screen'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => AuthGate(child: const LoginScreen()),
          ),
        ],
        refreshListenable: ValueNotifier(mockAuthRepository),
      );
      await pumpLoginScreenWithRouter(
        tester,
        mockAuthRepository,
        router,
      );

      // Simulate login failure by setting authentication state to false
      mockSetAuthenticated(mockAuthRepository, false);

      // Tap the login button
      await tester.tap(find.text('Continue to Home'));
      await tester.pumpAndSettle();

      // Verify error message is displayed
      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('LoginScreen UI elements are displayed correctly',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) =>
                AuthGate(child: const Scaffold(body: Text('Home Screen'))),
          ),
          GoRoute(
            path: '/login',
            builder: (context, state) => AuthGate(child: const LoginScreen()),
          ),
        ],
        refreshListenable: ValueNotifier(mockAuthRepository),
      );
      await pumpLoginScreenWithRouter(
        tester,
        mockAuthRepository,
        router,
      );

      // Verify the presence of UI elements
      expect(find.text('Login or Pay'), findsOneWidget);
      expect(find.text('Continue to Home'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);
    });
  });
}

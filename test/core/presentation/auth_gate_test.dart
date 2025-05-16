import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/core/presentation/auth_gate.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

void main() {
  group('AuthGate Tests', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = createMockAuthRepository();
      container = createTestProviderContainer(mockAuthRepository);
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('AuthGate redirects to login when unauthenticated',
        (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider
                .overrideWith((ref) => TestAuthNotifier(mockAuthRepository)),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const Text('Login Screen'),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const AuthGate(
                    child: Text('Home Screen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('AuthGate redirects to home when authenticated',
        (tester) async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider
                .overrideWith((ref) => TestAuthNotifier(mockAuthRepository)),
          ],
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/login',
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const AuthGate(
                    child: Text('Login Screen'),
                  ),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const Text('Home Screen'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('AuthGate redirects to /login when unauthenticated',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: getAuthTestRoutes(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) => TestAuthNotifier(
                MockAuthRepository()..setAuthenticated(false))),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);
    });

    testWidgets('AuthGate redirects to /home when authenticated',
        (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: getAuthTestRoutes(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) =>
                TestAuthNotifier(MockAuthRepository()..setAuthenticated(true))),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('AuthGate updates on auth state change', (tester) async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp.router(
            routerConfig: GoRouter(
              initialLocation: '/home',
              routes: [
                GoRoute(
                  path: '/login',
                  builder: (context, state) => const Text('Login Screen'),
                ),
                GoRoute(
                  path: '/home',
                  builder: (context, state) => const AuthGate(
                    child: Text('Home Screen'),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);

      // Explicitly trigger state change and rebuild
      container.read(authProvider.notifier).logout();
      await tester.pumpAndSettle();

      expect(find.text('Login Screen'), findsOneWidget);

      container.read(authProvider.notifier).login();
      await tester.pumpAndSettle();

      // Debugging: Print the current auth state to verify transitions
      print(
          'AuthGate Test: Current auth state: ${container.read(authProvider)}');

      expect(find.text('Home Screen'), findsOneWidget);
    });

    testWidgets('AuthGate navigation debugging', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: getAuthTestRoutes(),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider.overrideWith((ref) =>
                TestAuthNotifier(MockAuthRepository()..setAuthenticated(true))),
          ],
          child: MaterialApp.router(
            routerConfig: router,
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Debugging: Print the current route to verify navigation
      print(
          'Current route: ${router.routerDelegate.currentConfiguration.uri.toString()}');

      expect(find.text('Home Screen'), findsOneWidget);
    });

    // Debugging: Print the current auth state
    print('Auth state during test: ${container.read(authProvider)}');
  });
}

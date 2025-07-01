import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/app.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../test/test_helpers.dart';

void main() {
  group('App navigation flows', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = createMockAuthRepository();
    });

    testWidgets('Shows login screen when unauthenticated', (tester) async {
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
      expect(find.text('Login'), findsOneWidget);
    });

    testWidgets('Shows home screen when authenticated', (tester) async {
      final router = GoRouter(
        initialLocation: '/home',
        routes: [
          GoRoute(
            path: '/home',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Home')),
              body: const Text('Home Screen'),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider
                .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
          ],
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('Home'), findsOneWidget);
    });

    testWidgets('Navigates to register screen from login', (tester) async {
      final router = GoRouter(
        initialLocation: '/login',
        routes: [
          GoRoute(
            path: '/login',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Login')),
              body: Column(
                children: [
                  const Text('Login'),
                  TextButton(
                    key: const Key('go_to_register_button'),
                    onPressed: () => context.go('/register'),
                    child: const Text("Don't have an account? Register"),
                  ),
                ],
              ),
            ),
          ),
          GoRoute(
            path: '/register',
            builder: (context, state) => Scaffold(
              appBar: AppBar(title: const Text('Register')),
              body: const Text('Register'),
            ),
          ),
        ],
      );
      await tester.pumpWidget(
        MaterialApp.router(routerConfig: router),
      );
      await tester.pumpAndSettle();
      final registerButton =
          find.textContaining("Don't have an account? Register");
      expect(registerButton, findsOneWidget);
      await tester.tap(registerButton);
      await tester.pumpAndSettle();
      expect(find.widgetWithText(AppBar, 'Register'), findsOneWidget);
    });
  });
}

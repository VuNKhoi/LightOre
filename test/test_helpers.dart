import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/core/presentation/auth_gate.dart';
import 'package:lightore/features/auth/application/auth_notifier.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

/// Builds a ProviderScope or UncontrolledProviderScope for tests, with optional overrides.
Widget buildProviderScope({
  required Widget child,
  MockAuthRepository? mock,
  TestAuthNotifier? notifier,
  bool uncontrolled = false,
  ProviderContainer? container,
  bool withUnknown = false,
}) {
  if (uncontrolled && container != null) {
    return UncontrolledProviderScope(
      container: container,
      child: child,
    );
  }
  return ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) =>
          notifier ??
          (withUnknown
              ? TestAuthNotifier.withStateUnknown(mock!)
              : TestAuthNotifier(mock!))),
    ],
    child: child,
  );
}

/// Pumps a widget and settles for widget tests.
Future<void> pumpAuthTestWidget(
  WidgetTester tester, {
  required Widget widget,
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
  await tester.pump();
}

/// Asserts the current router location matches the expected location.
void expectRouterLocation(GoRouter router, String location) {
  expect(router.routerDelegate.currentConfiguration.uri.toString(), location);
}

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

// Test AuthNotifier
class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(MockAuthRepository super.mock);

  // Factory for unknown state
  TestAuthNotifier.withStateUnknown(MockAuthRepository super.mock) {
    state = AuthState.unknown();
  }
}

Future<void> pumpLoginScreenWithRouter(WidgetTester tester,
    MockAuthRepository mockAuthRepository, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider
            .overrideWith((ref) => TestAuthNotifier(mockAuthRepository)),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
}

Future<void> pumpWidgetWithRouter({
  required WidgetTester tester,
  required String initialLocation,
  required Map<String, Widget> routes,
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: routes.entries
        .map((entry) => GoRoute(
              path: entry.key,
              builder: (context, state) => entry.value,
            ))
        .toList(),
  );

  await tester.pumpWidget(
    MaterialApp.router(
      routerConfig: router,
    ),
  );
}

void mockSetAuthenticated(
    MockAuthRepository mockAuthRepository, bool shouldSucceed) {
  when(() => mockAuthRepository.setAuthenticated(any()))
      .thenAnswer((_) async => shouldSucceed);
}

List<GoRoute> getAuthTestRoutes() {
  return [
    GoRoute(
      path: '/login',
      builder: (context, state) => const AuthGate(
        child:
            Scaffold(body: Text('Login Screen', key: ValueKey('login-screen'))),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const AuthGate(
        child:
            Scaffold(body: Text('Home Screen', key: ValueKey('home-screen'))),
      ),
    ),
  ];
}

ProviderContainer createTestProviderContainer(
    MockAuthRepository mockAuthRepository) {
  return ProviderContainer(overrides: [
    authProvider.overrideWith((ref) => TestAuthNotifier(mockAuthRepository)),
  ]);
}

// Helper function to create and mock the AuthRepository
MockAuthRepository createMockAuthRepository() {
  final mockAuthRepository = MockAuthRepository();
  when(() => mockAuthRepository.setAuthenticated(any()))
      .thenAnswer((_) async => true);
  when(() => mockAuthRepository.clear()).thenAnswer((_) async => true);
  when(() => mockAuthRepository.isAuthenticated())
      .thenAnswer((_) async => null);
  return mockAuthRepository;
}

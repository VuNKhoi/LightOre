import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:mocktail/mocktail.dart';

import '../../test_helpers.dart';

void main() {
  group('AuthGate Tests', () {
    // Always use Scaffold(body: Text(...)) for route widgets in tests.
    // This ensures the widget tree matches the real app and avoids subtle test failures.
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = createMockAuthRepository();
      container = createTestProviderContainer(mockAuthRepository);
      setupMockAuthRepository(mockAuthRepository, false);
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('AuthGate redirects to login when unauthenticated',
        (tester) async {
      final router = createTestRouter(initialLocation: '/home');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mockAuthRepository,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/login');
    });

    testWidgets('AuthGate redirects to home when authenticated',
        (tester) async {
      setupMockAuthRepository(mockAuthRepository, true);
      final router = createTestRouter(initialLocation: '/login');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mockAuthRepository,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/home');
    });

    testWidgets('AuthGate redirects to /login when unauthenticated',
        (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, false);
      final router = createTestRouter(initialLocation: '/home');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mock,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/login');
    });

    testWidgets('AuthGate redirects to /home when authenticated',
        (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, true);
      final router = createTestRouter(initialLocation: '/login');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mock,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/home');
    });

    testWidgets('AuthGate updates on auth state change', (tester) async {
      // Use test notifier and mock to avoid coupling to real provider
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, false);
      mockSetAuthenticated(
          mock, true); // Ensure setAuthenticated returns Future<bool>
      final router = createTestRouter(initialLocation: '/home');
      final container = createTestProviderContainer(mock);
      final notifier =
          container.read(authProvider.notifier) as MockAuthNotifier;
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          uncontrolled: true,
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      // Explicitly set unauthenticated state before asserting redirect
      notifier.logout();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/login');
      notifier.login();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/home');
      notifier.logout();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/login');
    });

    testWidgets('AuthGate navigation debugging', (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, true);
      final router = createTestRouter(initialLocation: '/login');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mock,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/home');
    });

    testWidgets('AuthGate redirects to login when unknown', (tester) async {
      setupMockAuthRepository(mockAuthRepository, null);
      final router = createTestRouter(initialLocation: '/home');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mockAuthRepository,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/login');
    });

    testWidgets('AuthGate redirects to /login when state is unknown',
        (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, false);
      final router = createTestRouter(initialLocation: '/home');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mock,
          withUnknown: true,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/login');
    });

    testWidgets(
        'AuthGate does not redirect if already on correct route for state',
        (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, false);
      final router = createTestRouter(initialLocation: '/login');
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          mock: mock,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      expectRouterLocation(router, '/login');
    });

    testWidgets(
        'AuthGate handles rapid state changes (unknown -> unauthenticated -> authenticated)',
        (tester) async {
      final mock = MockAuthRepository();
      setupMockAuthRepository(mock, false);
      mockSetAuthenticated(
          mock, true); // Ensure setAuthenticated returns Future<bool>
      final router = createTestRouter(initialLocation: '/home');
      final container = createTestProviderContainer(mock);
      final notifier =
          container.read(authProvider.notifier) as MockAuthNotifier;
      await pumpAuthTestWidget(
        tester,
        widget: buildProviderScope(
          uncontrolled: true,
          container: container,
          child: MaterialApp.router(routerConfig: router),
        ),
      );
      await tester.pumpAndSettle(); // Wait for async init and redirect
      expect(find.byType(Directionality), findsOneWidget);
      // Explicitly set unauthenticated state before asserting redirect
      notifier.logout();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/login');
      notifier.login();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/home');
      notifier.logout();
      await tester.pumpAndSettle();
      expectRouterLocation(router, '/login');
    });
  });
}

// --- TEST HELPERS ---
GoRouter createTestRouter({String initialLocation = '/home'}) {
  return GoRouter(
    initialLocation: initialLocation,
    routes: getAuthTestRoutes(),
  );
}

Widget buildProviderScope({
  required Widget child,
  MockAuthRepository? mock,
  MockAuthNotifier? notifier,
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
              ? MockAuthNotifier.withStateUnknown(mock!)
              : MockAuthNotifier(mock!))),
    ],
    child: child,
  );
}

Future<void> pumpAuthTestWidget(
  WidgetTester tester, {
  required Widget widget,
}) async {
  await tester.pumpWidget(widget);
  await tester.pumpAndSettle();
  await tester.pump();
}

void expectRouterLocation(GoRouter router, String location) {
  expect(router.routerDelegate.currentConfiguration.uri.toString(), location);
}

void setupMockAuthRepository(MockAuthRepository mock, bool? isAuthenticated) {
  when(() => mock.isAuthenticated()).thenAnswer((_) async => isAuthenticated);
}

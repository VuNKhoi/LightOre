import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_notifier.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/features/auth/domain/repositories/auth_repository_interface.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lightore/app.dart' show homeScreenFactory;
import 'package:lightore/features/home/presentation/screens/home_screen.dart';
import 'package:lightore/repositories/auth_repository.dart';

/// Builds a ProviderScope or UncontrolledProviderScope for tests, with optional overrides.
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
/// A [MockAuthNotifier] for use in widget and provider tests.
class MockAuthNotifier extends AuthNotifier {
  MockAuthNotifier(MockAuthRepository super.mock);

  // Factory for unknown state
  MockAuthNotifier.withStateUnknown(MockAuthRepository super.mock) {
    state = AuthState.unknown();
  }
}

Future<void> pumpLoginScreenWithRouter(WidgetTester tester,
    MockAuthRepository mockAuthRepository, GoRouter router) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
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
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Login')),
        body: const Text('Login Screen', key: ValueKey('login-screen')),
      ),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Home')),
        body: const Text('Home Screen', key: ValueKey('home-screen')),
      ),
    ),
    GoRoute(
      path: '/register',
      builder: (context, state) => Scaffold(
        appBar: AppBar(title: const Text('Register')),
        body: const Text('Register Screen', key: ValueKey('register-screen')),
      ),
    ),
  ];
}

ProviderContainer createTestProviderContainer(
    MockAuthRepository mockAuthRepository) {
  return ProviderContainer(overrides: [
    authProvider.overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
  ]);
}

// Helper function to create and mock the AuthRepository
MockAuthRepository createMockAuthRepository() {
  final mockAuthRepository = MockAuthRepository();
  // Remove all default stubs here; all stubbing should be done in each test.
  return mockAuthRepository;
}

// Mock classes for FirebaseAuth
class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class MockUser extends Mock implements User {}

// Helper to set up mock FirebaseAuth for AuthRepository tests
MockFirebaseAuth createMockFirebaseAuth({
  MockUserCredential? userCredential,
  MockUser? user,
  Stream<User?>? authStateStream,
}) {
  final mock = MockFirebaseAuth();
  when(() => mock.currentUser).thenReturn(user);
  when(() => mock.authStateChanges())
      .thenAnswer((_) => authStateStream ?? const Stream.empty());
  when(() => mock.signOut()).thenAnswer((_) async {});
  return mock;
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
        home: homeScreen ?? homeScreenFactory(),
      ),
    ),
  );
}

Future<void> pumpHomeScreenWithScope(WidgetTester tester,
    {Widget? homeScreen}) async {
  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp(
        home: homeScreen ?? HomeScreen(),
      ),
    ),
  );
}

Future<void> pumpWidgetWithRouterAndScope({
  required WidgetTester tester,
  required String initialLocation,
  required Map<String, Widget> routes,
}) async {
  final router = GoRouter(
    initialLocation: initialLocation,
    routes: routes.entries
        .map((entry) => GoRoute(
              path: entry.key,
              builder: (context, state) {
                final widget = entry.value;
                if (widget is HomeScreen) {
                  return HomeScreen();
                }
                return widget;
              },
            ))
        .toList(),
  );

  await tester.pumpWidget(
    ProviderScope(
      child: MaterialApp.router(
        routerConfig: router,
      ),
    ),
  );
}

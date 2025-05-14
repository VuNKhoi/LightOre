import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/core/presentation/auth_gate.dart';
import 'package:lightore/features/auth/application/auth_notifier.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

// Test AuthNotifier
class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(MockAuthRepository mock) : super(mock) {
    state = AuthState.unauthenticated(); // Skip _init
  }

  @override
  Future<void> login() async {
    await super.login(); // uses _authRepository internally
    state = AuthState.authenticated(); // force deterministic state
  }
}

// Helper function to create and mock the AuthRepository
MockAuthRepository createMockAuthRepository() {
  final mockAuthRepository = MockAuthRepository();
  when(() => mockAuthRepository.setAuthenticated(true))
      .thenAnswer((_) async {});
  when(() => mockAuthRepository.clear()).thenAnswer((_) async {});
  return mockAuthRepository;
}

// Helper function to create a common router setup
GoRouter createRouter(Widget loginScreen, Widget homeScreen) {
  return GoRouter(
    initialLocation: '/login',
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => loginScreen,
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => homeScreen,
      ),
    ],
  );
}

// Helper function to pump a widget with a mock auth repository and router
Future<void> pumpWidgetWithAuth(
  WidgetTester tester,
  Widget screen,
  MockAuthRepository mockAuthRepository,
  Widget homeScreen, {
  List<Override>? overrides,
}) async {
  final testAuthNotifier = TestAuthNotifier(mockAuthRepository);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => testAuthNotifier),
        if (overrides != null) ...overrides,
      ],
      child: MaterialApp.router(
        routerConfig: createRouter(screen, homeScreen),
        builder: (context, child) => AuthGate(child: child!),
      ),
    ),
  );
}

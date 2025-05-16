import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_notifier.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

// Mock AuthRepository
class MockAuthRepository extends Mock implements AuthRepository {}

// Test AuthNotifier
class TestAuthNotifier extends AuthNotifier {
  TestAuthNotifier(MockAuthRepository mock) : super(mock);
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
      builder: (context, state) => const Scaffold(body: Text('Login Screen')),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const Scaffold(body: Text('Home Screen')),
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

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_status.dart';

import '../../../test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = createMockAuthRepository();
  });

  // Helper to create the provider container
  ProviderContainer createContainer() {
    final container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWith((ref) => mockAuthRepository),
      ],
    );
    addTearDown(container.dispose);
    return container;
  }

  group('AuthNotifier', () {
    test('initial state is unknown', () {
      final container = createContainer();
      final state = container.read(authProvider);
      expect(state.status, AuthStatus.unknown);
    });

    test('login() sets state to authenticated', () async {
      when(() => mockAuthRepository.setAuthenticated(true))
          .thenAnswer((_) async {});

      final container = createContainer();
      final notifier = container.read(authProvider.notifier);

      await notifier.login();

      expect(container.read(authProvider).status, AuthStatus.authenticated);
      verify(() => mockAuthRepository.setAuthenticated(true)).called(1);
    });

    test('logout() sets state to unauthenticated', () async {
      when(() => mockAuthRepository.setAuthenticated(false))
          .thenAnswer((_) async {});

      final container = createContainer();
      final notifier = container.read(authProvider.notifier);

      await notifier.logout();

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
      verify(() => mockAuthRepository.setAuthenticated(false)).called(1);
    });

    test('setUnknown() sets state to unknown', () async {
      when(() => mockAuthRepository.clear()).thenAnswer((_) async {});

      final container = createContainer();
      final notifier = container.read(authProvider.notifier);

      await notifier.setUnknown();

      expect(container.read(authProvider).status, AuthStatus.unknown);
      verify(() => mockAuthRepository.clear()).called(1);
    });

    test('_init() sets state to authenticated if isAuthenticated returns true',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);

      final container = createContainer();
      await Future.delayed(
          const Duration(milliseconds: 1)); // allow _init to complete

      expect(container.read(authProvider).status, AuthStatus.authenticated);
    });

    test(
        '_init() sets state to unauthenticated if isAuthenticated returns false',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);

      final container = createContainer();
      await Future.delayed(
          const Duration(milliseconds: 1)); // allow _init to complete

      expect(container.read(authProvider).status, AuthStatus.unauthenticated);
    });

    test('_init() keeps state unknown if isAuthenticated returns null',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => null);

      final container = createContainer();
      await Future.delayed(
          const Duration(milliseconds: 1)); // allow _init to complete

      expect(container.read(authProvider).status, AuthStatus.unknown);
    });
  });
}

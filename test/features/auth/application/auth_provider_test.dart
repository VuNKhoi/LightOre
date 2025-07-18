import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/features/auth/domain/auth_status.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';

import '../../../test_helpers.dart';

void main() {
  group('AuthProvider Tests', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = createMockAuthRepository();
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => null);
      // ProviderContainer will be initialized in each test
    });

    tearDown(() {
      container.dispose();
    });

    test('authRepositoryProvider provides an instance of AuthRepository', () {
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final authRepository = container.read(authRepositoryProvider(null));
      expect(authRepository, isA<AuthRepository>());
    });

    test('authProvider initializes with AuthNotifier and AuthState', () {
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final authState = container.read(authProvider);
      expect(authState, isA<AuthState>());
    });

    test(
        'authProvider updates state and returns true when AuthNotifier login succeeds',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.setAuthenticated(true))
          .thenAnswer((_) async => true);
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.login();
      expect(result, true);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.authenticated);
    });

    test(
        'authProvider does not update state and returns false when AuthNotifier login fails',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => null);
      when(() => mockAuthRepository.setAuthenticated(true))
          .thenAnswer((_) async => false);
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.login();
      expect(result, false);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unknown);
    });

    test(
        'authProvider updates state and returns true when AuthNotifier logout succeeds',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.setAuthenticated(false))
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async => Future.value());
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.logout();
      expect(result, true);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unauthenticated);
    });

    test(
        'authProvider does not update state and returns false when AuthNotifier logout fails',
        () async {
      when(() => mockAuthRepository.isAuthenticated())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.setAuthenticated(false))
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async => Future.value());
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.logout();
      expect(result, false);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.authenticated);
    });

    test(
        'authProvider updates state and returns true when AuthNotifier setUnknown succeeds',
        () async {
      when(() => mockAuthRepository.clear()).thenAnswer((_) async => true);
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.setUnknown();
      expect(result, true);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unknown);
    });

    test(
        'authProvider does not update state and returns false when AuthNotifier setUnknown fails',
        () async {
      when(() => mockAuthRepository.clear()).thenAnswer((_) async => false);
      container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWith((ref, _) => mockAuthRepository),
        authProvider
            .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
      ]);
      final notifier = container.read(authProvider.notifier);
      final result = await notifier.setUnknown();
      expect(result, false);
      final authState = container.read(authProvider);
      expect(authState.status, AuthStatus.unknown);
    });
  });
}

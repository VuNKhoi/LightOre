import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_status.dart';

import '../../../test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;
  ProviderContainer? container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = null;
  });

  tearDown(() {
    if (container != null) {
      container!.dispose();
    }
  });

  group('AuthNotifier', () {
    test('initial state is unknown', () {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      final state = container!.read(authProvider);
      expect(state.status, AuthStatus.unknown);
    });

    test('login() sets state to authenticated and returns true', () async {
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.login();
      expect(result, true);
      expect(container!.read(authProvider).status, AuthStatus.authenticated);
      verify(() => mockAuthRepository.setAuthenticated(true)).called(1);
    });

    test('login() does not set state if repository returns false', () async {
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((invocation) async => invocation.positionalArguments[0] == true ? false : true);
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.login();
      expect(result, false);
      expect(container!.read(authProvider).status, AuthStatus.unknown);
      verify(() => mockAuthRepository.setAuthenticated(true)).called(1);
    });

    test('logout() sets state to unauthenticated and returns true', () async {
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.logout();
      expect(result, true);
      expect(container!.read(authProvider).status, AuthStatus.unauthenticated);
      verify(() => mockAuthRepository.setAuthenticated(false)).called(1);
    });

    test('logout() does not set state if repository returns false', () async {
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((invocation) async => invocation.positionalArguments[0] == false ? false : true);
      when(() => mockAuthRepository.signOut()).thenAnswer((_) async {});
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.logout();
      expect(result, false);
      expect(container!.read(authProvider).status, AuthStatus.unknown);
      verify(() => mockAuthRepository.setAuthenticated(false)).called(1);
    });

    test('setUnknown() sets state to unknown and returns true', () async {
      when(() => mockAuthRepository.clear()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.setUnknown();
      expect(result, true);
      expect(container!.read(authProvider).status, AuthStatus.unknown);
      verify(() => mockAuthRepository.clear()).called(1);
    });

    test('setUnknown() does not set state if repository returns false', () async {
      when(() => mockAuthRepository.clear()).thenAnswer((_) async => false);
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      final notifier = container!.read(authProvider.notifier);
      final result = await notifier.setUnknown();
      expect(result, false);
      expect(container!.read(authProvider).status, AuthStatus.unknown);
      verify(() => mockAuthRepository.clear()).called(1);
    });

    test('init() sets state to authenticated if isAuthenticated returns true', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => true);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      await container!.read(authProvider.notifier).init();
      final state = container!.read(authProvider).status;
      expect(state, AuthStatus.authenticated);
    });

    test('init() sets state to unauthenticated if isAuthenticated returns false', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => false);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      await container!.read(authProvider.notifier).init();
      final state = container!.read(authProvider).status;
      expect(state, AuthStatus.unauthenticated);
    });

    test('init() keeps state unknown if isAuthenticated returns null', () async {
      when(() => mockAuthRepository.isAuthenticated()).thenAnswer((_) async => null);
      when(() => mockAuthRepository.setAuthenticated(any())).thenAnswer((_) async => true);
      container = createTestProviderContainer(mockAuthRepository);
      await container!.read(authProvider.notifier).init();
      final state = container!.read(authProvider).status;
      expect(state, AuthStatus.unknown);
    });
  });
}

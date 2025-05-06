import 'package:flutter_test/flutter_test.dart';
import 'package:your_app/auth/auth_state.dart';
import 'package:your_app/auth/auth_notifier.dart';
import 'package:your_app/repositories/auth_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MockAuthRepository implements AuthRepository {
  bool _isSubscribed = false;
  bool loggedOut = false;
  bool shouldThrowOnCheckSubscription = false;
  bool shouldDelayUserFetch = false;

  @override
  Future<User?> getCurrentUser() async {
    if (shouldDelayUserFetch) await Future.delayed(const Duration(seconds: 2));
    return User(id: '1', email: 'premium@example.com');
  }

  @override
  Future<User> login(String email, String password) async {
    if (email == 'premium@example.com') {
      _isSubscribed = true;
      return User(id: '1', email: email);
    }
    if (email == 'test@example.com') {
      _isSubscribed = false;
      return User(id: '2', email: email);
    }
    throw AuthException('Invalid credentials');
  }

  @override
  Future<void> logout() async {
    _isSubscribed = false;
    loggedOut = true;
  }

  @override
  Future<bool> checkSubscription(String userId) async {
    if (shouldThrowOnCheckSubscription) throw Exception('Subscription check failed');
    return _isSubscribed;
  }
}

void main() {
  late ProviderContainer container;
  setUp(() {
    container = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
    ]);
  });

  group('Auth Notifier', () {
    test('auto-login when user is already authenticated', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      final notifier = container.read(authStateProvider.notifier);
      await notifier.checkLoggedInUser();
      final state = container.read(authStateProvider);
      expect(state.isAuthenticated, true);
    });

    test('subscription check failure falls back safely', () async {
      final mockRepo = MockAuthRepository()..shouldThrowOnCheckSubscription = true;
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      final notifier = container.read(authStateProvider.notifier);
      await notifier.login('premium@example.com', 'password');
      final state = container.read(authStateProvider);
      expect(state.isSubscribed, false);
    });

    test('logout sets auth state to unauthenticated', () async {
      final mockRepo = MockAuthRepository();
      final container = ProviderContainer(overrides: [
        authRepositoryProvider.overrideWithValue(mockRepo),
      ]);
      final notifier = container.read(authStateProvider.notifier);
      await notifier.login('premium@example.com', 'password');
      expect(container.read(authStateProvider).isAuthenticated, true);
      await notifier.logout();
      expect(container.read(authStateProvider).isAuthenticated, false);
      expect(mockRepo.loggedOut, true);
    });
  });
}

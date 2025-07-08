import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_notifier.dart';
import 'package:lightore/navigation/navigation_guard.dart' as nav;
import 'package:lightore/repositories/auth_repository.dart';

class FakeAuthNotifier extends AuthNotifier {
  FakeAuthNotifier(AuthState state) : super(_FakeAuthRepository()) {
    super.state = state;
  }
}

class _FakeAuthRepository implements AuthRepository {
  bool? _isAuthenticated;
  _FakeAuthRepository();

  @override
  Future<bool?> isAuthenticated() async => _isAuthenticated;

  @override
  Future<bool> setAuthenticated(bool isAuthenticated) async {
    _isAuthenticated = isAuthenticated;
    return true;
  }

  @override
  Future<bool> clear() async {
    _isAuthenticated = null;
    return true;
  }

  // Implement only the methods needed for AuthNotifier
  @override
  noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  ProviderContainer makeContainer(AuthState state) {
    return ProviderContainer(overrides: [
      authProvider.overrideWith((ref) => FakeAuthNotifier(state)),
    ]);
  }

  test('redirect unauthenticated to /login', () {
    final container = makeContainer(AuthState.unauthenticated());
    final guard = container.read(nav.navigationGuardProvider);
    expect(guard.redirect('/home'), '/login');
    expect(guard.redirect('/register'), null);
    expect(guard.redirect('/login'), null);
  });

  test('redirect authenticated to /home', () {
    final container = makeContainer(AuthState.authenticated());
    final guard = container.read(nav.navigationGuardProvider);
    expect(guard.redirect('/login'), '/home');
    expect(guard.redirect('/register'), '/home');
    expect(guard.redirect('/home'), null);
  });

  test('no redirect for unknown status except /home', () {
    final container = makeContainer(AuthState.unknown());
    final guard = container.read(nav.navigationGuardProvider);
    expect(guard.redirect('/login'), null);
    expect(guard.redirect('/register'), null);
    expect(guard.redirect('/home'), '/login');
  });
}

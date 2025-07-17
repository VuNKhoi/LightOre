import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/application/auth_state.dart';
import 'package:lightore/features/auth/domain/auth_status.dart';

void main() {
  group('AuthState', () {
    test('unknown factory sets status to unknown', () {
      final state = AuthState.unknown();
      expect(state.status, AuthStatus.unknown);
    });

    test('authenticated factory sets status to authenticated', () {
      final state = AuthState.authenticated();
      expect(state.status, AuthStatus.authenticated);
    });

    test('unauthenticated factory sets status to unauthenticated', () {
      final state = AuthState.unauthenticated();
      expect(state.status, AuthStatus.unauthenticated);
    });
  });
}

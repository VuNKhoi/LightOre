import 'package:lightore/features/auth/domain/auth_status.dart';

class AuthState {
  final AuthStatus status;

  AuthState._(this.status);

  factory AuthState.unknown() {
    return AuthState._(AuthStatus.unknown);
  }

  factory AuthState.unauthenticated() {
    return AuthState._(AuthStatus.unauthenticated);
  }

  factory AuthState.authenticated() {
    return AuthState._(AuthStatus.authenticated);
  }
}

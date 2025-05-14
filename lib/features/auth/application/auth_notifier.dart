// lib/features/auth/application/auth_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.unknown()) {
    _init();
  }

  Future<void> _init() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth == true) {
      state = AuthState.authenticated();
    } else if (isAuth == false) {
      state = AuthState.unauthenticated();
    } else {
      state = AuthState.unknown();
    }
  }

  Future<void> login() async {
    await _authRepository.setAuthenticated(true);
    state = AuthState.authenticated();
  }

  Future<void> logout() async {
    await _authRepository.setAuthenticated(false);
    state = AuthState.unauthenticated();
  }

  Future<void> setUnknown() async {
    await _authRepository.clear();
    state = AuthState.unknown();
  }
}

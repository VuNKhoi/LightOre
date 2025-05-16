// lib/features/auth/application/auth_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:meta/meta.dart';
import 'auth_state.dart';

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(AuthState.unknown()) {
    init();
  }

  @visibleForTesting
  Future<void> init() async {
    final isAuth = await _authRepository.isAuthenticated();
    if (isAuth == true) {
      state = AuthState.authenticated();
    } else if (isAuth == false) {
      state = AuthState.unauthenticated();
    } else {
      state = AuthState.unknown();
    }
  }

  Future<bool> login() async {
    final success = await _authRepository.setAuthenticated(true);
    if (success) {
      state = AuthState.authenticated();
    }
    return success;
  }

  Future<bool> logout() async {
    final success = await _authRepository.setAuthenticated(false);
    if (success) {
      state = AuthState.unauthenticated();
    }
    return success;
  }

  Future<bool> setUnknown() async {
    final success = await _authRepository.clear();
    if (success) {
      state = AuthState.unknown();
    }
    return success;
  }
}

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/domain/auth_status.dart';

/// NavigationGuard decouples auth logic from router.
class NavigationGuard {
  final Ref ref;
  NavigationGuard(this.ref);

  String? redirect(String? location) {
    final authState = ref.read(authProvider);
    if (authState.status == AuthStatus.unknown ||
        authState.status == AuthStatus.unauthenticated) {
      if (location != '/login' && location != '/register') {
        return '/login';
      }
    } else if (authState.status == AuthStatus.authenticated) {
      if (location != '/home') {
        return '/home';
      }
    }
    return null;
  }
}

final navigationGuardProvider = Provider((ref) => NavigationGuard(ref));

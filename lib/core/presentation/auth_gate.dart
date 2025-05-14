// lib/core/presentation/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_status.dart';

class AuthGate extends ConsumerStatefulWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  ConsumerState<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends ConsumerState<AuthGate> {
  @override
  void initState() {
    super.initState();

    // Listen for auth changes and redirect accordingly
    ref.listen(authProvider, (previous, next) {
      final router = GoRouter.of(context);
      final location = router.routerDelegate.currentConfiguration.toString();

      switch (next.status) {
        case AuthStatus.unauthenticated:
          if (location != '/login') {
            router.go('/login');
          }
          break;
        case AuthStatus.authenticated:
          if (location == '/login') {
            router.go('/home');
          }
          break;
        case AuthStatus.unknown:
          // Stay in place or show splash
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

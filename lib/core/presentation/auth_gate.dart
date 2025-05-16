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
  Widget build(BuildContext context) {
    ref.listen(authProvider, (previous, next) {
      final router = GoRouter.of(context);

      // Debugging: Log state transitions
      print('AuthGate: Previous state: $previous, Next state: $next');

      if (next.status == AuthStatus.unauthenticated) {
        router.go('/login');
      } else if (next.status == AuthStatus.authenticated) {
        router.go('/home');
      }
    });

    return widget.child;
  }
}

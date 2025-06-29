// lib/core/presentation/auth_gate.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_status.dart';

class AuthGate extends StatelessWidget {
  final Widget child;
  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: MaterialType.transparency,
      child: Stack(
        children: [
          child,
          const AuthRedirector(),
        ],
      ),
    );
  }
}

class AuthRedirector extends ConsumerWidget {
  const AuthRedirector({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.listen(authProvider, (previous, next) {
      final router = GoRouter.of(context);
      final currentLocation =
          router.routerDelegate.currentConfiguration.uri.toString();
      if ((next.status == AuthStatus.unauthenticated ||
              next.status == AuthStatus.unknown) &&
          currentLocation != '/login') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/login');
        });
      } else if (next.status == AuthStatus.authenticated &&
          currentLocation != '/home') {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          router.go('/home');
        });
      }
    });
    return const SizedBox.shrink();
  }
}

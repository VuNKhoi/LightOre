import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/auth/application/auth_provider.dart';

class AuthGate extends ConsumerWidget {
  final Widget child;

  const AuthGate({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final status = ref.watch(authStatusProvider);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final router = GoRouter.of(context);

      if (status == AuthStatus.unauthenticated && router.location != '/auth') {
        router.go('/auth');
      } else if (status == AuthStatus.authenticated &&
          router.location == '/auth') {
        router.go('/home');
      }
    });

    return child;
  }
}

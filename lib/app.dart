import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/application/auth_status.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';

class LightOreApp extends ConsumerWidget {
  const LightOreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = createAppRouter(ref);
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}

GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final location = state.fullPath;
      if (authState.status == AuthStatus.unknown ||
          authState.status == AuthStatus.unauthenticated) {
        if (location != '/login') return '/login';
      } else if (authState.status == AuthStatus.authenticated) {
        if (location != '/home') return '/home';
      }
      return null;
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => const RegisterScreen(),
      ),
    ],
  );
}

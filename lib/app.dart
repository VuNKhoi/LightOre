import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'core/presentation/auth_gate.dart';
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
      builder: (context, child) => AuthGate(child: child!),
    );
  }
}

GoRouter createAppRouter(WidgetRef ref) {
  return GoRouter(
    initialLocation: '/home',
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lightore/navigation/navigation_guard.dart';
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
  final guard = ref.read(navigationGuardProvider);
  return GoRouter(
    initialLocation: '/home',
    redirect: (context, state) {
      final location = state.fullPath;
      return guard.redirect(location);
    },
    routes: [
      GoRoute(
        path: '/login',
        builder: (context, state) => loginScreenFactory(),
      ),
      GoRoute(
        path: '/register',
        builder: (context, state) => registerScreenFactory(),
      ),
      GoRoute(
        path: '/home',
        builder: (context, state) => homeScreenFactory(),
      ),
    ],
  );
}

// Factories for screen construction (for DI/mocking)
Widget loginScreenFactory() => const LoginScreen();
Widget registerScreenFactory() => const RegisterScreen();
Widget homeScreenFactory() => const HomeScreen();

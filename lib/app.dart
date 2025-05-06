import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:your_app/auth/auth_gate.dart';
import 'package:your_app/screens/login_screen.dart';
import 'package:your_app/screens/home_screen.dart';
import 'package:your_app/screens/paywall_screen.dart';
import 'package:your_app/auth/auth_state.dart';

class LightOreApp extends ConsumerWidget {
  const LightOreApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(path: '/', builder: (_, __) => const AuthGate()),
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(
          path: '/home',
          builder: (_, __) => const HomeScreen(),
          redirect: (_, state) {
            final auth = ref.read(authStateProvider);
            if (!auth.isAuthenticated) return '/login';
            if (!auth.isSubscribed) return '/paywall';
            return null;
          },
        ),
        GoRoute(
          path: '/paywall',
          builder: (_, __) => const PaywallScreen(),
          redirect: (_, state) {
            final auth = ref.read(authStateProvider);
            if (!auth.isAuthenticated) return '/login';
            if (auth.isSubscribed) return '/home';
            return null;
          },
        ),
      ],
      errorBuilder: (_, __) => const Scaffold(body: Text('404 Not Found')),
    );

    return MaterialApp.router(
      routerConfig: router,
      debugShowCheckedModeBanner: false,
    );
  }
}

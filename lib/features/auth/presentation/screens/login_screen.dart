// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';

class LoginScreen extends ConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login or Pay')),
      body: Center(
        child: ElevatedButton(
          onPressed: () async {
            await ref
                .read(authProvider.notifier)
                .login(); // will trigger redirect
          },
          child: const Text('Continue to Home'),
        ),
      ),
    );
  }
}

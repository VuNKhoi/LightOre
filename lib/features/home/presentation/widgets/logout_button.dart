import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:go_router/go_router.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      key: const Key('logout_button'),
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        if (context.mounted) {
          context.go('/login');
        }
      },
      child: const Text('Logout'),
    );
  }
}

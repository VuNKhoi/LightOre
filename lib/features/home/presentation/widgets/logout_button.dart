import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';

class LogoutButton extends ConsumerWidget {
  const LogoutButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      key: const Key('logout_button'),
      onPressed: () async {
        await ref.read(authProvider.notifier).logout();
        // Optionally, you can also clear any local state or show a message
      },
      child: const Text('Logout'),
    );
  }
}

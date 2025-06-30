import 'package:flutter/material.dart';
import 'package:lightore/features/home/presentation/widgets/logout_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                // Add any functionality you want here
                // For example, logout or navigate to another screen
              },
              child: const Text('Go to Another Screen'),
            ),
            const SizedBox(height: 20),
            const LogoutButton(),
          ],
        ),
      ),
    );
  }
}

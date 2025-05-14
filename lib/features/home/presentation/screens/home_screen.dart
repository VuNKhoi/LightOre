import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Home')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Add any functionality you want here
            // For example, logout or navigate to another screen
            print("User is on the home screen");
          },
          child: const Text('Go to Another Screen'),
        ),
      ),
    );
  }
}

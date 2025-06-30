import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebaseAuthGate extends StatelessWidget {
  final Widget authenticated;
  final Widget unauthenticated;
  const FirebaseAuthGate(
      {super.key, required this.authenticated, required this.unauthenticated});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasData) {
          return authenticated;
        }
        return unauthenticated;
      },
    );
  }
}

// This file is no longer needed. Keeping for reference, but not used in app.

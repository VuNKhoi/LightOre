import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'package:google_sign_in/google_sign_in.dart';

void main() async {
  await initFirebase();
  // Initialize GoogleSignIn (async, no custom clientId)
  await GoogleSignIn.instance.initialize();
  runApp(const ProviderScope(child: LightOreApp()));
}

Future<void> initFirebase() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform, // If using CLI
  );
}

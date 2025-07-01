// lib/features/auth/application/auth_provider.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'auth_notifier.dart';
import 'auth_state.dart';

final authRepositoryProvider = Provider.family<AuthRepository, FirebaseAuth?>(
  (ref, firebaseAuth) => AuthRepository(firebaseAuth: firebaseAuth),
);

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>(
  (ref) => AuthNotifier(ref.watch(authRepositoryProvider(null))),
);

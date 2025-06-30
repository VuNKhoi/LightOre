// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  static const _key = 'auth_status';

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Signs in with email and password.
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  /// Registers a new user with email and password.
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Returns the current user, or null if not signed in.
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes.
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sends a password reset email.
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Returns true if the value was set successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  Future<bool> setAuthenticated(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_key, isAuthenticated);
    } catch (_) {
      return false;
    }
  }

  Future<bool?> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key); // null means unknown
  }

  /// Returns true if the value was cleared successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (_) {
      return false;
    }
  }
}

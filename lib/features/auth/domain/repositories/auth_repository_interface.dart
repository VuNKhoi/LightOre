import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthRepository {
  Future<UserCredential> signInWithEmail(String email, String password);
  Future<UserCredential> registerWithEmail(String email, String password);
  Future<void> signOut();
  User? get currentUser;
  Stream<User?> get authStateChanges;
  Future<void> sendPasswordResetEmail(String email);
  Future<bool> setAuthenticated(bool isAuthenticated);
  Future<bool?> isAuthenticated();
  Future<bool> clear();
  Future<UserCredential> signInWithGoogle();
  Future<void> initializeGoogleSignIn(
      {String? clientId, String? serverClientId});
}

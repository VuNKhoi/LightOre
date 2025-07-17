// lib/repositories/auth_repository.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightore/features/auth/domain/repositories/auth_repository_interface.dart';

class AuthRepository implements IAuthRepository {
  final FirebaseAuth _firebaseAuth;
  static const _key = 'auth_status';

  AuthRepository({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Signs in with email and password.
  @override
  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _firebaseAuth.signInWithEmailAndPassword(
        email: email, password: password);
  }

  /// Registers a new user with email and password.
  @override
  Future<UserCredential> registerWithEmail(
      String email, String password) async {
    return await _firebaseAuth.createUserWithEmailAndPassword(
        email: email, password: password);
  }

  /// Signs out the current user.
  @override
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Returns the current user, or null if not signed in.
  @override
  User? get currentUser => _firebaseAuth.currentUser;

  /// Stream of auth state changes.
  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  /// Sends a password reset email.
  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth.sendPasswordResetEmail(email: email);
  }

  /// Returns true if the value was set successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  @override
  Future<bool> setAuthenticated(bool isAuthenticated) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.setBool(_key, isAuthenticated);
    } catch (_) {
      return false;
    }
  }

  @override
  Future<bool?> isAuthenticated() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_key); // null means unknown
  }

  /// Returns true if the value was cleared successfully, false otherwise.
  /// TODO: Consider returning a Result/Either type for richer error handling.
  @override
  Future<bool> clear() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return await prefs.remove(_key);
    } catch (_) {
      return false;
    }
  }

  /// Signs in with Google.
  @override
  Future<UserCredential> signInWithGoogle() async {
    final signIn = GoogleSignIn.instance;
    GoogleSignInAccount? user;
    if (signIn.supportsAuthenticate()) {
      user = await signIn.authenticate();
    } else {
      throw Exception('Google sign-in not supported on this platform');
    }
    // user cannot be null after authenticate()
    final auth = user.authentication;
    final credential = GoogleAuthProvider.credential(
      idToken: auth.idToken,
    );
    return await FirebaseAuth.instance.signInWithCredential(credential);
  }

  /// Initializes Google Sign-In.
  @override
  Future<void> initializeGoogleSignIn(
      {String? clientId, String? serverClientId}) async {
    final signIn = GoogleSignIn.instance;
    await signIn.initialize(clientId: clientId, serverClientId: serverClientId);
  }
}

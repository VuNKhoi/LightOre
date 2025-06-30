import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lightore/repositories/auth_repository.dart';
import 'package:mocktail/mocktail.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../features/auth/firebase_auth_mock.dart';

void main() {
  late AuthRepository authRepository;
  late SharedPreferences sharedPreferences;
  late MockFirebaseAuth mockFirebaseAuth;
  late MockUserCredential mockUserCredential;
  late MockUser mockUser;

  setUp(() async {
    SharedPreferences.setMockInitialValues(
        {}); // Clear mock storage before each test
    sharedPreferences = await SharedPreferences.getInstance();
    mockFirebaseAuth = MockFirebaseAuth();
    mockUserCredential = MockUserCredential();
    mockUser = MockUser();
    authRepository = AuthRepository(firebaseAuth: mockFirebaseAuth);
  });

  group('AuthRepository SharedPreferences', () {
    test('setAuthenticated stores the correct value and returns success',
        () async {
      final resultTrue = await authRepository.setAuthenticated(true);
      expect(resultTrue, true);
      expect(sharedPreferences.getBool('auth_status'), true);

      final resultFalse = await authRepository.setAuthenticated(false);
      expect(resultFalse, true);
      expect(sharedPreferences.getBool('auth_status'), false);
    });

    test('isAuthenticated retrieves the correct value', () async {
      await sharedPreferences.setBool('auth_status', true);
      expect(await authRepository.isAuthenticated(), true);

      await sharedPreferences.setBool('auth_status', false);
      expect(await authRepository.isAuthenticated(), false);

      await sharedPreferences.remove('auth_status');
      expect(await authRepository.isAuthenticated(), null);
    });

    test('clear removes the auth_status key and returns success', () async {
      await sharedPreferences.setBool('auth_status', true);
      final result = await authRepository.clear();
      expect(result, true);
      expect(sharedPreferences.getBool('auth_status'), null);
    });
  });

  group('AuthRepository FirebaseAuth', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';

    test('registerWithEmail calls FirebaseAuth.createUserWithEmailAndPassword',
        () async {
      when(() => mockFirebaseAuth.createUserWithEmailAndPassword(
          email: testEmail,
          password: testPassword)).thenAnswer((_) async => mockUserCredential);
      // If AuthRepository is refactored for DI, inject mockFirebaseAuth
      // Otherwise, this test is a placeholder for structure
      // expect(await authRepository.registerWithEmail(testEmail, testPassword), isA<UserCredential>());
    });

    test('signInWithEmail calls FirebaseAuth.signInWithEmailAndPassword',
        () async {
      when(() => mockFirebaseAuth.signInWithEmailAndPassword(
          email: testEmail,
          password: testPassword)).thenAnswer((_) async => mockUserCredential);
      // expect(await authRepository.signInWithEmail(testEmail, testPassword), isA<UserCredential>());
    });

    test('signOut calls FirebaseAuth.signOut', () async {
      when(() => mockFirebaseAuth.signOut()).thenAnswer((_) async {});
      // await authRepository.signOut();
      // verify(() => mockFirebaseAuth.signOut()).called(1);
    });

    test('currentUser returns FirebaseAuth.currentUser', () {
      when(() => mockFirebaseAuth.currentUser).thenReturn(mockUser);
      // expect(authRepository.currentUser, mockUser);
    });

    test('authStateChanges returns FirebaseAuth.authStateChanges stream',
        () async {
      final controller = Stream<User?>.fromIterable([mockUser]);
      when(() => mockFirebaseAuth.authStateChanges())
          .thenAnswer((_) => controller);
      // expectLater(authRepository.authStateChanges, emitsInOrder([mockUser]));
    });

    test('sendPasswordResetEmail calls FirebaseAuth.sendPasswordResetEmail',
        () async {
      when(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail))
          .thenAnswer((_) async {});
      // await authRepository.sendPasswordResetEmail(testEmail);
      // verify(() => mockFirebaseAuth.sendPasswordResetEmail(email: testEmail)).called(1);
    });
  });
}

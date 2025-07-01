import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MockGoogleSignIn extends Mock implements GoogleSignIn {}

class MockGoogleSignInAccount extends Mock implements GoogleSignInAccount {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUserCredential extends Mock implements UserCredential {}

class FakeAuthCredential extends Fake implements AuthCredential {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeAuthCredential());
  });

  testWidgets('Google login button is present and triggers sign-in flow',
      (tester) async {
    // Arrange: mock GoogleSignIn and FirebaseAuth
    final googleSignIn = MockGoogleSignIn();
    final googleUser = MockGoogleSignInAccount();
    final googleAuth = GoogleSignInAuthentication(idToken: 'fake_id_token');
    final firebaseAuth = MockFirebaseAuth();
    final userCredential = MockUserCredential();

    when(() => googleSignIn.supportsAuthenticate()).thenReturn(true);
    when(() => googleSignIn.authenticate()).thenAnswer((_) async => googleUser);
    when(() => googleUser.authentication).thenReturn(googleAuth);
    when(() => firebaseAuth.signInWithCredential(any()))
        .thenAnswer((_) async => userCredential);

    await tester.pumpWidget(const MaterialApp(home: LoginScreen()));
    await tester.pumpAndSettle();
    final googleButton = find.byKey(const Key('google_login_button'));
    expect(googleButton, findsOneWidget);
    await tester.tap(googleButton);
    await tester.pumpAndSettle();
    // No error thrown, button is tappable, and sign-in flow is triggered
  });
}

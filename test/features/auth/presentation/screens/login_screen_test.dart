import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/presentation/screens/login_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

void main() {
  late MockAuthRepository mockAuthRepository;

  setUp(() {
    mockAuthRepository = createMockAuthRepository();
  });

  // Helper to pump the login screen with test overrides.
  Future<void> pumpLogin(WidgetTester tester,
      {void Function(BuildContext context)? onLoginSuccess}) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider
              .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
        ],
        child: MaterialApp(
          home: LoginScreen(onLoginSuccess: onLoginSuccess),
          routes: {
            '/home': (_) => const Scaffold(
                body: Text('Home Screen', key: Key('home-screen'))),
            '/register': (_) => const Scaffold(
                body: Text('Register Screen', key: Key('register-screen'))),
            '/login': (_) => LoginScreen(onLoginSuccess: onLoginSuccess),
          },
        ),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('Login success navigates to /home', (tester) async {
    bool navigated = false;
    when(() => mockAuthRepository.signInWithEmail(any(), any()))
        .thenAnswer((_) async => MockUserCredential());
    await pumpLogin(tester, onLoginSuccess: (_) => navigated = true);

    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'test@example.com');
    await tester.enterText(
        find.byKey(const Key('login_password_field')), 'password123');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(navigated, isTrue);
  });

  testWidgets('Login failure shows error', (tester) async {
    when(() => mockAuthRepository.signInWithEmail(any(), any()))
        .thenThrow(Exception('Login failed'));
    await pumpLogin(tester, onLoginSuccess: (_) {});

    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'fail@example.com');
    await tester.enterText(
        find.byKey(const Key('login_password_field')), 'badpass');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();

    expect(
      find.textContaining('Login failed'),
      findsOneWidget,
      reason: 'Should show error message after login failure',
    );
  });

  testWidgets('Password reset success shows info message', (tester) async {
    when(() => mockAuthRepository.sendPasswordResetEmail(any()))
        .thenAnswer((_) async => Future.value());
    await pumpLogin(tester, onLoginSuccess: (_) {});

    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'reset@example.com');
    await tester.pump();
    await tester.tap(find.byKey(const Key('forgot_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('Password reset email sent!'), findsOneWidget);
  });

  testWidgets('Password reset with empty email shows error', (tester) async {
    await pumpLogin(tester, onLoginSuccess: (_) {});

    await tester.tap(find.byKey(const Key('forgot_password_button')));
    await tester.pumpAndSettle();

    expect(find.text('Enter your email to reset password'), findsOneWidget);
  });

  testWidgets('Navigates to register screen', (tester) async {
    await pumpLogin(tester, onLoginSuccess: (_) {});

    await tester.tap(find.byKey(const Key('go_to_register_button')));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('register-screen')), findsOneWidget);
  });

  testWidgets('Error/info messages clear on input change', (tester) async {
    when(() => mockAuthRepository.signInWithEmail(any(), any()))
        .thenThrow(Exception('Login failed'));
    await pumpLogin(tester, onLoginSuccess: (_) {});

    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'fail@example.com');
    await tester.enterText(
        find.byKey(const Key('login_password_field')), 'badpass');
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('login_button')));
    await tester.pumpAndSettle();
    expect(find.textContaining('Login failed. Please check your credentials.'),
        findsOneWidget);

    // Change email to clear error
    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'new@example.com');
    await tester.pumpAndSettle();
    expect(find.textContaining('Login failed. Please check your credentials.'),
        findsNothing);
  });

  testWidgets('Login button disabled if fields are empty', (tester) async {
    await pumpLogin(tester, onLoginSuccess: (_) {});

    var loginButton =
        tester.widget<ElevatedButton>(find.byKey(const Key('login_button')));
    expect(loginButton.onPressed, isNull);

    await tester.enterText(
        find.byKey(const Key('login_email_field')), 'a@b.com');
    await tester.pumpAndSettle();
    loginButton =
        tester.widget<ElevatedButton>(find.byKey(const Key('login_button')));
    expect(loginButton.onPressed, isNull);

    // Enter a short password (invalid)
    await tester.enterText(find.byKey(const Key('login_password_field')), 'pw');
    await tester.pumpAndSettle();
    loginButton =
        tester.widget<ElevatedButton>(find.byKey(const Key('login_button')));
    expect(loginButton.onPressed, isNull);

    // Enter a valid password (6+ chars)
    await tester.enterText(
        find.byKey(const Key('login_password_field')), 'password123');
    await tester.pumpAndSettle();
    loginButton =
        tester.widget<ElevatedButton>(find.byKey(const Key('login_button')));
    expect(loginButton.onPressed, isNotNull);
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/auth/presentation/screens/register_screen.dart';
import 'package:mocktail/mocktail.dart';

import '../../../../test_helpers.dart';

void main() {
  group('RegisterScreen', () {
    late MockAuthRepository mockAuthRepository;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepository = createMockAuthRepository();
      container = createTestProviderContainer(mockAuthRepository);
    });

    tearDown(() {
      container.dispose();
    });

    Route<dynamic>? onGenerateRoute(RouteSettings settings) {
      switch (settings.name) {
        case '/home':
          return MaterialPageRoute(
              builder: (_) => const Scaffold(
                  body: Text('Home Screen', key: Key('home-screen'))));
        case '/login':
          return MaterialPageRoute(
              builder: (_) => const Scaffold(
                  body: Text('Login Screen', key: Key('login-screen'))));
        case '/register':
        default:
          return MaterialPageRoute(builder: (_) => const RegisterScreen());
      }
    }

    Future<void> pumpRegister(WidgetTester tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authProvider
                .overrideWith((ref) => MockAuthNotifier(mockAuthRepository)),
          ],
          child: MaterialApp(
            initialRoute: '/register',
            onGenerateRoute: onGenerateRoute,
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('Register success navigates to /home', (tester) async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenAnswer((_) async => MockUserCredential());
      await pumpRegister(tester);

      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.byKey(const Key('home-screen')), findsOneWidget);
    });

    testWidgets('Register failure shows error', (tester) async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenThrow(Exception('Register failed'));
      await pumpRegister(tester);

      await tester.enterText(
          find.byType(TextFormField).at(0), 'fail@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'badpass');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(
          find.textContaining(
              'Register failed. Please check your credentials.'),
          findsOneWidget);
    });

    testWidgets('Validation error for invalid email and short password',
        (tester) async {
      await pumpRegister(tester);

      await tester.enterText(find.byType(TextFormField).at(0), 'invalid');
      await tester.enterText(find.byType(TextFormField).at(1), '123');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Min 6 chars'), findsOneWidget);
    });

    testWidgets('Error/info messages clear on input change', (tester) async {
      when(() => mockAuthRepository.registerWithEmail(any(), any()))
          .thenThrow(Exception('Register failed'));
      await pumpRegister(tester);

      await tester.enterText(
          find.byType(TextFormField).at(0), 'fail@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'badpass');
      await tester.pump();
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              'Register failed. Please check your credentials.'),
          findsOneWidget);

      // Change email to clear error
      await tester.enterText(
          find.byType(TextFormField).at(0), 'new@example.com');
      await tester.pumpAndSettle();
      expect(
          find.textContaining(
              'Register failed. Please check your credentials.'),
          findsNothing);
    });

    testWidgets('Navigates to login screen', (tester) async {
      await pumpRegister(tester);
      await tester.tap(find.byType(TextButton));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login-screen')), findsOneWidget);
    });
  });
}

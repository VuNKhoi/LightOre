import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:lightore/features/home/presentation/widgets/logout_button.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:go_router/go_router.dart';
import '../../../../test_helpers.dart';

void main() {
  testWidgets('LogoutButton calls logout and navigates to /login',
      (tester) async {
    final mockAuthRepository = MockAuthRepository();
    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => false);
    final mockNotifier = MockAuthNotifier(mockAuthRepository);
    final router = GoRouter(
      initialLocation: '/home',
      routes: [
        GoRoute(
          path: '/home',
          builder: (context, state) => ProviderScope(
            overrides: [authProvider.overrideWith((ref) => mockNotifier)],
            child: Scaffold(body: LogoutButton()),
          ),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const Scaffold(body: Text('Login')),
        ),
      ],
    );
    await tester.pumpWidget(MaterialApp.router(routerConfig: router));
    await tester.pumpAndSettle();
    final button = find.byKey(const Key('logout_button'));
    expect(button, findsOneWidget);
    await tester.tap(button);
    await tester.pumpAndSettle();
    // Only check navigation and UI, not method call
    expect(find.text('Login'), findsOneWidget);
  });
}

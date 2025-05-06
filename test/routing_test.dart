import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/screens/login_screen.dart';
import 'package:lightore/screens/home_screen.dart';
import 'package:lightore/screens/paywall_screen.dart';
import 'package:lightore/repositories/auth_repository.dart';

import 'auth_notifier_test.dart';
import 'test_utils.dart';

void main() {
  testWidgets('unknown route shows 404 screen', (tester) async {
    await pumpAppWithOverrides(tester, [
      authRepositoryProvider.overrideWithValue(MockAuthRepository()),
    ]);
    await navigateTo(tester, '/does-not-exist');
    await tester.pumpAndSettle();
    expect(find.text('404 Not Found'), findsOneWidget);
  });

  testWidgets('unauthenticated user redirected to login', (tester) async {
    final mockRepo = MockAuthRepository();
    await pumpAppWithOverrides(tester, [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    await navigateTo(tester, '/home');
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('unsubscribed user redirected to paywall from /home',
      (tester) async {
    final mockRepo = MockAuthRepository();
    mockRepo._isSubscribed = false;
    final testContainer = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    final notifier = testContainer.read(authStateProvider.notifier);
    await notifier.login('test@example.com', 'password');

    await pumpAppWithOverrides(tester, [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    await navigateTo(tester, '/home');
    await tester.pumpAndSettle();
    expect(find.byType(PaywallScreen), findsOneWidget);
  });

  testWidgets('subscribed user redirected to home from /paywall',
      (tester) async {
    final mockRepo = MockAuthRepository();
    mockRepo._isSubscribed = true;
    final testContainer = ProviderContainer(overrides: [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    final notifier = testContainer.read(authStateProvider.notifier);
    await notifier.login('premium@example.com', 'password');

    await pumpAppWithOverrides(tester, [
      authRepositoryProvider.overrideWithValue(mockRepo),
    ]);
    await navigateTo(tester, '/paywall');
    await tester.pumpAndSettle();
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}

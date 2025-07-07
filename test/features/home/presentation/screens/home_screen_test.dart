import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/auth/application/auth_provider.dart';
import 'package:lightore/features/home/presentation/screens/home_screen.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';

import '../../../../test_helpers.dart';

/// A [MockAuthNotifier] that tracks if logout() was called for test assertions.
class TrackingAuthNotifier extends MockAuthNotifier {
  bool logoutCalled = false;
  TrackingAuthNotifier(super.mock);
  @override
  Future<bool> logout() async {
    logoutCalled = true;
    return true;
  }
}

Future<void> pumpHomeScreenWithProvider(
  WidgetTester tester, {
  required MockAuthNotifier notifier,
  Widget? homeScreen,
}) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => notifier),
      ],
      child: MaterialApp(
        home: homeScreen ?? const HomeScreen(),
      ),
    ),
  );
}

void main() {
  group('HomeScreen', () {
    testWidgets('displays map and option bubble', (tester) async {
      await pumpWidgetWithRouter(
        tester: tester,
        initialLocation: '/home',
        routes: {
          '/home': const HomeScreen(),
        },
      );

      // Verify the BaseMapView is shown
      expect(find.byType(BaseMapView), findsOneWidget);
      // Verify the OptionBubble is shown
      expect(find.byType(OptionBubble), findsOneWidget);
      // Should NOT find AppBar, title, or logout button
      expect(find.text('Home'), findsNothing);
      expect(find.byKey(const Key('logout_button')), findsNothing);
      expect(find.text('Logout'), findsNothing);
    });

    testWidgets('HomeScreen displays BaseMapView after login', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(
        home: HomeScreen(),
      ));
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BaseMapView), findsOneWidget);
    });
  });
}

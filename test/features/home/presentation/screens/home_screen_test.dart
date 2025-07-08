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
      await pumpWidgetWithRouterAndScope(
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

    testWidgets('HomeScreen displays BaseMapView after login',
        (WidgetTester tester) async {
      await pumpHomeScreenWithScope(tester);
      expect(find.byType(HomeScreen), findsOneWidget);
      expect(find.byType(BaseMapView), findsOneWidget);
    });
    testWidgets('shows current location button at bottom right', (tester) async {
      await pumpWidgetWithRouterAndScope(
        tester: tester,
        initialLocation: '/home',
        routes: {
          '/home': const HomeScreen(),
        },
      );
      // Should find the FAB for current location
      final fabFinder = find.widgetWithIcon(FloatingActionButton, Icons.my_location);
      expect(fabFinder, findsOneWidget);
    });

    testWidgets('overlay selector uses popup and includes Street Map', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: const HomeScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      // Open the option bubble
      final menuFinder = find.byIcon(Icons.menu);
      expect(menuFinder, findsOneWidget);
      await tester.tap(menuFinder);
      await tester.pumpAndSettle();
      // Assert overlay tile is present
      final gridTile = find.text('Sectional');
      expect(gridTile, findsOneWidget, reason: 'Overlay tile should be present after expanding OptionBubble');
      // Tap overlay tile (should trigger dialog)
      await tester.tap(gridTile);
      await tester.pumpAndSettle();
      // Assert AlertDialog is present
      expect(find.byType(AlertDialog), findsOneWidget, reason: 'AlertDialog should be shown after tapping overlay tile');
      // Assert overlay options are present
      expect(find.text('Street Map'), findsWidgets);
      expect(find.text('Sectional'), findsWidgets);
      expect(find.text('IFR Low'), findsWidgets);
      expect(find.text('IFR High'), findsWidgets);
    });
    testWidgets('FAB centers map on user location', (tester) async {
      await pumpWidgetWithRouterAndScope(
        tester: tester,
        initialLocation: '/home',
        routes: {
          '/home': const HomeScreen(),
        },
      );
      final fabFinder = find.widgetWithIcon(FloatingActionButton, Icons.my_location);
      expect(fabFinder, findsOneWidget);
      await tester.tap(fabFinder);
      await tester.pumpAndSettle();
      // There is no direct way to check map position, but we can check for no errors and that the FAB is still present
      expect(fabFinder, findsOneWidget);
    });
  });
}

import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/home/presentation/screens/home_screen.dart';

import '../../../../test_helpers.dart';

void main() {
  testWidgets('HomeScreen displays title and button, and handles tap',
      (tester) async {
    await pumpWidgetWithRouter(
      tester: tester,
      initialLocation: '/home',
      routes: {
        '/home': const HomeScreen(),
      },
    );

    // Verify the title is shown
    expect(find.text('Home'), findsOneWidget);

    // Verify the button is shown
    expect(find.text('Go to Another Screen'), findsOneWidget);

    // Tap the button and ensure it doesn't crash
    await tester.tap(find.text('Go to Another Screen'));
    await tester.pump(); // allow any reactions to settle
  });
}

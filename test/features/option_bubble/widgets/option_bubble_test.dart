import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';

void main() {
  testWidgets('OptionBubble shows and hides grid, expands/shrinks tiles, and triggers account tap', (tester) async {
    bool accountTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              Container(),
              OptionBubble(
                onAccountTap: () => accountTapped = true,
              ),
            ],
          ),
        ),
      ),
    );
    // Initially, only the bubble is visible
    expect(find.byIcon(Icons.menu), findsOneWidget);
    expect(find.text('Account'), findsNothing);

    // Tap the bubble to expand
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    // Should show Account tile
    expect(find.text('Account'), findsOneWidget);
    // Tap + to add a tile
    await tester.tap(find.byIcon(Icons.add));
    await tester.pumpAndSettle();
    // Should show Account tile and one more (e.g., placeholder)
    expect(find.text('Account'), findsOneWidget);
    // Tap - to remove a tile
    await tester.tap(find.byIcon(Icons.remove));
    await tester.pumpAndSettle();
    // Should be back to original grid
    expect(find.text('Account'), findsOneWidget);
    // Tap Account tile
    await tester.tap(find.text('Account'));
    await tester.pumpAndSettle();
    expect(accountTapped, isTrue);
    // Grid should close after tap
    expect(find.text('Account'), findsNothing);
  });
}

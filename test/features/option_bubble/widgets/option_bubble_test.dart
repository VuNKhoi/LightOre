import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';

void main() {
  testWidgets(
      'OptionBubble shows and hides grid, expands/shrinks tiles, and triggers account tap',
      (tester) async {
    // This test verifies the OptionBubble expands, shrinks, and triggers the account callback.
    bool accountTapped = false;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
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

  testWidgets('OptionBubble can be dragged to a new position', (tester) async {
    // This test verifies the OptionBubble can be dragged around the screen.
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              OptionBubble(),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    final bubbleFinder = find.byIcon(Icons.menu);
    expect(bubbleFinder, findsOneWidget);
    // Get initial position
    final initial = tester.getCenter(bubbleFinder);
    // Drag the bubble by 100 pixels right and 50 pixels down
    await tester.drag(bubbleFinder, const Offset(100, 50));
    await tester.pumpAndSettle();
    final after = tester.getCenter(bubbleFinder);
    expect(after.dx, greaterThan(initial.dx));
    expect(after.dy, greaterThan(initial.dy));
  });

  testWidgets(
      'OptionBubble overlay selector: opens compact popup, selects overlay, updates indicator',
      (tester) async {
    // This test verifies the overlay selector modal opens, allows selection, and updates the indicator.
    await tester.pumpWidget(
      MaterialApp(
        home: _TestOverlayHome(),
      ),
    );
    // Open the grid
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    // Find the overlay tile (should show current overlay, e.g., 'Sectional')
    final overlayTile = find.text('Sectional');
    expect(overlayTile, findsOneWidget);
    // Tap the overlay tile to open the compact selector
    await tester.tap(overlayTile);
    await tester.pumpAndSettle();
    await tester.pump(
        const Duration(milliseconds: 500)); // Extra time for modal animation
    // Use a custom predicate finder for the ListTile with title 'IFR Low'
    final ifrLowTileFinder = find.byWidgetPredicate((widget) {
      if (widget is ListTile && widget.title is Text) {
        final text = widget.title as Text;
        return text.data == 'IFR Low';
      }
      return false;
    }, description: 'ListTile with title IFR Low');
    expect(ifrLowTileFinder, findsOneWidget,
        reason: 'Custom predicate: ListTile with IFR Low should be present');
    await tester.tap(ifrLowTileFinder);
    await tester.pumpAndSettle();
    // Re-expand the OptionBubble to check the updated indicator
    await tester.tap(find.byIcon(Icons.menu));
    await tester.pumpAndSettle();
    // The indicator should update to 'IFR Low'
    expect(find.text('IFR Low'), findsOneWidget);
  });
}

/// Test widget that mimics the real overlay selection logic and state management.
class _TestOverlayHome extends StatefulWidget {
  const _TestOverlayHome();
  @override
  State<_TestOverlayHome> createState() => _TestOverlayHomeState();
}

class _TestOverlayHomeState extends State<_TestOverlayHome> {
  MapOverlayType _selectedOverlay = MapOverlayType.sectional;
  void _showOverlaySelector() async {
    final selected = await showModalBottomSheet<MapOverlayType>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.map),
                title: const Text('Sectional (Default)'),
                selected: _selectedOverlay == MapOverlayType.sectional,
                onTap: () => Navigator.pop(context, MapOverlayType.sectional),
              ),
              ListTile(
                leading: const Icon(Icons.alt_route),
                title: const Text('IFR Low'),
                selected: _selectedOverlay == MapOverlayType.ifrLow,
                onTap: () => Navigator.pop(context, MapOverlayType.ifrLow),
              ),
              ListTile(
                leading: const Icon(Icons.flight),
                title: const Text('IFR High'),
                selected: _selectedOverlay == MapOverlayType.ifrHigh,
                onTap: () => Navigator.pop(context, MapOverlayType.ifrHigh),
              ),
            ],
          ),
        );
      },
    );
    if (selected != null && selected != _selectedOverlay) {
      setState(() => _selectedOverlay = selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: OptionBubble(
        overlayType: _selectedOverlay,
        onOverlayTap: _showOverlaySelector,
      ),
    );
  }
}

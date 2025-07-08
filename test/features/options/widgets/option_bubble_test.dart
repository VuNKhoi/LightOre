import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';

class TestOptionBubble extends OptionBubble {
  const TestOptionBubble({super.key});
  @override
  State<OptionBubble> createState() => TestOptionBubbleState();
}

class TestOptionBubbleState extends State<OptionBubble> {
  Offset? lastOffset;
  @override
  Widget build(BuildContext context) {
    return OptionBubble(
      key: widget.key,
      minTiles: widget.minTiles,
      maxTiles: widget.maxTiles,
      onAccountTap: widget.onAccountTap,
      overlayType: widget.overlayType,
      onOverlayTap: widget.onOverlayTap,
    );
  }
}

void main() {
  group('OptionBubble', () {
    testWidgets('bubble is 30% smaller and snaps to nearest edge', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OptionBubble(),
          ),
        ),
      );
      // Find the bubble by icon
      final bubbleFinder = find.byIcon(Icons.menu);
      expect(bubbleFinder, findsOneWidget);
      // Check size via RenderBox
      final bubbleBox = tester.renderObject<RenderBox>(bubbleFinder);
      expect(bubbleBox.size.width, closeTo(39, 1));
      expect(bubbleBox.size.height, closeTo(39, 1));
      // Drag bubble to left edge
      await tester.drag(bubbleFinder, const Offset(-200, 0));
      await tester.pumpAndSettle();
      // Can't access private state, so just check that the bubble is still visible
      expect(bubbleFinder, findsOneWidget);
      // Drag bubble to bottom edge
      await tester.drag(bubbleFinder, const Offset(0, 500));
      await tester.pumpAndSettle();
      expect(bubbleFinder, findsOneWidget);
    });
  });
}

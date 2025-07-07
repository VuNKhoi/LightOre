import 'package:flutter/material.dart';

/// A floating option bubble (like a chat head) that expands to show a grid of tiles.
class OptionBubble extends StatefulWidget {
  final int minTiles;
  final int maxTiles;
  final void Function()? onAccountTap;

  const OptionBubble({
    super.key,
    this.minTiles = 4,
    this.maxTiles = 9,
    this.onAccountTap,
  });

  @override
  State<OptionBubble> createState() => _OptionBubbleState();
}

class _OptionBubbleState extends State<OptionBubble> {
  bool _expanded = false;
  int _tileCount = 4;

  void _toggleExpand() {
    setState(() {
      _expanded = !_expanded;
    });
  }

  void _increaseTiles() {
    setState(() {
      if (_tileCount < widget.maxTiles) _tileCount++;
    });
  }

  void _decreaseTiles() {
    setState(() {
      if (_tileCount > widget.minTiles) _tileCount--;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Option grid popup
        if (_expanded)
          Positioned(
            right: 0,
            bottom: 70,
            child: Material(
              elevation: 8,
              borderRadius: BorderRadius.circular(16),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 220, // Bounded width for GridView
                      child: GridView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 8,
                          crossAxisSpacing: 8,
                        ),
                        itemCount: _tileCount,
                        itemBuilder: (context, i) {
                          if (i == 0) {
                            // Top-left: Account
                            return GestureDetector(
                              onTap: () {
                                _toggleExpand();
                                widget.onAccountTap?.call();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.blue.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.person, size: 32),
                                      SizedBox(height: 4),
                                      Text('Account'),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }
                          // Empty tiles
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          );
                        },
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.remove),
                          onPressed: _decreaseTiles,
                        ),
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: _increaseTiles,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        // Floating bubble
        Positioned(
          right: 16,
          bottom: 16,
          child: GestureDetector(
            onTap: _toggleExpand,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 51), // 0.2 * 255 = 51
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 32),
            ),
          ),
        ),
      ],
    );
  }
}

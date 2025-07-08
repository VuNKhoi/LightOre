import 'package:flutter/material.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';

/// A floating option bubble (like a chat head) that expands to show a grid of tiles.
class OptionBubble extends StatefulWidget {
  final int minTiles;
  final int maxTiles;
  final void Function()? onAccountTap;
  final MapOverlayType? overlayType;
  final VoidCallback? onOverlayTap;

  const OptionBubble({
    super.key,
    this.minTiles = 4,
    this.maxTiles = 9,
    this.onAccountTap,
    this.overlayType,
    this.onOverlayTap,
  });

  @override
  State<OptionBubble> createState() => _OptionBubbleState();
}

class _OptionBubbleState extends State<OptionBubble> {
  bool _expanded = false;
  int _tileCount = 4;
  Offset _bubbleOffset = const Offset(0, 0); // Offset from bottom-right
  Size? _screenSize;

  static const double _bubbleDiameter = 39; // 30% smaller than 56

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _screenSize ??= MediaQuery.of(context).size;
    // Default position: bottom right
    if (_bubbleOffset == Offset.zero && _screenSize != null) {
      setState(() {
        _bubbleOffset =
            Offset(_screenSize!.width - 88, _screenSize!.height - 168);
      });
    }
  }

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

  String _overlayLabel(MapOverlayType? type) {
    switch (type) {
      case MapOverlayType.ifrLow:
        return 'IFR Low';
      case MapOverlayType.ifrHigh:
        return 'IFR High';
      case MapOverlayType.sectional:
        return 'Sectional';
      case MapOverlayType.streetMap:
        return 'Street Map';
      default:
        return '';
    }
  }

  IconData _overlayIcon(MapOverlayType? type) {
    switch (type) {
      case MapOverlayType.ifrLow:
        return Icons.alt_route;
      case MapOverlayType.ifrHigh:
        return Icons.flight;
      case MapOverlayType.sectional:
        return Icons.map;
      case MapOverlayType.streetMap:
        return Icons.public;
      default:
        return Icons.map;
    }
  }

  @override
  Widget build(BuildContext context) {
    _screenSize = MediaQuery.of(context).size;
    return Stack(
      children: [
        // Option grid popup
        if (_expanded)
          Positioned(
            right: _screenSize!.width - _bubbleOffset.dx - 56,
            bottom: _screenSize!.height -
                _bubbleOffset.dy -
                56 -
                54, // 54: grid height offset
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
                            const SliverGridDelegateWithFixedCrossAxisCount(
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
                          } else if (i == 1 && widget.overlayType != null) {
                            // Overlay selector tile
                            return GestureDetector(
                              onTap: () {
                                _toggleExpand();
                                widget.onOverlayTap?.call();
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  color: Colors.green.shade100,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(_overlayIcon(widget.overlayType),
                                          size: 32),
                                      const SizedBox(height: 4),
                                      Text(_overlayLabel(widget.overlayType)),
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
        // Draggable floating bubble
        Positioned(
          left: _bubbleOffset.dx,
          top: _bubbleOffset.dy,
          child: GestureDetector(
            onPanUpdate: (details) {
              setState(() {
                final dx = (_bubbleOffset.dx + details.delta.dx)
                    .clamp(0.0, _screenSize!.width - _bubbleDiameter);
                final dy = (_bubbleOffset.dy + details.delta.dy)
                    .clamp(0.0, _screenSize!.height - _bubbleDiameter);
                _bubbleOffset = Offset(dx, dy);
              });
            },
            onPanEnd: (details) {
              // Snap to nearest edge
              final width = _screenSize!.width;
              final height = _screenSize!.height;
              final dx = _bubbleOffset.dx;
              final dy = _bubbleOffset.dy;
              final distances = {
                'left': dx,
                'right': width - dx - _bubbleDiameter,
                'top': dy,
                'bottom': height - dy - _bubbleDiameter,
              };
              final nearest = (distances.entries.toList()
                    ..sort((a, b) => a.value.compareTo(b.value)))[0]
                  .key;
              Offset newOffset;
              switch (nearest) {
                case 'left':
                  newOffset = Offset(0, dy);
                  break;
                case 'right':
                  newOffset = Offset(width - _bubbleDiameter, dy);
                  break;
                case 'top':
                  newOffset = Offset(dx, 0);
                  break;
                case 'bottom':
                  newOffset = Offset(dx, height - _bubbleDiameter);
                  break;
                default:
                  newOffset = _bubbleOffset;
              }
              setState(() {
                _bubbleOffset = newOffset;
              });
            },
            onTap: _toggleExpand,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _bubbleDiameter,
              height: _bubbleDiameter,
              decoration: BoxDecoration(
                color: Colors.blue,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha((0.2 * 255).toInt()),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.menu, color: Colors.white, size: 24),
            ),
          ),
        ),
      ],
    );
  }
}

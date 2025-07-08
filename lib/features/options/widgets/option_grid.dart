import 'package:flutter/material.dart';

class OptionGrid extends StatelessWidget {
  final VoidCallback? onAccountTap;
  final int optionCount;
  final List<OptionGridTileData>? tiles;
  const OptionGrid({
    super.key,
    this.onAccountTap,
    this.optionCount = 4,
    this.tiles,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    // Minimum 2x2 grid
    int minCrossAxis = 2;
    int minMainAxis = 2;
    int count = tiles?.length ?? optionCount;
    // Calculate grid dimensions
    int crossAxisCount = minCrossAxis;
    int mainAxisCount = minMainAxis;
    if (isLandscape) {
      // Expand horizontally first
      while (crossAxisCount * mainAxisCount < count) {
        crossAxisCount++;
      }
    } else {
      // Expand vertically first
      while (crossAxisCount * mainAxisCount < count) {
        mainAxisCount++;
      }
    }
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 80.0 * crossAxisCount + 32,
        height: 80.0 * mainAxisCount + 32,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
          ),
          itemCount: count,
          itemBuilder: (context, index) {
            if (index == 0) {
              return _OptionTile(
                icon: Icons.person,
                label: 'Account',
                onTap: () {
                  onAccountTap?.call();
                },
              );
            }
            final tile = tiles != null && index < tiles!.length
                ? tiles![index]
                : null;
            return _OptionTile(
              icon: tile?.icon ?? Icons.circle,
              label: tile?.label ?? 'Option',
              onTap: tile?.onTap ?? () {},
            );
          },
        ),
      ),
    );
  }
}

class OptionGridTileData {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  OptionGridTileData({required this.icon, required this.label, required this.onTap});
}

class _OptionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _OptionTile({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 32, color: Colors.blueAccent),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontSize: 12)),
        ],
      ),
    );
  }
}

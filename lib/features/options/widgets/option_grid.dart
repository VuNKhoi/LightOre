import 'package:flutter/material.dart';

class OptionGrid extends StatelessWidget {
  final VoidCallback? onAccountTap;
  const OptionGrid({Key? key, this.onAccountTap}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 8,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: 240,
        height: 240,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          children: List.generate(9, (index) {
            if (index == 0) {
              return _OptionTile(
                icon: Icons.person,
                label: 'Account',
                onTap: () {
                  onAccountTap?.call();
                },
              );
            }
            return _OptionTile(
              icon: Icons.circle,
              label: 'Option',
              onTap: () {},
            );
          }),
        ),
      ),
    );
  }
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

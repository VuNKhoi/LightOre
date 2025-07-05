import 'package:flutter/material.dart';
import 'package:lightore/constants.dart';

class InfoBanner extends StatelessWidget {
  final String? message;
  const InfoBanner({super.key, this.message});

  @override
  Widget build(BuildContext context) {
    if (message == null) return const SizedBox.shrink();
    return Column(
      children: [
        Text(message!, style: TextStyle(color: AppTheme.successColor)),
        const SizedBox(height: 16),
      ],
    );
  }
}

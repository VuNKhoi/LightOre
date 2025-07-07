import 'package:flutter/material.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';
import 'package:lightore/features/account/presentation/screens/account_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          const SafeArea(child: BaseMapView()),
          OptionBubble(
            onAccountTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

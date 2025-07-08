import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';
import 'package:lightore/features/account/presentation/screens/account_screen.dart';
import 'package:lightore/features/map/application/map_overlay_provider.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final TileProvider? tileProvider;
  const HomeScreen({super.key, this.tileProvider});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final BaseMapViewController _mapController = BaseMapViewController();

  void _showOverlaySelector() async {
    final overlays = MapOverlayType.values;
    final selected = await showDialog<MapOverlayType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Map Overlay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: overlays.map((type) => ListTile(
              leading: Icon(MapOverlayTypeViewModel.icon(type)),
              title: Text(MapOverlayTypeViewModel.label(type)),
              selected: ref.read(mapOverlayProvider) == type,
              onTap: () => Navigator.pop(context, type),
            )).toList(),
          ),
        );
      },
    );
    if (selected != null) {
      ref.read(mapOverlayProvider.notifier).state = selected;
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOverlay = ref.watch(mapOverlayProvider);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(child: BaseMapView(
            overlayType: selectedOverlay,
            controller: _mapController,
            tileProvider: widget.tileProvider,
          )),
          OptionBubble(
            overlayType: selectedOverlay,
            onOverlayTap: _showOverlaySelector,
            onAccountTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const AccountScreen(),
                ),
              );
            },
          ),
          // Show current location button at bottom right
          Positioned(
            right: 24,
            bottom: 24,
            child: FloatingActionButton(
              heroTag: 'current_location',
              onPressed: () async {
                await _mapController.centerOnUser();
              },
              child: const Icon(Icons.my_location),
            ),
          ),
        ],
      ),
    );
  }
}

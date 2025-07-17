import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/options/widgets/option_bubble.dart';
import 'package:lightore/features/account/presentation/screens/account_screen.dart';
import 'package:lightore/features/map/application/map_overlay_provider.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';
import 'package:lightore/features/map/domain/geolocator_service.dart';

class HomeScreen extends ConsumerStatefulWidget {
  final TileProvider? tileProvider;
  final IGeolocatorService? geolocatorService;
  const HomeScreen({super.key, this.tileProvider, this.geolocatorService});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  final BaseMapViewController _mapController = BaseMapViewController();
  late final IGeolocatorService _geo;

  @override
  void initState() {
    super.initState();
    _geo = widget.geolocatorService ?? GeolocatorService();
  }

  void _showOverlaySelector() async {
    final overlays = MapOverlayType.values;
    final selected = await showDialog<MapOverlayType>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Select Map Overlay'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: overlays
                .map((type) => ListTile(
                      leading: Icon(MapOverlayTypeViewModel.icon(type)),
                      title: Text(MapOverlayTypeViewModel.label(type)),
                      selected: ref.read(mapOverlayProvider) == type,
                      onTap: () => Navigator.pop(context, type),
                    ))
                .toList(),
          ),
        );
      },
    );
    if (selected != null) {
      await ref.read(mapOverlayProvider.notifier).setOverlay(selected);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedOverlay = ref.watch(mapOverlayProvider);
    return Scaffold(
      body: Stack(
        children: [
          SafeArea(
              child: BaseMapView(
            overlayType: selectedOverlay,
            controller: _mapController,
            tileProvider: widget.tileProvider,
            geolocatorService: widget.geolocatorService,
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
                final permission = await _geo.checkPermission();
                if (permission == LocationPermission.denied ||
                    permission == LocationPermission.deniedForever) {
                  final req = await _geo.requestPermission();
                  if (req != LocationPermission.always &&
                      req != LocationPermission.whileInUse) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                          content: Text(
                              'Location permission required to center on your position.')),
                    );
                    return;
                  }
                }
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

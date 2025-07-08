import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

import 'package:lightore/features/map/domain/map_overlay_type.dart'; // Import the enum from the domain

/// BaseMapView abstraction for all map logic and overlays
class BaseMapView extends StatefulWidget {
  final MapOverlayType overlayType;
  final bool showUserLocation;

  const BaseMapView({
    super.key,
    this.overlayType = MapOverlayType.sectional,
    this.showUserLocation = true,
  });

  @override
  State<BaseMapView> createState() => _BaseMapViewState();
}

class _BaseMapViewState extends State<BaseMapView> {
  LatLng? _currentPosition;
  bool _loadingLocation = false;

  @override
  void initState() {
    super.initState();
    if (widget.showUserLocation) {
      _fetchCurrentLocation();
    }
  }

  /// Fetches the user's current location and updates state.
  Future<void> _fetchCurrentLocation() async {
    setState(() => _loadingLocation = true);
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _loadingLocation = false;
      });
    } catch (_) {
      setState(() => _loadingLocation = false);
      // Handle location error (permissions, etc.)
    }
  }

  /// Returns the overlay tile URL template for the given overlay type.
  String _overlayUrlTemplate(MapOverlayType type) {
    switch (type) {
      case MapOverlayType.sectional:
        return 'https://your-tile-server/sectional/{z}/{x}/{y}.png';
      case MapOverlayType.ifrLow:
        return 'https://your-tile-server/ifr_low/{z}/{x}/{y}.png';
      case MapOverlayType.ifrHigh:
        return 'https://your-tile-server/ifr_high/{z}/{x}/{y}.png';
      case MapOverlayType.streetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  /// Builds the user location marker.
  Marker _buildUserMarker() {
    return Marker(
      point: _currentPosition!,
      width: 40,
      height: 40,
      child: const Icon(Icons.my_location, color: Colors.blue),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition ??
            const LatLng(39.8283, -98.5795), // Default: USA center
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.lightore',
        ),
        TileLayer(
          urlTemplate: _overlayUrlTemplate(widget.overlayType),
          userAgentPackageName: 'com.example.lightore',
          tileBuilder: (context, tileWidget, tile) {
            return Opacity(
              opacity: 0.7,
              child: tileWidget,
            );
          },
        ),
        if (widget.showUserLocation)
          if (_loadingLocation)
            MarkerLayer(
              markers: [
                Marker(
                  point: const LatLng(39.8283, -98.5795),
                  width: 40,
                  height: 40,
                  child: const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  ),
                ),
              ],
            )
          else if (_currentPosition != null)
            MarkerLayer(
              markers: [
                _buildUserMarker(),
              ],
            ),
      ],
    );
  }
}

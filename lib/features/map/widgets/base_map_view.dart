import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Enum for supported overlay types
enum MapOverlayType {
  sectional,
  ifrLow,
  ifrHigh,
}

/// BaseMapView abstraction for all map logic and overlays
class BaseMapView extends StatefulWidget {
  final MapOverlayType overlayType;
  final bool showUserLocation;
  final TileProvider? tileProvider; // <-- Add this line

  const BaseMapView({
    Key? key,
    this.overlayType = MapOverlayType.sectional,
    this.showUserLocation = true,
    this.tileProvider, // <-- Add this line
  }) : super(key: key);

  @override
  State<BaseMapView> createState() => _BaseMapViewState();
}

class _BaseMapViewState extends State<BaseMapView> {
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    if (widget.showUserLocation) {
      _getCurrentLocation();
    }
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (_) {
      // Handle location error (permissions, etc.)
    }
  }

  String _overlayUrlTemplate(MapOverlayType type) {
    switch (type) {
      case MapOverlayType.sectional:
        return 'https://your-tile-server/sectional/{z}/{x}/{y}.png';
      case MapOverlayType.ifrLow:
        return 'https://your-tile-server/ifr_low/{z}/{x}/{y}.png';
      case MapOverlayType.ifrHigh:
        return 'https://your-tile-server/ifr_high/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      options: MapOptions(
        initialCenter: _currentPosition ?? LatLng(39.8283, -98.5795), // Default: USA center
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.example.lightore',
        ),
        TileLayer(
          urlTemplate: _overlayUrlTemplate(widget.overlayType),
          tileBuilder: (context, tileWidget, tile) {
            return Opacity(
              opacity: 0.7,
              child: tileWidget,
            );
          },
          tileProvider: widget.tileProvider, // <-- Add this line
        ),
        if (widget.showUserLocation && _currentPosition != null)
          MarkerLayer(
            markers: [
              Marker(
                point: _currentPosition!,
                width: 40,
                height: 40,
                child: const Icon(Icons.my_location, color: Colors.blue),
              ),
            ],
          ),
      ],
    );
  }
}

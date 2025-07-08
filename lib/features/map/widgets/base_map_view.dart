import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

/// Enum for supported overlay types
enum MapOverlayType {
  streetMap, // New default
  sectional,
  ifrLow,
  ifrHigh,
}

/// BaseMapView abstraction for all map logic and overlays
class BaseMapViewController {
  _BaseMapViewState? _state;
  void _attach(_BaseMapViewState state) => _state = state;
  void _detach() => _state = null;
  Future<void> centerOnUser() async => _state?._centerOnUser();
}

class BaseMapView extends StatefulWidget {
  final MapOverlayType overlayType;
  final bool showUserLocation;
  final TileProvider? tileProvider;
  final BaseMapViewController? controller;

  const BaseMapView({
    super.key,
    this.overlayType = MapOverlayType.streetMap,
    this.showUserLocation = true,
    this.tileProvider,
    this.controller,
  });

  @override
  State<BaseMapView> createState() => _BaseMapViewState();
}

class _BaseMapViewState extends State<BaseMapView> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    widget.controller?._attach(this);
    if (widget.showUserLocation) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    widget.controller?._detach();
    super.dispose();
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

  Future<void> _centerOnUser() async {
    if (_currentPosition == null) {
      await _getCurrentLocation();
    }
    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, 15);
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
      case MapOverlayType.streetMap:
        return 'https://tile.openstreetmap.org/{z}/{x}/{y}.png';
    }
  }

  @override
  Widget build(BuildContext context) {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition ??
            LatLng(39.8283, -98.5795), // Default: USA center
        initialZoom: 6,
      ),
      children: [
        TileLayer(
          urlTemplate: _overlayUrlTemplate(widget.overlayType),
          userAgentPackageName: 'com.example.lightore',
        ),
        if (widget.overlayType != MapOverlayType.streetMap)
          TileLayer(
            urlTemplate: _overlayUrlTemplate(widget.overlayType),
            tileBuilder: (context, tileWidget, tile) {
              return Opacity(
                opacity: 0.7,
                child: tileWidget,
              );
            },
            tileProvider: widget.tileProvider,
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

// UI mapping for MapOverlayType (decoupling enum from UI)
class MapOverlayTypeViewModel {
  static String label(MapOverlayType type) {
    switch (type) {
      case MapOverlayType.streetMap:
        return 'Street Map';
      case MapOverlayType.sectional:
        return 'Sectional';
      case MapOverlayType.ifrLow:
        return 'IFR Low';
      case MapOverlayType.ifrHigh:
        return 'IFR High';
    }
  }

  static IconData icon(MapOverlayType type) {
    switch (type) {
      case MapOverlayType.streetMap:
        return Icons.map;
      case MapOverlayType.sectional:
        return Icons.map;
      case MapOverlayType.ifrLow:
        return Icons.alt_route;
      case MapOverlayType.ifrHigh:
        return Icons.flight;
    }
  }
}

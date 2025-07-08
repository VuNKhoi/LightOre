import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';
import 'package:lightore/features/map/domain/geolocator_service.dart';

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
  final IGeolocatorService? geolocatorService;

  const BaseMapView({
    super.key,
    this.overlayType = MapOverlayType.streetMap,
    this.showUserLocation = true,
    this.tileProvider,
    this.controller,
    this.geolocatorService,
  });

  @override
  State<BaseMapView> createState() => _BaseMapViewState();
}

class _BaseMapViewState extends State<BaseMapView> {
  LatLng? _currentPosition;
  final MapController _mapController = MapController();
  late final IGeolocatorService _geo;

  @override
  void initState() {
    super.initState();
    _geo = widget.geolocatorService ?? GeolocatorService();
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
    LocationPermission permission = await _geo.checkPermission();
    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      permission = await _geo.requestPermission();
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        // Permission denied, do not proceed
        return;
      }
    }
    try {
      final position = await _geo.getCurrentPosition();
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
          tileProvider:
              widget.tileProvider, // <-- use injected provider for all layers
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

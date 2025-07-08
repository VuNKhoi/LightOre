import 'package:flutter/material.dart';

/// Enum for supported overlay types (SRP: domain only)
enum MapOverlayType {
  streetMap,
  sectional,
  ifrLow,
  ifrHigh,
}

/// UI mapping for MapOverlayType (SRP: presentation only)
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

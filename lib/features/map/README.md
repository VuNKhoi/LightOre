# Base Map View

The BaseMapView widget displays the main map and supports sectional, IFR low, and IFR high overlays. It can be extended to support more overlays (airspace, NOTAMs, etc.).

**Key Features:**
- Map display with overlay support
- Shows user's current GPS position
- Extensible for more overlays

**Usage:**
```dart
BaseMapView(overlayType: MapOverlayType.sectional)
```

**Location:**
`lib/features/map/widgets/base_map_view.dart`

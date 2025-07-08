# Base Map View

The BaseMapView widget displays the main map and supports sectional, IFR low, IFR high, and street map overlays. It can be extended to support more overlays (airspace, NOTAMs, etc.).

**Key Features:**
- Map display with overlay support
- Shows user's current GPS position
- Extensible for more overlays
- **SOLID:**
  - `MapOverlayType` enum and `MapOverlayTypeViewModel` are in `domain/`.
  - All business logic is in providers/services, not UI.
  - Map widget is UI-only and receives overlay type as a parameter.
  - Overlay selection is persisted and managed via provider and shared_preferences.

**Usage:**
```dart
BaseMapView(overlayType: MapOverlayType.sectional)
```

**Location:**
`lib/features/map/widgets/base_map_view.dart`

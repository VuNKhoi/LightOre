# LightOre: ForeFlight-Style Flutter Aviation App

## Overview
LightOre is a modular, testable Flutter application inspired by Boeing ForeFlight, designed for pilots and aviation enthusiasts. The app is built with a clean architecture, robust authentication (including Google Sign-In and Firebase), and a future-proof mapping strategy that starts with flutter_map and migrates to MapLibre for full control and open-source flexibility.

## Architecture & Philosophy
- **Feature-based folder structure**: Code is organized by feature (e.g., `features/auth/`, `features/home/`), with shared widgets and utilities in dedicated folders.
- **Separation of concerns**: UI, business logic, and data access are separated using Riverpod providers, repositories, and notifiers.
- **Reusable widgets**: Common UI elements (fields, banners, buttons) are extracted for maintainability and testability.
- **Centralized constants and theming**: All keys, labels, error messages, routes, and styles are defined in `constants.dart` and `theme.dart` for consistency and easy updates.
- **Comprehensive testing**: Widget and integration tests cover all critical flows, including authentication and error handling.
- **Map abstraction**: All map-related code is wrapped in a single widget/service layer (e.g., `BaseMapView`) to enable seamless migration from flutter_map to MapLibre.
- **UI Compactness Principle**: All option menus, popups, and overlays are designed to be as compact and unobtrusive as possible, ensuring maximum map visibility and a focused user experience at all times.

## Authentication
- **Email/password and Google Sign-In** using Firebase Auth.
- **Error handling**: All errors are mapped to user-friendly messages and displayed via reusable banners.
- **Test coverage**: All widgets and flows are covered by unit and widget tests.

## Mapping Strategy
### Phase 1: flutter_map Integration (MVP)
- Use the [flutter_map](https://pub.dev/packages/flutter_map) package for rapid MVP development.
- FAA sectional charts are processed into XYZ raster tiles and displayed as a TileLayer overlay above the base map.
- User's current GPS position is shown as a marker on the map.
- User position tracking, panning, zoom, markers, and overlays are supported out of the box.
- All map logic is abstracted behind a `BaseMapView` interface for future migration.

### Phase 2: Migration to MapLibre
- Replace flutter_map with a custom/community MapLibre wrapper for advanced features and open-source flexibility.
- Migrate map code to use platform channels or the abstraction layer.
- Host FAA charts and styles yourself (Cloudflare R2, S3, or self-hosted).
- Implement offline tile caching and advanced overlays as needed.
- No vendor lock-in, fully open-source, and cost-effective for scale.

## Long-Term Architecture
- **Abstraction**: All map and FAA chart logic is decoupled from the rendering engine.
- **Interoperability**: Tiles and styles are stored in open formats (XYZ raster, Style JSON v8).
- **Dependency injection**: Map engine selection is configurable for easy migration.
- **Offline-first**: The architecture anticipates offline support from the start.

## Aviation Overlays & Airspace Data

LightOre is designed to support advanced aviation features such as FAA chart overlays and airspace boundaries. These features are enabled by integrating open and authoritative data sources:

- **Airspace Boundaries:**
  - Sourced from [OpenAIP](https://www.openaip.net/) (global, GeoJSON), FAA (US, Shapefile/GeoJSON), Eurocontrol (Europe, AIXM/GeoJSON), and other open-data projects.
  - Data includes lines and polygons for all major airspace classes, restricted areas, and more.
  - Data is regularly updated and can be automated via APIs or scheduled downloads.
- **FAA Sectional/IFR Overlays:**
  - FAA raster charts are processed into XYZ tiles and overlaid as raster TileLayers in flutter_map.
- **Terrain Visualization:**
  - (Optional, not planned for MVP) MapLibre supports 3D terrain using DEM tiles; flutter_map supports raster hillshading and custom layers.

### Compatibility
- All airspace and overlay data (GeoJSON, KML, Shapefile) can be rendered as vector or raster overlays in both **flutter_map** and **MapLibre**.
- The app's map abstraction ensures seamless integration and future migration between mapping engines.
- Styling, interactivity, and offline support are supported in both approaches.

## Project Structure
```
lib/
  constants.dart
  app.dart
  main.dart
  features/
    auth/
      application/
      presentation/
      repositories/
    home/
    ...
  widgets/
  services/
  utils/
  ...
test/
integration_test/
```

## Testing
- **Widget and unit tests**: All reusable widgets and flows are tested.
- **Integration tests**: Google Sign-In and navigation flows are covered.
- **Test helpers**: Common test setup and mocks are provided in `test_helpers.dart`.

## Future Plans
- Complete flutter_map MVP and user testing.
- Build out the `BaseMapView` abstraction for all map logic (start early to support multiple map/overlay types).
- Prepare FAA chart tiling and hosting pipeline (XYZ raster tiles for sectional, IFR low, and IFR high overlays).
- Migrate to MapLibre for open-source, offline, and scalable deployment.
- Integrate advanced aviation overlays (airspace, NOTAMs, etc.) and ensure compatibility with both flutter_map and MapLibre.

## Contributing
- Follow the feature-based folder structure and keep business logic out of UI widgets.
- Add tests for all new widgets and flows.
- Use constants and theming for all UI elements.
- Document all public classes and methods.

---

## Architectural Principles: Decoupling & Maintainability

- **Routing and Auth Decoupling**: Routing logic should not directly depend on authentication providers. Use navigation guards, services, or event-based patterns to handle redirects and access control.
- **Screen Construction**: Route definitions should use factories or builders for screen creation, not direct instantiation. This enables dependency injection and easier refactoring.
- **Provider Abstraction**: UI widgets should depend on interfaces or abstract providers, not concrete implementations. Pass providers as parameters for easier testing and mocking.
- **Enum/UI Decoupling**: UI code should not directly reference enums for display. Use view models or mapping layers to translate enum values to user-facing strings and icons.
- **Test-Driven**: All new features and bug fixes should include appropriate widget and logic tests. Fix all failed tests unless the subject is deprecated, hard to test, or integration-only.

_These principles ensure LightOre remains modular, testable, and easy to maintain as it grows._

## Questions for the Team
1. **Map Abstraction**: Should the `BaseMapView` abstraction be a widget, a service, or both? (Current plan: widget with injectable engine)
2. **FAA Chart Hosting**: Is there a preferred cloud provider for tile hosting (Cloudflare, S3, or self-hosted)?
3. **Offline Support**: Should we prioritize full offline support in the MVP, or defer until after MapLibre migration?
4. **Testing**: Are there any additional flows or edge cases that should be prioritized for automated testing?
5. **Open-Source Goals**: Are there any licensing or compliance requirements we should consider for MapLibre and FAA data?

---

For more details, see the project plan in this README or contact the maintainers.
# LightOre: ForeFlight-Style Flutter Aviation App

## Overview
LightOre is a modular, testable Flutter application inspired by Boeing ForeFlight, designed for pilots and aviation enthusiasts. The app is built with a clean architecture, robust authentication (including Google Sign-In and Firebase), and a future-proof mapping strategy that starts with Mapbox and migrates to MapLibre for full control and open-source flexibility.

## Architecture & Philosophy
- **Feature-based folder structure**: Code is organized by feature (e.g., `features/auth/`, `features/home/`), with shared widgets and utilities in dedicated folders.
- **Separation of concerns**: UI, business logic, and data access are separated using Riverpod providers, repositories, and notifiers.
- **Reusable widgets**: Common UI elements (fields, banners, buttons) are extracted for maintainability and testability.
- **Centralized constants and theming**: All keys, labels, error messages, routes, and styles are defined in `constants.dart` and `theme.dart` for consistency and easy updates.
- **Comprehensive testing**: Widget and integration tests cover all critical flows, including authentication and error handling.
- **Map abstraction**: All map-related code is wrapped in a single widget/service layer (e.g., `BaseMapView`) to enable seamless migration from Mapbox to MapLibre.

## Authentication
- **Email/password and Google Sign-In** using Firebase Auth.
- **Error handling**: All errors are mapped to user-friendly messages and displayed via reusable banners.
- **Test coverage**: All widgets and flows are covered by unit and widget tests.

## Mapping Strategy
### Phase 1: Mapbox Integration
- Use Mapbox’s Flutter SDK for rapid MVP development.
- FAA sectional charts uploaded as raster tilesets and overlaid using the SDK.
- User position tracking, panning, zoom, markers, and overlays supported out of the box.
- All map logic is abstracted behind a `BaseMapView` interface.

### Phase 2: Migration to MapLibre
- Replace Mapbox SDK with a custom/community MapLibre wrapper.
- Migrate map code to use platform channels or the abstraction layer.
- Host FAA charts and styles yourself (Cloudflare R2, S3, or self-hosted).
- Implement offline tile caching and advanced overlays as needed.
- No vendor lock-in, fully open-source, and cost-effective for scale.

## Long-Term Architecture
- **Abstraction**: All map and FAA chart logic is decoupled from the rendering engine.
- **Interoperability**: Tiles and styles are stored in open formats (XYZ raster, Style JSON v8).
- **Dependency injection**: Map engine selection is configurable for easy migration.
- **Offline-first**: The architecture anticipates offline support from the start.

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
- Complete Mapbox MVP and user testing.
- Build out the `BaseMapView` abstraction.
- Prepare FAA chart tiling and hosting pipeline.
- Migrate to MapLibre for open-source, offline, and scalable deployment.

## Contributing
- Follow the feature-based folder structure and keep business logic out of UI widgets.
- Add tests for all new widgets and flows.
- Use constants and theming for all UI elements.
- Document all public classes and methods.

---

## Questions for the Team
1. **Map Abstraction**: Should the `BaseMapView` abstraction be a widget, a service, or both? (Current plan: widget with injectable engine)
2. **FAA Chart Hosting**: Is there a preferred cloud provider for tile hosting (Cloudflare, S3, or self-hosted)?
3. **Offline Support**: Should we prioritize full offline support in the MVP, or defer until after MapLibre migration?
4. **Testing**: Are there any additional flows or edge cases that should be prioritized for automated testing?
5. **Open-Source Goals**: Are there any licensing or compliance requirements we should consider for MapLibre and FAA data?

---

For more details, see the project plan in this README or contact the maintainers.
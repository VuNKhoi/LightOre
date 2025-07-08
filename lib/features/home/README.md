# Home Feature

This feature contains the main home screen and navigation logic for the LightOre app.

## Key Responsibilities
- Hosts the main map view and floating OptionBubble.
- Manages overlay selection and user navigation.
- Integrates with authentication and account features.
- **SOLID:**
  - All widgets are UI-only and receive data via providers.
  - Overlay selection is managed by a provider and persisted.
  - Navigation logic is decoupled from UI and authentication logic.
  - No business logic in UI files.

## Main Widgets
- `HomeScreen`: The main entry point for authenticated users.
- `OptionBubble`: Floating button for quick actions and overlay selection.
- `BaseMapView`: Displays the map and overlays.

## Location
`lib/features/home/`

# Auth Feature

This feature handles authentication logic and UI for the LightOre app.

## Key Responsibilities
- User login, registration, and logout flows.
- State management for authentication status.
- Integration with account and navigation features.
- **SOLID:**
  - `AuthStatus` enum is in `domain/`.
  - All business logic is in notifiers and providers, not UI.
  - `AuthRepository` implements `IAuthRepository` interface for testability.
  - Providers and notifiers depend on abstractions, not concrete classes.

## Main Components
- `auth_provider.dart`: Riverpod provider for authentication state (uses interface).
- `auth_state.dart`: Authentication state model.
- `domain/auth_status.dart`: Enum for authentication status.
- `domain/repositories/auth_repository_interface.dart`: Repository interface.
- `repositories/auth_repository.dart`: Implementation of repository.
- `screens/`: Contains login and registration screens.

## Location
`lib/features/auth/`

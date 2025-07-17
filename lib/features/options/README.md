# Options Feature

This feature provides the floating Option Bubble and the Option Grid popup for quick access to app actions.

**Widgets:**
- `OptionBubble`: Floating button that expands to show the grid.
- `OptionGrid`: Popup grid of quick actions.

**SOLID:**
- All widgets are UI-only and receive actions/data via parameters or providers.
- No business logic or state in UI files.
- Option selection and actions are decoupled from UI.

**Usage:**
```dart
import 'package:lightore/features/options/widgets/option_bubble.dart';
import 'package:lightore/features/options/widgets/option_grid.dart';
```

**Location:**
`lib/features/options/widgets/`

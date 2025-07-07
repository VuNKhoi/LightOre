# Deprecated: Option Bubble Feature

This feature has been merged into the new `options` feature. Please use `lib/features/options/` for all option-related widgets and logic.

This file is retained for historical reference only and will be removed in a future cleanup.

# Option Bubble

The Option Bubble is a floating action button that expands to show a grid of quick actions (the Option Grid). It is modular and triggers the account screen and other features.

**Key Features:**
- Floating button UI
- Expands to show Option Grid
- Handles tap events for quick actions

**Usage:**
```dart
OptionBubble(onAccountTap: () { ... })
```

**Location:**
`lib/features/option_bubble/widgets/option_bubble.dart`

This folder contains the floating chat-head style button and logic for showing the OptionGrid popup.

- Use `OptionBubble` for the floating button and grid trigger.
- Use `OptionGrid` (in `option_grid/widgets/option_grid.dart`) for the popup grid UI.

All code for the option bubble should live in this folder. Do not use or reference `options/widgets/option_bubble.dart`.

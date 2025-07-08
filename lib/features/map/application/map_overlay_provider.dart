import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';

/// Holds the currently selected map overlay type for the app.
final mapOverlayProvider = StateProvider<MapOverlayType>((ref) => MapOverlayType.sectional);

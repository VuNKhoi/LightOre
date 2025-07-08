import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _overlayPrefKey = 'selected_map_overlay';

class MapOverlayNotifier extends StateNotifier<MapOverlayType> {
  MapOverlayNotifier() : super(MapOverlayType.streetMap) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final index = prefs.getInt(_overlayPrefKey);
    if (index != null && index >= 0 && index < MapOverlayType.values.length) {
      state = MapOverlayType.values[index];
    }
  }

  Future<void> setOverlay(MapOverlayType type) async {
    state = type;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_overlayPrefKey, type.index);
  }
}

final mapOverlayProvider =
    StateNotifierProvider<MapOverlayNotifier, MapOverlayType>(
  (ref) => MapOverlayNotifier(),
);

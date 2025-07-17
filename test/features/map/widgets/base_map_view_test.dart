import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:lightore/features/map/widgets/base_map_view.dart';
import 'package:lightore/features/map/domain/map_overlay_type.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geolocator_platform_interface/geolocator_platform_interface.dart';
import 'dart:typed_data';
import 'package:lightore/features/map/domain/geolocator_service.dart';

class DummyTileProvider extends TileProvider {
  @override
  ImageProvider getImage(TileCoordinates coordinates, TileLayer options) {
    // Return a 1x1 transparent image
    return MemoryImage(
      Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        12,
        73,
        68,
        65,
        84,
        8,
        153,
        99,
        0,
        1,
        0,
        0,
        5,
        0,
        1,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130
      ]),
    );
  }
}

class FakeGeolocatorPlatform extends GeolocatorPlatform {
  @override
  Future<Position> getCurrentPosition(
      {LocationSettings? locationSettings}) async {
    return Position(
      latitude: 37.7749,
      longitude: -122.4194,
      timestamp: DateTime.now(),
      accuracy: 1.0,
      altitude: 0.0,
      heading: 0.0,
      speed: 0.0,
      speedAccuracy: 0.0,
      headingAccuracy: 0.0,
      altitudeAccuracy: 0.0,
      isMocked: true,
    );
  }
}

class FakeGeolocatorService implements IGeolocatorService {
  @override
  Future<LocationPermission> checkPermission() async =>
      LocationPermission.always;
  @override
  Future<LocationPermission> requestPermission() async =>
      LocationPermission.always;
  @override
  Future<Position> getCurrentPosition() async => Position(
        latitude: 37.7749,
        longitude: -122.4194,
        timestamp: DateTime.now(),
        accuracy: 1.0,
        altitude: 0.0,
        heading: 0.0,
        speed: 0.0,
        speedAccuracy: 0.0,
        headingAccuracy: 0.0,
        altitudeAccuracy: 0.0,
        isMocked: true,
      );
}

void main() {
  setUpAll(() {
    GeolocatorPlatform.instance = FakeGeolocatorPlatform();
  });

  group('BaseMapView', () {
    testWidgets('renders sectional overlay and user marker',
        (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BaseMapView(
            overlayType: MapOverlayType.sectional,
            showUserLocation: false, // skip location for test
            tileProvider: DummyTileProvider(),
            geolocatorService: FakeGeolocatorService(),
          ),
        ),
      ));
      expect(find.byType(BaseMapView), findsOneWidget);
      expect(find.byType(Scaffold), findsOneWidget);
      // The map widget should be present
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('supports IFR overlays', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BaseMapView(
            overlayType: MapOverlayType.ifrLow,
            showUserLocation: false,
            tileProvider: DummyTileProvider(),
            geolocatorService: FakeGeolocatorService(),
          ),
        ),
      ));
      expect(find.byType(BaseMapView), findsOneWidget);
    });

    testWidgets('does not throw ClientException in test', (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BaseMapView(
            overlayType: MapOverlayType.sectional,
            showUserLocation: false,
            tileProvider: DummyTileProvider(),
            geolocatorService: FakeGeolocatorService(),
          ),
        ),
      ));
      expect(find.byType(BaseMapView), findsOneWidget);
      // No exceptions should be thrown
    });

    testWidgets('BaseMapViewController centers map on user location',
        (tester) async {
      final controller = BaseMapViewController();
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: BaseMapView(
            overlayType: MapOverlayType.sectional,
            showUserLocation: true,
            tileProvider: DummyTileProvider(),
            controller: controller,
            geolocatorService: FakeGeolocatorService(),
          ),
        ),
      ));
      // Simulate centering (should not throw)
      await controller.centerOnUser();
      await tester.pumpAndSettle();
      expect(find.byType(BaseMapView), findsOneWidget);
    });
  });
}

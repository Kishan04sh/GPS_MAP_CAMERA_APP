import 'dart:ui' as ui;
import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../model/map_state.dart';
import '../repository/map_repository.dart';

final mapControllerProvider =
StateNotifierProvider<MapController, MapState>((ref) {
  return MapController(MapRepository());
});

class MapController extends StateNotifier<MapState> {
  final MapRepository repository;

  MapController(this.repository) : super(MapState.initial());

  Future<void> loadCurrentLocation() async {
    try {
      state = state.copyWith(status: MapStatus.loading);

      final pos = await repository.getCurrentLocation();

      state = state.copyWith(
        status: MapStatus.ready,
        currentLocation: LatLng(pos.latitude, pos.longitude),
      );
    } catch (e) {
      state = state.copyWith(
        status: MapStatus.error,
        error: e.toString(),
      );
    }
  }

  void refreshLocation() {
    loadCurrentLocation();
  }

  void toggleMapType() {
    state = state.copyWith(
      mapType: state.mapType == MapTypeMode.normal
          ? MapTypeMode.satellite
          : MapTypeMode.normal,
    );
  }

  Future<void> addPhotoMarker(String imagePath) async {
    if (state.currentLocation == null) return;

    final marker = PhotoMarker(
      position: state.currentLocation!,
      imagePath: imagePath,
    );

    state = state.copyWith(
      photoMarkers: [...state.photoMarkers, marker],
    );
  }

  Future<BitmapDescriptor> createCircularMarker(String path) async {
    final bytes = await File(path).readAsBytes();
    final codec = await ui.instantiateImageCodec(
      bytes,
      targetWidth: 150,
    );
    final frame = await codec.getNextFrame();
    final image = frame.image;

    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    final paint = ui.Paint();

    const size = 150.0;
    const rect = ui.Rect.fromLTWH(0, 0, size, size);

    canvas.clipPath(
      ui.Path()..addOval(rect),
    );
    canvas.drawImage(image, ui.Offset.zero, paint);

    final pic = recorder.endRecording();
    final img = await pic.toImage(150, 150);
    final pngBytes =
    await img.toByteData(format: ui.ImageByteFormat.png);

    return BitmapDescriptor.fromBytes(pngBytes!.buffer.asUint8List());
  }
}

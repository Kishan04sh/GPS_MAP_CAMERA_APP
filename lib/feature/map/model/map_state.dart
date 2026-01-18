import 'package:google_maps_flutter/google_maps_flutter.dart';

enum MapStatus { initial, loading, ready, error }
enum MapTypeMode { normal, satellite }

class PhotoMarker {
  final LatLng position;
  final String imagePath;

  PhotoMarker({
    required this.position,
    required this.imagePath,
  });
}

class MapState {
  final MapStatus status;
  final LatLng? currentLocation;
  final String? error;
  final MapTypeMode mapType;
  final List<PhotoMarker> photoMarkers;

  const MapState({
    required this.status,
    this.currentLocation,
    this.error,
    this.mapType = MapTypeMode.normal,
    this.photoMarkers = const [],
  });

  factory MapState.initial() =>
      const MapState(status: MapStatus.initial);

  MapState copyWith({
    MapStatus? status,
    LatLng? currentLocation,
    String? error,
    MapTypeMode? mapType,
    List<PhotoMarker>? photoMarkers,
  }) {
    return MapState(
      status: status ?? this.status,
      currentLocation: currentLocation ?? this.currentLocation,
      error: error,
      mapType: mapType ?? this.mapType,
      photoMarkers: photoMarkers ?? this.photoMarkers,
    );
  }
}

//
//
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
//
// final locationProvider = StateNotifierProvider<LocationNotifier, Position?>(
//       (ref) => LocationNotifier(),
// );
//
// class LocationNotifier extends StateNotifier<Position?> {
//   StreamSubscription<Position>? _sub;
//
//   LocationNotifier(): super(null) {
//     _init();
//   }
//
//   Future<void> _init() async {
//     bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
//     if (!serviceEnabled) {
//       // optional: request user to enable service
//       return;
//     }
//
//     LocationPermission perm = await Geolocator.checkPermission();
//     if (perm == LocationPermission.denied) {
//       perm = await Geolocator.requestPermission();
//       if (perm == LocationPermission.denied) return;
//     }
//     if (perm == LocationPermission.deniedForever) return;
//
//     try {
//       state = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.best);
//     } catch (_) {}
//     _sub = Geolocator.getPositionStream(locationSettings: const LocationSettings(accuracy: LocationAccuracy.best, distanceFilter: 5))
//         .listen((p) => state = p);
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     super.dispose();
//   }
// }


import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationProvider =
StateNotifierProvider<LocationNotifier, Position?>((ref) => LocationNotifier());

class LocationNotifier extends StateNotifier<Position?> {
  StreamSubscription<Position>? _sub;

  LocationNotifier() : super(null);

  Future<void> initLocation() async {
    bool enabled = await Geolocator.isLocationServiceEnabled();
    if (!enabled) {
      await Geolocator.openLocationSettings();
      return;
    }

    LocationPermission perm = await Geolocator.checkPermission();
    if (perm == LocationPermission.denied) {
      perm = await Geolocator.requestPermission();
      if (perm == LocationPermission.denied) return;
    }
    if (perm == LocationPermission.deniedForever) return;

    // Get first position
    try {
      state = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
    } catch (_) {}

    // Stream position updates
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    ).listen((pos) => state = pos);
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

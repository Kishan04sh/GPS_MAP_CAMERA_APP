import 'dart:async';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';

final locationProvider = StateNotifierProvider<LocationNotifier, Position?>(
      (ref) => LocationNotifier(),
);

class LocationNotifier extends StateNotifier<Position?> {
  LocationNotifier() : super(null);

  StreamSubscription<Position>? _sub;

  Future<void> initLocation() async {
    debugPrint('[LOCATION] Checking services…');

    if (!await Geolocator.isLocationServiceEnabled()) {
      debugPrint('[LOCATION] Service disabled');
      return;
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      debugPrint('[LOCATION] Permission denied');
      return;
    }

    debugPrint('[LOCATION] Fetching initial position…');
    state = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    debugPrint('[LOCATION] Starting position stream');
    _sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      ),
    ).listen((pos) {
      state = pos;
    });
  }

  @override
  void dispose() {
    debugPrint('[LOCATION] Disposing stream');
    _sub?.cancel();
    super.dispose();
  }
}

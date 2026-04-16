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
  
  /// *******************initLocation ******************************************

  Future<void> initLocation() async {
    try {
      debugPrint('[LOCATION] Checking services…');
      if (!await Geolocator.isLocationServiceEnabled()) return;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) return;

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
        try {
          if (_sub == null) return; // ✅ disposed
          state = pos;
        } catch (e) {
          debugPrint('[LOCATION][STREAM UPDATE ERROR] $e');
        }
      });
    } catch (e) {
      debugPrint('[LOCATION][INIT ERROR] $e');
    }
  }


/// *******************ADD BY CAPTURE ******************************************

  Future<bool> waitFirstAccurateFix({int timeout = 10}) async {
    final completer = Completer<bool>();

    late StreamSubscription sub;

    sub = Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.bestForNavigation,
        distanceFilter: 0,
      ),
    ).listen((pos) {
      if (pos.accuracy <= 25) {
        completer.complete(true);
        sub.cancel();
      }
    });

    Future.delayed(Duration(seconds: timeout), () {
      if (!completer.isCompleted) {
        completer.complete(false);
        sub.cancel();
      }
    });

    return completer.future;
  }


  ///*************************************************************************************


  @override
  void dispose() {
    debugPrint('[LOCATION] Disposing stream');
    _sub?.cancel();
    super.dispose();
  }
}

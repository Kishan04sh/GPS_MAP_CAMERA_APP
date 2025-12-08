import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'location_controller.dart';

final addressProvider = StateNotifierProvider<AddressNotifier, String?>((ref) => AddressNotifier(ref));

class AddressNotifier extends StateNotifier<String?> {
  final Ref ref;
  StreamSubscription<Position?>? _posSub;

  AddressNotifier(this.ref) : super(null) {
    _posSub = ref.read(locationProvider.notifier).stream.listen((pos) {
      _reverseGeocode(pos);
    });
  }

  Future<void> _reverseGeocode(Position? pos) async {
    if (pos == null) {
      state = null;
      return;
    }
    try {
      final placemarks = await placemarkFromCoordinates(pos.latitude, pos.longitude);
      if (placemarks.isNotEmpty) {
        final p = placemarks.first;
        final parts = <String>[];
        if ((p.name ?? '').isNotEmpty) parts.add(p.name!);
        if ((p.street ?? '').isNotEmpty) parts.add(p.street!);
        if ((p.locality ?? '').isNotEmpty) parts.add(p.locality!);
        if ((p.administrativeArea ?? '').isNotEmpty) parts.add(p.administrativeArea!);
        if ((p.postalCode ?? '').isNotEmpty) parts.add(p.postalCode!);
        if ((p.country ?? '').isNotEmpty) parts.add(p.country!);
        state = parts.join(', ');
      } else {
        state = 'Address not found';
      }
    } catch (e) {
      state = 'Failed to fetch address';
    }
  }

  @override
  void dispose() {
    _posSub?.cancel();
    super.dispose();
  }
}

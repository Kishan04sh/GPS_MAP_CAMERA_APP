
import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'location_controller.dart';

final addressProvider =
StateNotifierProvider<AddressNotifier, String?>(
      (ref) => AddressNotifier(ref),
);

class AddressNotifier extends StateNotifier<String?> {
  AddressNotifier(this.ref) : super(null) {
    _startListening();
  }

  final Ref ref;
  Timer? _debounce;
  StreamSubscription<Position?>? _sub;

  void _startListening() {
    debugPrint('[ADDRESS] Listening to location updates');

    _sub = ref
        .read(locationProvider.notifier)
        .stream
        .listen((pos) {
      if (pos == null) return;

      _debounce?.cancel();
      _debounce = Timer(const Duration(seconds: 2), () {
        _reverseGeocode(pos);
      });
    });
  }

  Future<void> _reverseGeocode(Position pos) async {
    debugPrint(
      '[ADDRESS] Reverse geocoding '
          '(${pos.latitude}, ${pos.longitude})',
    );

    try {
      final placemarks = await placemarkFromCoordinates(
        pos.latitude,
        pos.longitude,
      );

      if (placemarks.isEmpty) {
        state = 'Address not found';
        return;
      }

      final p = placemarks.first;

      // BUILD FULL ADDRESS SAFELY
      final parts = <String>[
        if (p.name?.isNotEmpty == true) p.name!,
        if (p.subLocality?.isNotEmpty == true) p.subLocality!,
        if (p.locality?.isNotEmpty == true) p.locality!,
        if (p.subAdministrativeArea?.isNotEmpty == true)
          p.subAdministrativeArea!,
        if (p.administrativeArea?.isNotEmpty == true)
          p.administrativeArea!,
        if (p.postalCode?.isNotEmpty == true) p.postalCode!,
        if (p.country?.isNotEmpty == true) p.country!,
      ];


      state = parts.join(', ');

      debugPrint('[ADDRESS] Updated → $state');
    } catch (e) {
      debugPrint('[ADDRESS][ERROR] Reverse geocode failed: $e');
    }
  }

  @override
  void dispose() {
    debugPrint('[ADDRESS] Disposing');
    _debounce?.cancel();
    _sub?.cancel();
    super.dispose();
  }
}



//
// import 'dart:async';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../../core/api/api_constants.dart';
// import '../../../core/services/google_maps_api_repository.dart';
// import 'location_controller.dart';
//
// final addressProvider = StateNotifierProvider<AddressNotifier, String?>(
//       (ref) => AddressNotifier(ref),
// );
//
// class AddressNotifier extends StateNotifier<String?> {
//   AddressNotifier(this.ref) : super('Fetching address…') {
//     _listenLocation();
//   }
//
//   final Ref ref;
//   final _repo = GoogleMapsApiRepository();
//   StreamSubscription<Position?>? _sub;
//
//   void _listenLocation() {
//     _sub = ref.read(locationProvider.notifier).stream.listen((pos) async {
//       if (pos == null) return;
//       try {
//         state = await _repo.getAddress(
//           latitude: pos.latitude,
//           longitude: pos.longitude,
//           apiKey: ApiURLConstants.mapApiKay,
//         );
//       } catch (e) {
//         state = 'Unable to fetch address';
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     _sub?.cancel();
//     _repo.dispose();
//     super.dispose();
//   }
// }

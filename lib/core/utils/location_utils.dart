import 'package:geolocator/geolocator.dart';

class LocationServiceUtil {
  /// Check whether GPS/location service is enabled
  static Future<bool> isServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  /// Open system location settings
  static Future<void> openLocationSettings() async {
    await Geolocator.openLocationSettings();
  }
}

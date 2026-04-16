
import 'package:permission_handler/permission_handler.dart';

class PermissionUtil {
  /// Request both camera and location permissions
  static Future<Map<Permission, PermissionStatus>> requestAll() async {
    return await [
      Permission.camera,
      Permission.locationWhenInUse,
    ].request();
  }

  /// Check if camera permission is granted
  static Future<bool> isCameraGranted() async => Permission.camera.isGranted;

  /// Check if location permission is granted
  static Future<bool> isLocationGranted() async =>
      Permission.locationWhenInUse.isGranted;

  /// Check if any permission is permanently denied
  static Future<bool> isAnyPermanentlyDenied() async {
    return await Permission.camera.isPermanentlyDenied ||
        await Permission.locationWhenInUse.isPermanentlyDenied;
  }

  /// Open app settings to let user manually grant permission
  static Future<void> openSettings() async {
    await openAppSettings();
  }
}


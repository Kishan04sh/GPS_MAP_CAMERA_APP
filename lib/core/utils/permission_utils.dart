
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

//
// import 'package:permission_handler/permission_handler.dart';
//
// class PermissionUtil {
//   /// Request camera + location permissions
//   static Future<bool> requestAll() async {
//     final result = await [
//       Permission.camera,
//       Permission.microphone,
//       Permission.locationWhenInUse,
//       Permission.locationAlways,
//     ].request();
//
//     // return true only if all granted
//     return result.values.every((status) => status.isGranted);
//   }
//
//   /// Check individual permissions
//   static Future<bool> isCameraGranted() async => await Permission.camera.isGranted;
//   static Future<bool> isMicrophoneGranted() async => await Permission.microphone.isGranted;
//   static Future<bool> isLocationGranted() async =>
//       await Permission.locationWhenInUse.isGranted || await Permission.locationAlways.isGranted;
//
//   /// Check if any permission is permanently denied
//   static Future<bool> isAnyPermanentlyDenied() async {
//     return await Permission.camera.isPermanentlyDenied ||
//         await Permission.locationWhenInUse.isPermanentlyDenied ||
//         await Permission.microphone.isPermanentlyDenied;
//   }
//
//   /// Open app settings to manually grant permission
//   static Future<void> openSettings() async {
//     await openAppSettings();
//   }
// }

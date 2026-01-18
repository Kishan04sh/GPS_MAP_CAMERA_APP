import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';

class DeviceService {
  Future<String> getDeviceId() async {
    final deviceInfo = DeviceInfoPlugin();

    if (Platform.isAndroid) {
      final info = await deviceInfo.androidInfo;
      return info.id;
    } else {
      final info = await deviceInfo.iosInfo;
      return info.identifierForVendor ?? 'unknown';
    }
  }
}

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// ********************************************************************

class AuthStorageKeys {
  static const isLoggedIn = 'is_logged_in';
  static const loginType = 'login_type';
  static const firebaseUid = 'firebase_uid';
  static const mobileNumber = 'mobile_number';
  static const deviceId = 'device_id';
}

/// ************************************************************************


class SecureStorageService {
  static const _storage = FlutterSecureStorage();

  Future<void> write(String key, String value) async {
    await _storage.write(key: key, value: value);
  }

  Future<String?> read(String key) async {
    return await _storage.read(key: key);
  }

  Future<void> delete(String key) async {
    await _storage.delete(key: key);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }
}


/// ************************************************************************
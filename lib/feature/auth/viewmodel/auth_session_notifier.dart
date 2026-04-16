
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/device_service.dart';
import '../../../core/storege/secure_storage_service.dart';
import '../model/auth_session.dart';

/// ***************************************************************
/// AUTH SESSION PROVIDER
/// ***************************************************************
final authSessionProvider =
StateNotifierProvider<AuthSessionNotifier, AuthState>(
      (ref) => AuthSessionNotifier(),
);

/// ***************************************************************
/// AUTH SESSION NOTIFIER
/// ***************************************************************
class AuthSessionNotifier extends StateNotifier<AuthState> {
  AuthSessionNotifier() : super(AuthState.loading()) {
    _loadSession();
  }

  final _storage = SecureStorageService();
  final _deviceService = DeviceService();

  /// *************************************************************
  /// Load session from secure storage
  Future<void> _loadSession() async {
    try {
      final isLoggedIn = await _storage.read(AuthStorageKeys.isLoggedIn);

      if (isLoggedIn != 'true') {
        print('❌ [AuthSession] No active session');
        state = AuthState.unauthenticated();
        return;
      }

      final deviceId = await _storage.read(AuthStorageKeys.deviceId) ?? 'unknown';
      final loginTypeStr = await _storage.read(AuthStorageKeys.loginType);

      final session = AuthSession(
        isLoggedIn: true,
        deviceId: deviceId,
        loginType: LoginType.values.firstWhere(
              (e) => e.name == loginTypeStr,
          orElse: () => LoginType.otp,
        ),
        uid: await _storage.read(AuthStorageKeys.firebaseUid),
        mobile: await _storage.read(AuthStorageKeys.mobileNumber),
      );

      state = AuthState.authenticated(session);
      print('✅ [AuthSession] Session loaded: $session');
    } catch (e) {
      print('❌ [AuthSession] Error loading session: $e');
      state = AuthState.unauthenticated();
    }
  }

  /// *************************************************************
  /// Save login session
  Future<void> saveLogin({
    String? uid,
    String? mobile,
    required LoginType loginType,
  }) async {
    final deviceId = await _deviceService.getDeviceId();

    await _storage.write(AuthStorageKeys.isLoggedIn, 'true');
    await _storage.write(AuthStorageKeys.loginType, loginType.name);
    if (uid != null) await _storage.write(AuthStorageKeys.firebaseUid, uid);
    if (mobile != null) await _storage.write(AuthStorageKeys.mobileNumber, mobile);
    await _storage.write(AuthStorageKeys.deviceId, deviceId);

    final session = AuthSession(
      isLoggedIn: true,
      loginType: loginType,
      uid: uid,
      mobile: mobile,
      deviceId: deviceId,
    );

    state = AuthState.authenticated(session);
    print('✅ [AuthSession] Login saved: $session');
  }

  /// *****************xx Logout user********************************************

  Future<void> logout() async {
    try {
      await _storage.write(AuthStorageKeys.isLoggedIn, 'false');
      await _storage.delete(AuthStorageKeys.firebaseUid);
      await _storage.delete(AuthStorageKeys.userId);
      await _storage.delete(AuthStorageKeys.mobileNumber);
      await _storage.delete(AuthStorageKeys.loginType);
      await _storage.delete(AuthStorageKeys.deviceId);
      state = AuthState.unauthenticated();
      print('🔴 [AuthSession] Logged out, redirect to login');
    } catch (e) {
      print('❌ [AuthSession] Logout error: $e');
      state = AuthState.unauthenticated();
    }
  }
}

/// ***************************************************************
/// AUTH STATE
/// ***************************************************************
enum AuthStatus { loading, authenticated, unauthenticated }

class AuthState {
  final AuthStatus status;
  final AuthSession? session;

  AuthState({required this.status, this.session});

  factory AuthState.loading() => AuthState(status: AuthStatus.loading);
  factory AuthState.authenticated(AuthSession session) =>
      AuthState(status: AuthStatus.authenticated, session: session);
  factory AuthState.unauthenticated() =>
      AuthState(status: AuthStatus.unauthenticated);
}

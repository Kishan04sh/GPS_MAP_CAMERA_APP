enum LoginType { google, otp }

class AuthSession {
  final bool isLoggedIn;
  final LoginType? loginType;
  final String? uid;
  final String? mobile;
  final String deviceId;

  AuthSession({
    required this.isLoggedIn,
    required this.deviceId,
    this.loginType,
    this.uid,
    this.mobile,
  });

  @override
  String toString() {
    return 'AuthSession(isLoggedIn: $isLoggedIn, loginType: $loginType, uid: $uid, mobile: $mobile, deviceId: $deviceId)';
  }
}

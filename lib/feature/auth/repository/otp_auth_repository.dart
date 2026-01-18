import '../../../core/api/api_services.dart';
import '../../../core/api/api_exception.dart';

class OtpAuthRepository {
  final ApiService _api = ApiService();

  Future<void> sendOtp({
    required String mobile,
    required String otp,
  }) async {
    try {
      await _api.sendSmsOtp(mobile: mobile, otp: otp);
    } on ApiException catch (e) {
      throw ApiException("OTP sending failed: ${e.message}");
    }
  }
}

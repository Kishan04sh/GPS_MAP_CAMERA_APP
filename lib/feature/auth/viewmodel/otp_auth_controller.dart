import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../model/auth_session.dart';
import '../model/otp_state.dart';
import '../repository/otp_auth_repository.dart';
import 'auth_session_notifier.dart';

// final otpAuthControllerProvider =
// StateNotifierProvider<OtpAuthController, OtpAuthState>(
//       (ref) => OtpAuthController(OtpAuthRepository()),
// );


final otpAuthControllerProvider =
StateNotifierProvider<OtpAuthController, OtpAuthState>(
      (ref) => OtpAuthController(
    OtpAuthRepository(),
    ref,
  ),
);

class OtpAuthController extends StateNotifier<OtpAuthState> {
  final OtpAuthRepository _repo;
  final Ref _ref; // <-- Use Ref here
  static const Duration otpValidity = Duration(minutes: 2);
  static const int maxResend = 3;
  String? _generatedOtp;

  OtpAuthController(this._repo, this._ref) : super(OtpAuthState.initial());


  /// ****************************************************************************

  Future<void> sendOtp(String mobile) async {
    if (state.resendCount >= maxResend) {
      state = state.copyWith(
        status: OtpStatus.failure,
        error: "OTP resend limit exceeded",
      );
      return;
    }

    try {
      state = state.copyWith(status: OtpStatus.sending);
      _generatedOtp = _generateOtp();
      await _repo.sendOtp(mobile: mobile, otp: _generatedOtp!);

      state = state.copyWith(
        status: OtpStatus.sent,
        mobile: mobile,
        resendCount: state.resendCount + 1,
        expiresAt: DateTime.now().add(otpValidity),
      );
    } catch (e) {
      state = state.copyWith(
        status: OtpStatus.failure,
        error: e.toString(),
      );
    }
  }


  /// *******************************************************************

  Future<void> verifyOtp(String input) async {
    if (state.expiresAt == null || DateTime.now().isAfter(state.expiresAt!)) {
      state = state.copyWith(
        status: OtpStatus.failure,
        error: "OTP expired",
      );
      return;
    }

    if (input != _generatedOtp) {
      state = state.copyWith(
        status: OtpStatus.failure,
        error: "Invalid OTP",
      );
      return;
    }

    final authSessionNotifier = _ref.read(authSessionProvider.notifier);

    await authSessionNotifier.saveLogin(
      mobile: state.mobile,
      loginType: LoginType.otp,
    );

    _generatedOtp = null;
    state = state.copyWith(status: OtpStatus.success);
  }

  /// *************************************************************************

  String _generateOtp() => (100000 + Random().nextInt(900000)).toString();

  /// ***************************************************************************
}

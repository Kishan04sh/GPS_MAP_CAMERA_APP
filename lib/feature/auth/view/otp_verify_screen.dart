import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../model/otp_state.dart';
import '../viewmodel/otp_auth_controller.dart';

class OtpVerifyScreen extends ConsumerStatefulWidget {
  const OtpVerifyScreen({super.key});

  @override
  ConsumerState<OtpVerifyScreen> createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends ConsumerState<OtpVerifyScreen> {
  final TextEditingController _otpController = TextEditingController();
  Timer? _timer;
  int _secondsRemaining = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    final otpState = ref.read(otpAuthControllerProvider);
    if (otpState.expiresAt != null) {
      _secondsRemaining = otpState.expiresAt!
          .difference(DateTime.now())
          .inSeconds
          .clamp(0, 120);
      _timer?.cancel();
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (_secondsRemaining > 0) {
          setState(() {
            _secondsRemaining--;
          });
        } else {
          timer.cancel();
        }
      });
    }
  }

  @override
  void dispose() {
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final otpState = ref.watch(otpAuthControllerProvider);
    final otpControllerVM = ref.read(otpAuthControllerProvider.notifier);

 ///****************** Listen for success/error
    ref.listen<OtpAuthState>(
      otpAuthControllerProvider,
          (previous, next) {
        if (next.isSuccess && context.mounted) {
          AppSnackbar.show(
            context,
            message: "OTP verified successfully",
            type: SnackbarType.success,
          );
          context.go(RouteNames.home);
        }
        if (next.isError && context.mounted) {
          AppSnackbar.show(
            context,
            message: next.error ?? "OTP verification failed",
            type: SnackbarType.error,
          );
        }
      },
    );

    final canResend = otpState.resendCount < 3 && _secondsRemaining == 0;

 /// **********************************************************************

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),

      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: const CommonAppBar(
          title: 'Verify OTP',
          showDate: false,
        ),

/// ***********************************************************
        body: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),

            child: Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.08),
                    blurRadius: 25,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),


              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "OTP Verification",
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
                  ),


                  const SizedBox(height: 8),

                  Text(
                    "Enter the 6-digit OTP sent to",
                    style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
                  ),


                  const SizedBox(height: 4),

                  Text("+91 ${otpState.mobile}",
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w600),
                  ),


                  const SizedBox(height: 32),

                  // OTP Input
                  TextField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    maxLength: 6,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontSize: 22,
                        letterSpacing: 6,
                        fontWeight: FontWeight.bold),
                    decoration: InputDecoration(
                      counterText: "",
                      hintText: "------",
                      filled: true,
                      fillColor: Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(14),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

 ///******************************** Verify Button
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: otpState.isLoading
                          ? null
                          : () {
                        final otp = _otpController.text.trim();
                        if (otp.length != 6) {
                          AppSnackbar.show(
                            context,
                            message: "Please enter valid 6-digit OTP",
                            type: SnackbarType.error,
                          );
                          return;
                        }
                        otpControllerVM.verifyOtp(otp);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandDark,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      ),
                      child: otpState.isLoading
                          ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                          : const Text(
                        "Verify OTP",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

/// ****************************** Countdown + Resend **************************
                if (_secondsRemaining > 0)
                  Text("OTP expires in $_secondsRemaining seconds",
                      style: TextStyle(fontSize: 13, color: Colors.grey.shade600)),

                  TextButton(
                    onPressed: canResend
                        ? () async {
                      await otpControllerVM.sendOtp(otpState.mobile!);
                      _startTimer();
                      AppSnackbar.show(context,
                          message: "OTP resent successfully",
                          type: SnackbarType.success);
                    }
                        : null,
                    child: Text(
                      canResend
                          ? "Resend OTP"
                          : "Resend OTP in $_secondsRemaining s",
                      style: TextStyle(
                        color: canResend
                            ? AppColors.brandDark
                            : Colors.grey.shade500,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),


                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

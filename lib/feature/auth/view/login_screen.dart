
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../model/otp_state.dart';
import '../viewmodel/auth_view_model.dart';
import '../viewmodel/otp_auth_controller.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final TextEditingController mobileController = TextEditingController();
  bool isMobileValid = false;
  String? errorText;

 /// *********initState****************
  @override
  void initState() {
    super.initState();
    mobileController.addListener(onMobileChanged);
  }


  /// ********onMobileChanged*********************

  void onMobileChanged() {
    final value = mobileController.text.trim();
    if (value.isEmpty) {
      _updateValidation(false, null);
      return;
    }
    final isValid = RegExp(r'^[6-9]\d{9}$').hasMatch(value);
    _updateValidation(
      isValid,
      isValid ? null : 'Enter valid 10-digit mobile number',
    );
  }


  /// **********_updateValidation*********************************
  void _updateValidation(bool valid, String? error) {
    if (isMobileValid != valid || errorText != error) {
      setState(() {
        isMobileValid = valid;
        errorText = error;
      });
    }
  }


  /// **************************************************
  @override
  void dispose() {
    mobileController.removeListener(onMobileChanged);
    mobileController.dispose();
    super.dispose();
  }

/// ********************************************************************


  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final otpState = ref.watch(otpAuthControllerProvider);
    final otpController = ref.read(otpAuthControllerProvider.notifier);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.blueActionGradient,
        ),

        child: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: size.height - MediaQuery.of(context).padding.top,
              ),

              child: IntrinsicHeight(
                child: Column(
                  children: [
                    SizedBox(height: size.height * 0.08),

                    // ================= LOGO =================
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.25),
                            blurRadius: 30,
                            offset: const Offset(0, 12),
                          ),
                        ],
                      ),
                      child: ClipOval(
                        child: Image.asset(
                          AppImages.sp1,
                          height: size.width * 0.30,
                          width: size.width * 0.30,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ================= APP NAME =================
                    const Text(
                      'GPS Cam Bharat',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.3,
                      ),
                    ),

                    const SizedBox(height: 6),

                    const Text(
                      'Secure login to continue',
                      style: TextStyle(
                        color: AppColors.grey200,
                        fontSize: 14.5,
                      ),
                    ),

                    SizedBox(height: size.height * 0.07),

                    // ================= MOBILE INPUT =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: TextField(
                        controller: mobileController,
                        keyboardType: TextInputType.phone,
                        maxLength: 10,
                        style: const TextStyle(color: AppColors.black),
                        decoration: InputDecoration(
                          counterText: '',
                          filled: true,
                          fillColor: AppColors.white,
                          hintText: 'Enter mobile number',
                          prefixIcon: const Icon(Icons.phone_android),
                          errorText: errorText,
                          errorStyle: TextStyle(color: Colors.red[900],
                              fontSize: 15,fontWeight: FontWeight.w600),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.035),

                    // ================= CONTINUE BUTTON =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: ElevatedButton(
                        onPressed: ( !isMobileValid || otpState.isLoading)
                            ? null
                            : () async {

                          final mobile = mobileController.text.trim();

                          if (mobile.length != 10) {
                            AppSnackbar.show(context, message: "Enter valid mobile number",
                                type: SnackbarType.error);
                            return;
                          }

                          await otpController.sendOtp(mobile);

                          final state = ref.read(otpAuthControllerProvider);
                          if (!context.mounted) return;

                          if (state.status == OtpStatus.sent) {
                            context.go(RouteNames.otpVerify);
                          } else if (state.status == OtpStatus.failure) {
                            AppSnackbar.show(
                              context,
                              message: state.isError.toString(),
                              type: SnackbarType.error,
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isMobileValid
                              ? AppColors.success
                              : AppColors.grey400,
                          disabledBackgroundColor: AppColors.grey400,
                          minimumSize: const Size(double.infinity, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 3,
                        ),
                        child: otpState.isLoading
                            ? const SizedBox(
                          height: 25,
                          width: 25,
                          child: CircularProgressIndicator(
                            color: AppColors.white,
                            strokeWidth: 2,
                          ),
                        )
                            : const Text('Continue With OTP',
                          style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: AppColors.white),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.035),

                    // ================= OR DIVIDER =================
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 26, vertical: 6),
                      child: Row(
                        children: [
                          Expanded(child:
                              Divider(color: AppColors.grey300)),
                          Padding(
                            padding:
                            EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'OR',
                              style: TextStyle(
                                color: AppColors.grey200,
                                fontSize: 13,
                                letterSpacing: 1.2,
                              ),
                            ),
                          ),
                          Expanded(child: Divider(color: AppColors.grey300)),
                        ],
                      ),
                    ),

                    SizedBox(height: size.height * 0.02),

                    // ================= GOOGLE BUTTON =================
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 26),
                      child: _googleButton(context,ref),
                    ),

                    const Spacer(),

                    // ================= FOOTER =================
                    Padding(
                      padding: const EdgeInsets.only(bottom: 60),
                      child: RichText(
                        text: const TextSpan(
                          children: [
                            TextSpan(
                              text: 'Powered by ',
                              style: TextStyle(
                                  color: AppColors.grey200, fontSize: 13.5),
                            ),
                            TextSpan(
                              text: 'Sharim Tech Solution',
                              style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: 14.5,
                                  fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

/// ***********************_googleButton******************************************************

  static Widget _googleButton(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authViewModelProvider);
    final authVM = ref.read(authViewModelProvider.notifier);

    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.black,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        elevation: 3,
      ),

 /// ************************************************************
      onPressed: authState.status == AuthStatus.loading
          ? null
          : () async {
        await authVM.loginWithGoogle();
        final updatedState = ref.read(authViewModelProvider);

        if (updatedState.status == AuthStatus.authenticated && context.mounted) {
          AppSnackbar.show(
            context,
            message: "Login successful",
            type: SnackbarType.success,
          );
          context.go(RouteNames.home);
        }

        if (updatedState.status == AuthStatus.error &&
            context.mounted) {
          AppSnackbar.show(
            context,
            message: updatedState.errorMessage ?? 'Login failed',
            type: SnackbarType.error,
          );
        }
      },
 /// *****************************************************************************
      child: authState.status == AuthStatus.loading
          ? const SizedBox(
        height: 25,
        width: 25,
        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.white,),
      )
          :  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            AppImages.icon,
            height: 22,
          ),
          const SizedBox(width: 12),
          const Text(
            'Continue with Google',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

/// ***********************************************************************
}

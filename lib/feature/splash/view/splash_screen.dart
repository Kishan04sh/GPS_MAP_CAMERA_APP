
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/storege/secure_storage_service.dart';
import '../../auth/model/auth_session.dart';


class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with TickerProviderStateMixin {

  late final AnimationController _logoController;
  late final AnimationController _textController;
  late final Animation<double> _logoScale;
  late final Animation<double> _logoFade;
  late final Animation<Offset> _titleSlide;
  final _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();

    /// Logo animation
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _logoScale = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeOutBack,
    );

    _logoFade = CurvedAnimation(
      parent: _logoController,
      curve: Curves.easeIn,
    );

    /// Text animation
    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _titleSlide = Tween<Offset>(
      begin: const Offset(0, 1.8),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _textController,
        curve: Curves.easeOut,
      ),
    );

    /// Start sequence
    _logoController.forward().then((_) => _textController.forward());

    // After splash, navigate based on local storage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _navigateBasedOnLocalStorage();
    });
  }


/// ***************************************************************************

  Future<void> _navigateBasedOnLocalStorage() async {
    await Future.delayed(const Duration(seconds: 3)); // Splash duration

    final isLoggedIn = await _storage.read(AuthStorageKeys.isLoggedIn);
    final loginTypeStr = await _storage.read(AuthStorageKeys.loginType);
    final uid = await _storage.read(AuthStorageKeys.firebaseUid);
    final mobile = await _storage.read(AuthStorageKeys.mobileNumber);
    final deviceId = await _storage.read(AuthStorageKeys.deviceId);

    if (isLoggedIn == 'true' && uid != null) {
      final session = AuthSession(
        isLoggedIn: true,
        loginType: loginTypeStr == 'otp' ? LoginType.otp : LoginType.google,
        uid: uid,
        mobile: mobile,
        deviceId: deviceId ?? 'unknown',
      );

      print('💡 Session loaded: $session');
      print('➡️ Redirecting to Home');
      if (!mounted) return;
      context.go(RouteNames.home);
    } else {
      print('💡 No valid session → redirecting to Login');
      if (!mounted) return;
      context.go(RouteNames.login);
    }
  }
  /// ******************************************************************

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    super.dispose();
  }


  /// ***************************************************************

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: AppColors.blueBrandGradient,
        ),
        child: SafeArea(
          child: Column(
            children: [

              /// ================= CENTER CONTENT =================
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [

                    /// Logo
                    ScaleTransition(
                      scale: _logoScale,
                      child: FadeTransition(
                        opacity: _logoFade,
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: AppColors.white,
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.primary.withOpacity(0.35),
                                blurRadius: 36,
                                offset: const Offset(0, 16),
                              ),
                            ],
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              AppImages.sp1,
                              height: size.width * 0.35,
                              width: size.width * 0.35,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.08),

                    /// App Name
                    SlideTransition(
                      position: _titleSlide,
                      child: const Text(
                        "GPS Cam Bharat",
                        style: TextStyle(
                          color: AppColors.white,
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.5,
                        ),
                      ),
                    ),

                    SizedBox(height: size.height * 0.015),

                    /// Tagline
                    FadeTransition(
                      opacity: _textController,
                      child: const Text(
                        "Secure Geo-Tagged Camera Solution",
                        style: TextStyle(
                          color: AppColors.grey200,
                          fontSize: 15,
                          letterSpacing: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              /// ================= BOTTOM POWERED BY =================
              Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: FadeTransition(
                  opacity: _textController,
                  child: RichText(
                    text: const TextSpan(
                      children: [
                        TextSpan(
                          text: 'Powered by ',
                          style: TextStyle(
                            color: AppColors.grey200,
                            fontSize: 14.5,
                            letterSpacing: 1.0,
                          ),
                        ),
                        TextSpan(
                          text: 'Sharim Tech Solution',
                          style: TextStyle(
                            color: AppColors.white, // Dark blue
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.05,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}

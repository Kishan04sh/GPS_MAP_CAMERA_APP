
import 'package:go_router/go_router.dart';
import 'package:gps_map_camera/feature/video/view/video_camera_screen.dart';
import '../../feature/auth/model/auth_user_model.dart';
import '../../feature/auth/view/login_screen.dart';
import '../../feature/auth/view/otp_verify_screen.dart';
import '../../feature/auth/view/sign_up_screen.dart';
import '../../feature/camera/view/camera_screen.dart';
import '../../feature/capture/presentation/screens/capture_screen.dart';
import '../../feature/gallery/view/gallery_screen.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/home/view/home_tab.dart';
import '../../feature/map/view/map_screen.dart';
import '../../feature/settings/view/settings_screen.dart';
import '../../feature/splash/view/splash_screen.dart';
import '../widgets/app_error_screen.dart';
import '../widgets/permission_gate_screen.dart';
import 'route_names.dart';



final GoRouter appRouter = GoRouter(
  initialLocation: RouteNames.splash,

  errorBuilder: (context, state) => AppErrorScreen(
    message: state.error?.message ?? "The page you are looking for doesn’t exist",
  ),

  routes: [
    GoRoute(
      path: RouteNames.splash,
      builder: (_, __) => const SplashScreen(),
    ),

    GoRoute(
      path: RouteNames.login,
      builder: (_, __) => const LoginScreen(),
    ),

    GoRoute(
      path: RouteNames.signup,
      builder: (context, state) {
        final user = state.extra as UserModel; // ✅ RECEIVE USER
        return SignupScreen(user: user);       // ✅ PASS TO SCREEN
      },
    ),


    GoRoute(
      path: RouteNames.home,
      builder: (_, __) => const HomeScreen(),
      routes: [
        GoRoute(
          path: RouteNames.homeTab,
          builder: (_, __) => const HomeTab(),
        ),
        GoRoute(
          path: RouteNames.galleryTab,
          builder: (_, __) => const GalleryTab(),
        ),
        GoRoute(
          path: RouteNames.mapTab,
          builder: (_, __) => const MapTab(),
        ),
        GoRoute(
          path: RouteNames.settingsTab,
          builder: (_, __) => const SettingsTab(),
        ),
      ],
    ),

    // Camera route
    GoRoute(
      path: RouteNames.camera,
      builder: (_, __) => const CameraScreen(),
    ),

    // Camera route
    GoRoute(
      path: RouteNames.video,
      builder: (_, __) => const VideoCameraScreen(),
    ),

    GoRoute(
      path: RouteNames.captureBoth,
      builder: (_, __) => const CaptureScreen(),
    ),


    GoRoute(
      path: RouteNames.otpVerify,
      builder: (_, __) => const OtpVerifyScreen(),
    ),

    GoRoute(
      path: RouteNames.permission,
      builder: (context, state) => const PermissionGateScreen(),
    ),


    /// *******************************************************

  ],
);

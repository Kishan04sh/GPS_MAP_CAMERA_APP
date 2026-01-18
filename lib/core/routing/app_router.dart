
import 'package:go_router/go_router.dart';
import '../../feature/auth/view/login_screen.dart';
import '../../feature/auth/view/otp_verify_screen.dart';
import '../../feature/camera/view/camera_screen.dart';
import '../../feature/gallery/view/gallery_screen.dart';
import '../../feature/home/view/home_screen.dart';
import '../../feature/home/view/home_tab.dart';
import '../../feature/map/view/map_screen.dart';
import '../../feature/settings/view/settings_screen.dart';
import '../../feature/splash/view/splash_screen.dart';
import '../widgets/app_error_screen.dart';
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
      builder: (_, __) => LoginScreen(),
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


    GoRoute(
      path: RouteNames.otpVerify,
      builder: (_, __) => OtpVerifyScreen(),
    ),

    /// *******************************************************

  ],
);


import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'core/ads/ad_service.dart';
import 'core/routing/app_router.dart';
import 'core/widgets/app_error_screen.dart';
import 'feature/camera/viewmodal/address_controller.dart';
import 'feature/camera/viewmodal/location_controller.dart';
import 'feature/capture/presentation/viewmodel/capture_viewmodel.dart';
import 'feature/splash/view/splash_screen.dart';
import 'firebase_options.dart';


void main() {
  runZonedGuarded(() {
    WidgetsFlutterBinding.ensureInitialized();
    /// 🔹 Flutter framework errors
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      debugPrint('FLUTTER ERROR: ${details.exception}');
      debugPrintStack(stackTrace: details.stack);
    };

    runApp(
      const ProviderScope(
        child: AppBootstrap(),
      ),
    );
  }, (error, stackTrace) {
    debugPrint('ZONE ERROR: $error');
    debugPrintStack(stackTrace: stackTrace);
  });
}


/// *****************AppBootstrap*************************************************************


class AppBootstrap extends StatefulWidget {
  const AppBootstrap({super.key});

  @override
  State<AppBootstrap> createState() => _AppBootstrapState();
}

class _AppBootstrapState extends State<AppBootstrap> {
  bool _initialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
      ]);

      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      /// ======= ⭐ ADD THIS ==============
      debugPrint("🔥 Firebase Ready");
      // ✅ AdMob INIT (IMPORTANT)
      await MobileAds.instance.initialize();
      debugPrint("🔥 AdMob Initialized");
      // ✅ Correct Riverpod usage (NO new ProviderContainer)
      final container = ProviderScope.containerOf(context);
      await container.read(adServiceProvider).init();
      ///*******************************
      await _bootHardware();

      setState(() {
        _initialized = true;
      });
    } catch (e, st) {
      debugPrint('INIT ERROR: $e');
      debugPrintStack(stackTrace: st);
      setState(() {
        _error = 'Failed to initialize app';
      });
    }
  }

/// **************************************************************
  Future<void> _bootHardware() async {
    debugPrint("🚀 BootHardware Started");

    final container = ProviderScope.containerOf(context);

    try {
      debugPrint("📷 Initializing Capture Provider...");
      unawaited(
        container.read(captureProvider.notifier).initialize().then((_) {
          debugPrint("✅ Capture Provider Initialized");
        }).catchError((e, st) {
          debugPrint("❌ Capture Init Error: $e");
          debugPrintStack(stackTrace: st);
        }),
      );

      debugPrint("📍 Initializing Location Provider...");
      unawaited(
        container.read(locationProvider.notifier).initLocation().then((_) {
          debugPrint("✅ Location Provider Initialized");
        }).catchError((e, st) {
          debugPrint("❌ Location Init Error: $e");
          debugPrintStack(stackTrace: st);
        }),
      );

      debugPrint("🏠 Forcing Address Provider Initialization...");
      container.read(addressProvider);

      debugPrint("🔥 BootHardware Completed");
    } catch (e, st) {
      debugPrint("❌ BootHardware Fatal Error: $e");
      debugPrintStack(stackTrace: st);
    }
  }


  /// *****************************************************************

  @override
  Widget build(BuildContext context) {
    /// ❌ Init failed
    if (_error != null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: AppErrorScreen(message: _error!),
      );
    }

    /// ⏳ Initializing
    if (!_initialized) {
      return const MaterialApp(
        debugShowCheckedModeBanner: false,
        home: SplashScreen(isBootstrap: true,),
      );
    }

    /// ✅ App ready
    return const MyApp();
  }
}

/// ******************MyApp**************************************************

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'GPS Cam Bharat',
      routerConfig: appRouter,
    );
  }
}

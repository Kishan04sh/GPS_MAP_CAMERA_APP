
/*
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../camera/viewmodal/address_controller.dart';
import '../../../camera/viewmodal/location_controller.dart';
import '../viewmodel/capture_viewmodel.dart';
import '../widgets/capture_app_bar.dart';
import '../widgets/capture_preview.dart';
import '../widgets/capture_button.dart';
import '../widgets/capture_mode_switch.dart';
import '../widgets/zoomable_camera_preview.dart';
import '../widgets/location_overlay_card.dart';

enum DeviceViewSide {
  portrait,
  landscapeLeft,
  landscapeRight,
  upsideDown,
}

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with WidgetsBindingObserver {

  StreamSubscription? _sensorSub;
  DeviceViewSide _side = DeviceViewSide.portrait;

  bool _booted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());

    _sensorSub = accelerometerEvents.listen((event) {
      final x = event.x;
      final y = event.y;

      DeviceViewSide newSide = _side;

      if (y < -7) newSide = DeviceViewSide.portrait;
      else if (y > 7) newSide = DeviceViewSide.upsideDown;
      else if (x > 7) newSide = DeviceViewSide.landscapeLeft;
      else if (x < -7) newSide = DeviceViewSide.landscapeRight;

      if (newSide != _side) {
        setState(() => _side = newSide);
      }
    });
  }

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;

    await ref.read(captureProvider.notifier).initialize();
    await ref.read(locationProvider.notifier).initLocation();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = ref.read(captureProvider.notifier);
    if (state == AppLifecycleState.resumed) vm.onResume();
    if (state == AppLifecycleState.paused) vm.onPause();
  }

  /// Rotation turns (never ulta text)
  double _getTurns() {
    switch (_side) {
      case DeviceViewSide.portrait:
        return 0;
      case DeviceViewSide.landscapeLeft:
        return 0.25;
      case DeviceViewSide.landscapeRight:
        return -0.25;
      case DeviceViewSide.upsideDown:
        return 0.5;
    }
  }

  /// Dynamic positioning (always bottom of device)
  Map<String, double?> _getPosition() {
    switch (_side) {

      case DeviceViewSide.portrait:
        return {
          "left": 12,
          "right": 12,
          "bottom": 550,
          "top": null,
        };

      case DeviceViewSide.landscapeLeft:
        return {
          "left": null,
          "right": 400,
          "top": 12,
          "bottom": 12,
        };

      case DeviceViewSide.landscapeRight:
        return {
          "left": 400,
          "right": null,
          "top": 12,
          "bottom": 12,
        };

      case DeviceViewSide.upsideDown:
        return {
          "left": 12,
          "right": 12,
          "top": 450,
          "bottom": null,
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final position = ref.watch(locationProvider);
    final address = ref.watch(addressProvider);
    final time = DateTime.now().toString();
    final pos = _getPosition();

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [

          /// Camera Preview
          const Positioned.fill(
            child: ZoomHandlerWrapper(child: CapturePreview()),
          ),

          /// App Bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: CaptureAppBar(),
            ),
          ),

          /// LOCATION OVERLAY (Fully Dynamic + Smooth)
          if (position != null)
            Positioned(
              left: pos["left"],
              right: pos["right"],
              top: pos["top"],
              bottom: pos["bottom"],
              child: SafeArea(
                child: AnimatedRotation(
                  turns: _getTurns(),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: LocationOverlayCard(
                    position: position,
                    address: address ?? "Fetching address...",
                    time: time,
                  ),
                ),
              ),
            ),

          /// Mode Switch
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(child: CaptureModeSwitch()),
            ),
          ),

          /// Capture Button
          const Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(child: CaptureButton()),
            ),
          ),

          /// Loader
          if (captureState.initializing && !captureState.ready)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sensors_plus/sensors_plus.dart';
import '../../../camera/view/full_image_view.dart';
import '../../../camera/viewmodal/address_controller.dart';
import '../../../camera/viewmodal/location_controller.dart';
import '../../../gallery/modal/media_type.dart';
import '../../../gallery/view_modal/gallery_controller.dart';
import '../../../video/view/video_preview_screen.dart';
import '../../domain/capture_result.dart';
import '../../domain/capture_state.dart';
import '../viewmodel/capture_viewmodel.dart';
import '../widgets/capture_app_bar.dart';
import '../widgets/capture_preview.dart';
import '../widgets/capture_button.dart';
import '../widgets/capture_mode_switch.dart';
import '../widgets/zoomable_camera_preview.dart';
import '../widgets/location_overlay_card.dart';

final captureScreenSideProvider = StateProvider<DeviceViewSide>((ref) => DeviceViewSide.portrait);


enum DeviceViewSide {
  portrait,
  landscapeLeft,
  landscapeRight,
  upsideDown,
}

class CaptureScreen extends ConsumerStatefulWidget {
  const CaptureScreen({super.key});

  @override
  ConsumerState<CaptureScreen> createState() => _CaptureScreenState();
}

class _CaptureScreenState extends ConsumerState<CaptureScreen>
    with WidgetsBindingObserver {
  StreamSubscription? _sensorSub;
  DeviceViewSide _side = DeviceViewSide.portrait;
  bool _booted = false;
  late final ProviderSubscription<CaptureState> resultSub;
  // CaptureScreen ke state me


  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
    /// 🎯 RESULT LISTENER (ONE TIME ONLY)*************************
    resultSub = ref.listenManual<CaptureState>(
      captureProvider,
      _handleResult,
    );
    /// ************************************************************

    /// ✅ CORRECT accelerometer mapping
    _sensorSub = accelerometerEvents.listen((event) {
      final x = event.x;
      final y = event.y;

      DeviceViewSide newSide = _side;

      if (y > 7) {
        newSide = DeviceViewSide.portrait;
      } else if (y < -7) {
        newSide = DeviceViewSide.upsideDown;
      } else if (x > 7) {
        newSide = DeviceViewSide.landscapeRight;
      } else if (x < -7) {
        newSide = DeviceViewSide.landscapeLeft;
      }

      if (newSide != _side) {
        setState(() => _side = newSide);
        ref.read(captureScreenSideProvider.notifier).state = newSide; // update provider
      }
    });
  }

  ///**********************************************************************

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;
    await ref.read(captureProvider.notifier).initialize();
    await ref.read(locationProvider.notifier).initLocation();
  }

///*****************************************************************************

  Future<void> _handleResult(CaptureState? prev, CaptureState next) async {
    final result = next.result;
    if (result == null || !mounted) return;

    /// one-shot event
    ref.read(captureProvider.notifier).consumeResult();

    try {

      /// read LIVE location (UI purpose)
      final livePos = ref.read(locationProvider);
      final liveAddr = ref.read(addressProvider) ?? "Fetching address...";

      /// ================= PHOTO =================
      if (result is PhotoCapture) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => FullImageView(
              file: result.file,
              position: livePos, // fallback safety
              address: livePos != null ? liveAddr : result.address,
            ),
          ),
        );

        if (!mounted) return;
        /// upload uses CAPTURE metadata (correct geo proof)
        await ref.read(galleryViewModelProvider.notifier).uploadMedia(
          context,
          file: result.file,
          latitude: result.lat.toString(),
          longitude: result.lng.toString(),
          location: result.address,
          type: MediaType.image,
        );
      }

      /// ================= VIDEO =================
      else if (result is VideoCapture) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => VideoPreviewScreen(video: result.file),
          ),
        );

        if (!mounted) return;
        await ref.read(galleryViewModelProvider.notifier).uploadMedia(
          context,
          file: result.file,
          latitude: result.lat.toString(),
          longitude: result.lng.toString(),
          location: result.address,
          type: MediaType.video,
        );
      }

    } catch (e) {
      debugPrint("Result handling error: $e");
    }
  }


  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final vm = ref.read(captureProvider.notifier);
    if (state == AppLifecycleState.resumed) vm.onResume();
    if (state == AppLifecycleState.paused) vm.onPause();
  }

  /// ✅ Smooth rotation (text kabhi ulta nahi)
  double _getTurns() {
    switch (_side) {
      case DeviceViewSide.portrait:
        return 0;
      case DeviceViewSide.landscapeLeft:
        return -0.25;
      case DeviceViewSide.landscapeRight:
        return 0.25;
      case DeviceViewSide.upsideDown:
        return 0.5;
    }
  }


  /// **************************************************************

  /// ✅ Fully responsive positioning
  Map<String, double?> _getPosition(BuildContext context) {
    final padding = MediaQuery.of(context).padding;
    const margin = 12.0;
    final width = MediaQuery.of(context).size.width;

    switch (_side) {
      case DeviceViewSide.portrait:
        return {
          "left": margin,
          "right": margin,
          "bottom": padding.bottom + 140, // 110
          "top": null,
        };

      case DeviceViewSide.landscapeLeft:
        return {
          "left": width * 1.08,
          "right": null,
          "top": margin,
          "bottom": margin,
        };

      case DeviceViewSide.landscapeRight:
        return {
          "left": null,
          "right": width * 1.08,
          "top": margin,
          "bottom": margin,
        };

      case DeviceViewSide.upsideDown:
        return {
          "left": margin,
          "right": margin,
          "top": padding.top + 40,
          "bottom": null,
        };
    }
  }



  /// *********************************************************************

  @override
  Widget build(BuildContext context) {
    final captureState = ref.watch(captureProvider);
    final position = ref.watch(locationProvider);
    final address = ref.watch(addressProvider);
    final time = DateTime.now().toString();
    final pos = _getPosition(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// Camera Preview
          const Positioned.fill(
            child: ZoomHandlerWrapper(child: CapturePreview()),
          ),

          /// App Bar
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: CaptureAppBar(),
            ),
          ),

          /// LOCATION OVERLAY
          if (position != null)
            Positioned(
              left: pos["left"],
              right: pos["right"],
              top: pos["top"],
              bottom: pos["bottom"],
              child: SafeArea(
                child: AnimatedRotation(
                  turns: _getTurns(),
                  duration: const Duration(milliseconds: 250),
                  curve: Curves.easeOut,
                  child: LocationOverlayCard(
                    position: position,
                    address: address ?? "Fetching address...",
                    time: time,
                  ),
                ),
              ),
            ),

          /// Mode Switch
          const Positioned(
            bottom: 100,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(child: CaptureModeSwitch()),
            ),
          ),

          /// Capture Button
          const Positioned(
            bottom: 10,
            left: 0,
            right: 0,
            child: SafeArea(
              top: false,
              child: Center(child: CaptureButton()),
            ),
          ),

          /// Loader
          if (captureState.initializing && !captureState.ready)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _sensorSub?.cancel();
    resultSub.close();     // MUST
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}




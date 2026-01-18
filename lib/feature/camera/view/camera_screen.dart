/*

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import 'package:gps_map_camera/core/widgets/app_snackbar.dart';
import '../viewmodal/camera_controller.dart';
import '../viewmodal/location_controller.dart';
import '../viewmodal/address_controller.dart';
import '../widget/bottom_info_panel.dart';
import '../widget/camera_pinch_wrapper.dart';
import '../widget/gps_camera_loading_overlay.dart';
import '../widget/camera_app_bar.dart';
import '../../../core/utils/image_stamp_util.dart';
import 'full_image_view.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _booted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;
    await Future.wait([
      ref.read(locationProvider.notifier).initLocation(),
      ref.read(cameraProvider.notifier).initCamera(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cam = ref.watch(cameraProvider);
    final camNotifier = ref.read(cameraProvider.notifier);
    final pos = ref.watch(locationProvider);
    final addr = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ================= CAMERA PREVIEW FULL SCREEN =================
          if (cam.controller != null && cam.controller!.value.isInitialized && !cam.initializing)
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: CameraPinchWrapper(
                  child: CameraPreview(cam.controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // ================= TOP APP BAR =================
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
                child: CameraAppBar()
            ),
          ),

          // ================= BOTTOM PANEL =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false, // ignore top padding
              child: BottomInfoPanel(
                position: pos,
                address: addr,
                onSwitchCamera: cam.controller != null ? camNotifier.switchCamera : null,
                onVideo: (){
                  AppSnackbar.show(
                    context,
                    message: 'Waiting for Not Working ',
                    type: SnackbarType.warning,
                  );
                },
                onCapture: cam.isReady && pos != null
                    ? () async {
                  final raw = await camNotifier.capture();
                  if (raw == null) return;
                  final stamped = await ImageStampUtil.stamp(
                    original: raw,
                    address: addr ?? '',
                    lat: pos.latitude,
                    lng: pos.longitude,
                    time: DateTime.now(),
                  );
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImageView(file: stamped, position: pos),
                    ),
                  );
                }
                    : null,
              ),
            ),
          ),

          // ================= LOADING OVERLAY =================
          if (cam.initializing) const GpsCameraLoadingOverlay(),
        ],
      ),
    );
  }
}
*/




import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../viewmodal/camera_controller.dart';
import '../viewmodal/location_controller.dart';
import '../viewmodal/address_controller.dart';
import '../widget/bottom_info_panel.dart';
import '../widget/camera_pinch_wrapper.dart';
import '../widget/gps_camera_loading_overlay.dart';
import '../widget/camera_app_bar.dart';
import '../../../core/utils/image_stamp_util.dart';
import 'full_image_view.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _booted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _boot());
  }

  Future<void> _boot() async {
    if (_booted) return;
    _booted = true;
    await Future.wait([
      ref.read(locationProvider.notifier).initLocation(),
      ref.read(cameraProvider.notifier).initCamera(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final cam = ref.watch(cameraProvider);
    final camNotifier = ref.read(cameraProvider.notifier);
    final pos = ref.watch(locationProvider);
    final addr = ref.watch(addressProvider);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        children: [
          // ================= CAMERA PREVIEW FULL SCREEN =================
          if (cam.controller != null && cam.controller!.value.isInitialized && !cam.initializing)
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: CameraPinchWrapper(
                  child: CameraPreview(cam.controller!),
                ),
              ),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // ================= TOP APP BAR =================
          const Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
                bottom: false,
                child: CameraAppBar()
            ),
          ),

          // ================= BOTTOM PANEL =================
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: SafeArea(
              top: false, // ignore top padding
              child: BottomInfoPanel(
                position: pos,
                address: addr,
                onSwitchCamera: cam.controller != null ? camNotifier.switchCamera : null,
                onVideo: (){
                  AppSnackbar.show(
                    context,
                    message: 'Waiting for Not Working ',
                    type: SnackbarType.warning,
                  );
                },
                onCapture: cam.isReady && pos != null
                    ? () async {
                  final raw = await camNotifier.capture();
                  if (raw == null) return;
                  final stamped = await ImageStampUtil.stamp(
                    original: raw,
                    address: addr ?? '',
                    lat: pos.latitude,
                    lng: pos.longitude,
                    time: DateTime.now(),
                  );
                  if (!mounted) return;
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => FullImageView(file: stamped, position: pos),
                    ),
                  );
                }
                    : null,
              ),
            ),
          ),

          // ================= LOADING OVERLAY =================
          if (cam.initializing) const GpsCameraLoadingOverlay(),
        ],
      ),
    );
  }
}


import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import '../modal/camera_state.dart';

final cameraProvider =
StateNotifierProvider<CameraNotifier, CameraState>((ref) {
  final notifier = CameraNotifier();
  ref.onDispose(notifier.disposeCamera);
  return notifier;
});

class CameraNotifier extends StateNotifier<CameraState>
    with WidgetsBindingObserver {
  CameraNotifier() : super(CameraState.empty) {
    WidgetsBinding.instance.addObserver(this);
  }

  List<CameraDescription> _cameras = [];
  int _index = 0;

  // ================= INIT CAMERA =================
  Future<void> initCamera() async {
    if (state.initializing || state.controller != null || state.disposed) return;
    state = state.copyWith(initializing: true);

    try {
      _cameras = await availableCameras();
      _index = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_index < 0) _index = 0;

      await _createController();
    } catch (e) {
      debugPrint('[CAMERA][INIT ERROR] $e');
      state = CameraState.empty;
    }
  }

  // ================= CREATE CONTROLLER =================
  Future<void> _createController() async {
    final camera = _cameras[_index];
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
    );

    await controller.initialize();

    final minZoom = await controller.getMinZoomLevel();
    final maxZoom = await controller.getMaxZoomLevel();

    // FRONT CAMERA FLASH SAFETY
    if (camera.lensDirection == CameraLensDirection.front) {
      await controller.setFlashMode(FlashMode.off);
    } else {
      await controller.setFlashMode(state.flashMode);
    }

    if (state.disposed) {
      await controller.dispose();
      return;
    }

    state = state.copyWith(
      controller: controller,
      initializing: false,
      minZoom: minZoom,
      maxZoom: maxZoom,
      zoom: 0.6, // 1.0
      flashMode: FlashMode.off,
    );
  }

  // ================= SWITCH CAMERA =================
  Future<void> switchCamera() async {
    if (state.initializing || _cameras.length < 2) return;
    state = state.copyWith(initializing: true);

    try {
      _index = (_index + 1) % _cameras.length;
      final old = state.controller;
      state = state.copyWith(controller: null);
      await old?.dispose();
      await _createController();
    } catch (e) {
      debugPrint('[CAMERA][SWITCH ERROR] $e');
      state = state.copyWith(initializing: false);
    }
  }

  // ================= FLASH =================
  Future<void> toggleFlash() async {
    final ctrl = state.controller;
    if (ctrl == null || !state.isReady) return;

    if (ctrl.description.lensDirection == CameraLensDirection.front) {
      state = state.copyWith(flashMode: FlashMode.off);
      return;
    }

    final next = switch (state.flashMode) {
      FlashMode.off => FlashMode.auto,
      FlashMode.auto => FlashMode.torch,
      _ => FlashMode.off,
    };

    try {
      await ctrl.setFlashMode(next);
      state = state.copyWith(flashMode: next);
    } catch (_) {
      await ctrl.setFlashMode(FlashMode.off);
      state = state.copyWith(flashMode: FlashMode.off);
    }
  }

  // ================= PINCH ZOOM =================
  Future<void> setZoom(double zoom) async {
    final ctrl = state.controller;
    if (ctrl == null || !state.isReady) return;
    final value = zoom.clamp(state.minZoom, state.maxZoom);
    await ctrl.setZoomLevel(value);
    state = state.copyWith(zoom: value);
  }

  // ================= CAPTURE =================
  // Future<File?> capture() async {
  //   if (!state.isReady || state.isRecording) return null;
  //   try {
  //     final xfile = await state.controller!.takePicture();
  //     final dir = await getApplicationDocumentsDirectory();
  //     final path = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
  //     await xfile.saveTo(path);
  //     return File(path);
  //   } catch (e) {
  //     debugPrint('[CAMERA][CAPTURE ERROR] $e');
  //     return null;
  //   }
  // }

  // ================= CAPTURE =================
  Future<File?> capture() async {
    if (!state.isReady || state.isRecording) return null;
    try {
      final xfile = await state.controller!.takePicture();
      final dir = await getApplicationDocumentsDirectory();
      final path = '${dir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await xfile.saveTo(path);

      // ===== TURN FLASH OFF AFTER CAPTURE =====
      if (state.flashMode != FlashMode.off) {
        try {
          await state.controller!.setFlashMode(FlashMode.off);
          state = state.copyWith(flashMode: FlashMode.off);
        } catch (e) {
          debugPrint('[CAMERA][FLASH RESET ERROR] $e');
        }
      }

      return File(path);
    } catch (e) {
      debugPrint('[CAMERA][CAPTURE ERROR] $e');
      return null;
    }
  }


  // ================= VIDEO =================
  Future<void> startVideo() async {
    if (!state.isReady || state.isRecording) return;
    await state.controller!.startVideoRecording();
    state = state.copyWith(isRecording: true);
  }

  Future<File?> stopVideo() async {
    if (!state.isReady || !state.isRecording) return null;
    final file = await state.controller!.stopVideoRecording();
    state = state.copyWith(isRecording: false);
    return File(file.path);
  }

  // ================= LIFECYCLE =================
  @override
  void didChangeAppLifecycleState(AppLifecycleState stateLife) {
    if (stateLife == AppLifecycleState.paused ||
        stateLife == AppLifecycleState.inactive) {
      disposeCamera();
    }
    if (stateLife == AppLifecycleState.resumed &&
        !state.disposed &&
        state.controller == null) {
      initCamera();
    }
  }

  // ================= DISPOSE =================
  Future<void> disposeCamera() async {
    final old = state.controller;
    state = CameraState.empty;
    try {
      await old?.dispose();
    } catch (_) {}
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    disposeCamera();
    super.dispose();
  }
}


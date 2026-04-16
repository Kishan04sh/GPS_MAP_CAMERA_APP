
import 'package:camera/camera.dart';
import 'dart:developer';

enum AppFlashMode { off, auto, on, torch }

class CameraDatasource {
  CameraController? _controller;
  List<CameraDescription> _cameras = [];
  int _index = 0;

  AppFlashMode _flashMode = AppFlashMode.off;

  double _minZoom = 1.0;
  double _maxZoom = 1.0;

  CameraController? get controller => _controller;
  bool get isInitialized => _controller?.value.isInitialized ?? false;
  bool get isRecording => _controller?.value.isRecordingVideo ?? false;
  AppFlashMode get flashMode => _flashMode;
  double get minZoom => _minZoom;
  double get maxZoom => _maxZoom;

  // ---------------- INIT ----------------
  Future<void> initialize() async {
    try {
      await dispose(); // safety

      _cameras = await availableCameras();
      _index = _cameras.indexWhere(
            (e) => e.lensDirection == CameraLensDirection.back,
      );
      if (_index < 0) _index = 0;

      await _createController();
    } catch (e) {
      log("Camera init error: $e");
      rethrow;
    }
  }

  Future<void> _createController() async {
    final cam = _cameras[_index];

    final controller = CameraController(
      cam,
      ResolutionPreset.high,
      enableAudio: true,
    );

    await controller.initialize();
    _controller = controller;

    // Cache zoom limits
    _minZoom = await controller.getMinZoomLevel();
    _maxZoom = await controller.getMaxZoomLevel();

    // Better auto behavior for back camera
    if (cam.lensDirection == CameraLensDirection.back) {
      await controller.setFocusMode(FocusMode.auto);
      await controller.setExposureMode(ExposureMode.auto);
    }

    await _applyFlashMode();
  }

  // ---------------- CAMERA SWITCH ----------------
  Future<void> switchCamera() async {
    if (_cameras.length < 2 || isRecording) return;

    try {
      _index = (_index + 1) % _cameras.length;

      final old = _controller;
      _controller = null;
      await old?.dispose();

      await _createController();
    } catch (e) {
      log("Switch camera error: $e");
    }
  }

  // ---------------- PHOTO ----------------
  Future<XFile?> takePhoto() async {
    try {
      final ctrl = _controller;
      if (ctrl == null || !ctrl.value.isInitialized) return null;
      if (ctrl.value.isTakingPicture) return null;
      if (_flashMode == AppFlashMode.torch) {
        _flashMode = AppFlashMode.off;
        await _applyFlashMode();
      }
      return await ctrl.takePicture();
    } catch (e) {
      log("Take photo error: $e");
      return null;
    }
  }

  // ---------------- VIDEO ----------------
  Future<void> startRecording() async {
    try {
      final ctrl = _controller;
      if (ctrl == null || !ctrl.value.isInitialized) return;
      if (ctrl.value.isRecordingVideo) return;
      // 🔥 VERY IMPORTANT — apply flash BEFORE recording
      await _applyFlashMode();
      await ctrl.startVideoRecording();

    } catch (e) {
      log("Start recording error: $e");
    }
  }

  Future<XFile?> stopRecording() async {
    try {
      final ctrl = _controller;
      if (ctrl == null || !ctrl.value.isInitialized) return null;
      if (!ctrl.value.isRecordingVideo) return null;

      final file = await ctrl.stopVideoRecording();

      // Turn off torch after recording
      if (_flashMode == AppFlashMode.torch) {
        _flashMode = AppFlashMode.off;
        await _applyFlashMode();
      }

      return file;
    } catch (e) {
      log("Stop recording error: $e");
      return null;
    }
  }

  // ---------------- ZOOM ----------------
  Future<void> setZoom(double zoom) async {
    try {
      final ctrl = _controller;
      if (ctrl == null || !ctrl.value.isInitialized) return;

      await ctrl.setZoomLevel(zoom.clamp(_minZoom, _maxZoom));
    } catch (e) {
      log("Zoom error: $e");
    }
  }

  // ---------------- FLASH CONTROL ----------------


  Future<void> cycleFlashMode() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    final isFront =
        ctrl.description.lensDirection == CameraLensDirection.front;

    if (isFront) {
      _flashMode = AppFlashMode.off;
      await _applyFlashMode();
      return;
    }

    switch (_flashMode) {
      case AppFlashMode.off:
        _flashMode = AppFlashMode.auto;
        break;
      case AppFlashMode.auto:
        _flashMode = AppFlashMode.on;
        break;
      case AppFlashMode.on:
        _flashMode = AppFlashMode.torch;
        break;
      case AppFlashMode.torch:
        _flashMode = AppFlashMode.off;
        break;
    }

    await _applyFlashMode();
  }


  Future<void> _applyFlashMode() async {
    final ctrl = _controller;
    if (ctrl == null || !ctrl.value.isInitialized) return;

    try {
      switch (_flashMode) {
        case AppFlashMode.off:
          await ctrl.setFlashMode(FlashMode.off);
          break;

        case AppFlashMode.auto:
          await ctrl.setFlashMode(FlashMode.auto);
          break;

        case AppFlashMode.on:
          await ctrl.setFlashMode(FlashMode.always);
          break;

        case AppFlashMode.torch:
          await ctrl.setFlashMode(FlashMode.torch);
          break;
      }

      log("Flash applied: $_flashMode");
    } catch (e) {
      log("Flash apply error: $e");
    }
  }


  // ---------------- PREVIEW ----------------
  Future<void> pausePreview() async {
    try {
      await _controller?.pausePreview();
    } catch (_) {}
  }

  Future<void> resumePreview() async {
    try {
      await _controller?.resumePreview();
    } catch (_) {}
  }

  // ---------------- DISPOSE ----------------
  Future<void> dispose() async {
    try {
      final old = _controller;
      _controller = null;
      await old?.dispose();
    } catch (e) {
      log("Dispose error: $e");
    }
  }
}

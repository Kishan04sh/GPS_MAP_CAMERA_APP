
import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:permission_handler/permission_handler.dart';
import '../modal/video_state.dart';

final videoCameraProvider =
StateNotifierProvider.autoDispose<VideoCameraController, VideoState>(
      (ref) {
    final controller = VideoCameraController();
    ref.onDispose(() {
      controller.dispose(); // autoDispose handle karega
      print('[Provider] VideoCameraController disposed');
    });
    return controller;
  },
);

class VideoCameraController extends StateNotifier<VideoState>
    with WidgetsBindingObserver {
  VideoCameraController() : super(VideoState.empty) {
    WidgetsBinding.instance.addObserver(this);
    print('[VideoController] CREATED');
  }

  final List<CameraDescription> _cameras = [];
  int _cameraIndex = 0;
  Timer? _timer;
  bool _disposed = false;
  bool _busy = false;

  // ================= PERMISSIONS =================
  Future<bool> _checkPermissions() async {
    final cameraStatus = await Permission.camera.status;
    final micStatus = await Permission.microphone.status;

    if (cameraStatus.isGranted && micStatus.isGranted) return true;

    final result = await [
      Permission.camera,
      Permission.microphone,
    ].request();

    return result[Permission.camera]?.isGranted == true &&
        result[Permission.microphone]?.isGranted == true;
  }

  // ================= INIT CAMERA =================
  Future<void> initCamera() async {
    if (_disposed || state.initializing) return;

    final granted = await _checkPermissions();
    if (!granted) {
      if (!_disposed) {
        state = state.copyWith(error: 'Camera & Mic permission required');
      }
      return;
    }

    try {
      if (_disposed) return;
      state = state.copyWith(initializing: true, error: null);

      _cameras.clear();
      _cameras.addAll(await availableCameras());
      if (_cameras.isEmpty) throw Exception('No camera found');

      _cameraIndex =
          _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_cameraIndex < 0) _cameraIndex = 0;

      final controller = await _createController(_cameras[_cameraIndex]);

      if (_disposed) {
        await controller.dispose();
        return;
      }

      state = state.copyWith(
        controller: controller,
        initializing: false,
        isFlashOn: false,
        zoom: 1.0,
      );

      print('[Camera] init SUCCESS');
    } catch (e, st) {
      if (!_disposed) {
        state = state.copyWith(initializing: false, error: e.toString());
      }
      print('[Camera] init ERROR $e\n$st');
    }
  }

  Future<CameraController> _createController(CameraDescription camera) async {
    final controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await controller.initialize();
    return controller;
  }

  // ================= RECORDING =================
  Future<void> startRecording() async {
    if (!state.isReady || state.isRecording || _busy || _disposed) return;

    _busy = true;
    try {
      await state.controller!.startVideoRecording();
      _startTimer();
      if (!_disposed) state = state.copyWith(isRecording: true);
    } catch (e, st) {
      print('[Record] START ERROR $e\n$st');
    } finally {
      _busy = false;
    }
  }

  Future<File?> stopRecording() async {
    if (!state.isRecording || _busy || _disposed || state.controller == null) return null;

    _busy = true;
    File? videoFile;

    try {
      final controller = state.controller!;

      if (controller.value.isRecordingVideo) {
        final XFile file = await controller.stopVideoRecording();
        videoFile = File(file.path);
      }

      _stopTimer();

      if (state.isFlashOn && controller.value.isInitialized) {
        try {
          await controller.setFlashMode(FlashMode.off);
        } catch (_) {}
      }

      if (!_disposed) {
        state = state.copyWith(
          isRecording: false,
          recordingDuration: Duration.zero,
          isFlashOn: false,
        );
      }

      return videoFile;
    } catch (e, st) {
      print('[Record] STOP ERROR $e\n$st');
      return null;
    } finally {
      _busy = false;
    }
  }

  // ================= FLASH =================
  Future<void> toggleFlash() async {
    if (!state.isReady || _busy || _disposed) return;

    _busy = true;
    try {
      final controller = state.controller!;
      final newMode = state.isFlashOn ? FlashMode.off : FlashMode.torch;
      await controller.setFlashMode(newMode);

      if (!_disposed) state = state.copyWith(isFlashOn: !state.isFlashOn);
    } catch (e) {
      print('[Flash] ERROR $e');
    } finally {
      _busy = false;
    }
  }

  // ================= SWITCH CAMERA =================
  Future<void> switchCamera() async {
    if (_disposed || _busy || state.isRecording || _cameras.length < 2) return;

    _busy = true;
    final oldController = state.controller;
    final oldIndex = _cameraIndex;

    try {
      state = state.copyWith(controller: null, isFlashOn: false, zoom: 1.0);
      await Future.delayed(const Duration(milliseconds: 200));
      await oldController?.dispose();

      _cameraIndex = (_cameraIndex + 1) % _cameras.length;
      final controller = await _createController(_cameras[_cameraIndex]);

      if (_disposed) {
        await controller.dispose();
        return;
      }

      state = state.copyWith(controller: controller, isFlashOn: false, zoom: 1.0);
    } catch (e, st) {
      _cameraIndex = oldIndex;
      if (!_disposed) state = state.copyWith(controller: oldController);
      print('[SwitchCamera ERROR] $e\n$st');
    } finally {
      _busy = false;
    }
  }

  // ================= ZOOM =================
  Future<void> setZoom(double value) async {
    if (!state.isReady || _busy || _disposed) return;
    _busy = true;
    try {
      final controller = state.controller!;
      final minZoom = await controller.getMinZoomLevel();
      final maxZoom = await controller.getMaxZoomLevel();
      final newZoom = value.clamp(minZoom, maxZoom);
      await controller.setZoomLevel(newZoom);
      if (!_disposed) state = state.copyWith(zoom: newZoom);
    } catch (e) {
      print('[Zoom] ERROR $e');
    } finally {
      _busy = false;
    }
  }

  // ================= TIMER =================
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_disposed) return;
      state = state.copyWith(
        recordingDuration: state.recordingDuration + const Duration(seconds: 1),
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ================= LIFECYCLE =================
  @override
  void didChangeAppLifecycleState(AppLifecycleState life) async {
    if (_disposed) return;
    if (life == AppLifecycleState.paused || life == AppLifecycleState.inactive) {
      if (state.isRecording) await stopRecording();
      _timer?.cancel();
      try {
        await state.controller?.dispose();
      } catch (_) {}
    } else if (life == AppLifecycleState.resumed) {
      await initCamera();
    }
  }

  void detachPreviewSafely() {
    if (_disposed) return;
    try {
      state = state.copyWith(controller: null);
    } catch (_) {}
  }

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    if (state.controller != null) {
      try {
        state.controller!.dispose();
      } catch (_) {}
    }
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}

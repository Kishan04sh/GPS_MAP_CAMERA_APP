import 'dart:async';
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../modal/video_state.dart';

final videoCameraProvider =
StateNotifierProvider<VideoCameraController, VideoState>(
      (ref) {
    final ctrl = VideoCameraController();
    ref.onDispose(ctrl.disposeCamera);
    return ctrl;
  },
);

class VideoCameraController extends StateNotifier<VideoState>
    with WidgetsBindingObserver {
  VideoCameraController() : super(VideoState.empty) {
    WidgetsBinding.instance.addObserver(this);
  }

  List<CameraDescription> _cameras = [];
  int _index = 0;
  Timer? _timer;

  // ================= INIT =================
  Future<void> initCamera() async {
    if (state.initializing || state.controller != null) return;
    state = state.copyWith(initializing: true);

    try {
      _cameras = await availableCameras();
      _index = _cameras.indexWhere(
            (c) => c.lensDirection == CameraLensDirection.back,
      );
      if (_index < 0) _index = 0;

      final controller = CameraController(
        _cameras[_index],
        ResolutionPreset.high,
        enableAudio: true, // 🔴 VIDEO NEEDS AUDIO
      );

      await controller.initialize();

      state = state.copyWith(
        controller: controller,
        initializing: false,
      );
    } catch (e) {
      debugPrint('[VIDEO][INIT ERROR] $e');
      state = VideoState.empty;
    }
  }

  // ================= RECORD =================
  Future<void> startRecording() async {
    if (!state.isReady || state.isRecording) return;

    await state.controller!.prepareForVideoRecording();
    await state.controller!.startVideoRecording();

    _startTimer();
    state = state.copyWith(isRecording: true);
  }

  Future<File?> stopRecording() async {
    if (!state.isRecording) return null;

    final xFile = await state.controller!.stopVideoRecording();
    _stopTimer();

    state = state.copyWith(
      isRecording: false,
      recordingDuration: Duration.zero,
    );

    return File(xFile.path);
  }

  // ================= TIMER =================
  void _startTimer() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      state = state.copyWith(
        recordingDuration:
        state.recordingDuration + const Duration(seconds: 1),
      );
    });
  }

  void _stopTimer() {
    _timer?.cancel();
    _timer = null;
  }

  // ================= LIFECYCLE =================
  @override
  void didChangeAppLifecycleState(AppLifecycleState life) {
    if (life == AppLifecycleState.paused ||
        life == AppLifecycleState.inactive) {
      disposeCamera();
    }
  }

  // ================= DISPOSE =================
  Future<void> disposeCamera() async {
    _timer?.cancel();
    final old = state.controller;
    state = VideoState.empty;
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

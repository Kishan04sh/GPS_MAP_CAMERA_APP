
import 'dart:async';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../camera/viewmodal/address_controller.dart';
import '../../../camera/viewmodal/location_controller.dart';
import '../../data/camera_datasource.dart';
import '../../data/camera_repository_impl.dart';
import '../../domain/capture_result.dart';
import '../../domain/capture_state.dart';
import '../../domain/camera_repository.dart';
import '../screens/capture_screen.dart';
import '../widgets/capture_orientation_services.dart';

final cameraRepositoryProvider = Provider<CameraRepository>((ref) {
  final ds = CameraDatasource();
  final repo = CameraRepositoryImpl(ds);

  ref.onDispose(() async {
    await repo.dispose();
  });

  return repo;
});

final captureProvider =
NotifierProvider<CaptureViewModel, CaptureState>(CaptureViewModel.new);

class CaptureViewModel extends Notifier<CaptureState> {
  late CameraRepository repo;
  Timer? _timer;
  CaptureOrientation? lastCameraOrientation;


  @override
  CaptureState build() {
    repo = ref.read(cameraRepositoryProvider);
    return CaptureState.initial();
  }

  // ================= INIT =================
  Future<void> initialize() async {
    if (state.ready || state.initializing) return;

    state = state.copyWith(initializing: true, error: null);

    try {
      await repo.initialize();
      final ctrl = repo.controller!;

      state = state.copyWith(
        initializing: false,
        ready: true,
        zoom: 1.0,
        minZoom: await ctrl.getMinZoomLevel(),
        maxZoom: await ctrl.getMaxZoomLevel(),
        flashMode: repo.flashMode,
      );
    } catch (e) {
      state = state.copyWith(initializing: false, error: e.toString());
    }
  }

  // ================= SWITCH CAMERA =================
  Future<void> switchCamera() async {
    if (state.recording) return;

    state = state.copyWith(initializing: true, ready: false);

    try {
      await repo.switchCamera();
      final ctrl = repo.controller!;

      state = state.copyWith(
        initializing: false,
        ready: true,
        zoom: 1.0,
        minZoom: await ctrl.getMinZoomLevel(),
        maxZoom: await ctrl.getMaxZoomLevel(),
        flashMode: repo.flashMode,
      );
    } catch (e) {
      state = state.copyWith(initializing: false, error: e.toString());
    }
  }

  // ================= ZOOM =================
  Future<void> setZoom(double zoom) async {
    if (!state.ready) return;

    final clamped = zoom.clamp(state.minZoom, state.maxZoom);
    await repo.setZoom(clamped);
    state = state.copyWith(zoom: clamped);
  }

  // ================= FLASH =================
  Future<void> cycleFlash() async {
    if (!state.ready) return;
    await repo.cycleFlash();
    state = state.copyWith(flashMode: repo.flashMode);
  }

  // ================= MODE =================
  void setPhotoMode() {
    if (!state.recording) {
      state = state.copyWith(mode: CaptureMode.photo);
    }
  }

  void setVideoMode() {
    if (!state.recording) {
      state = state.copyWith(mode: CaptureMode.video);
    }
  }

  // ================= CAPTURE =================
  // Future<void> onCapturePressed() async {
  //   if (!state.ready) return;
  //
  //   if (state.mode == CaptureMode.photo) {
  //     await _takePhoto();
  //   } else {
  //     state.recording ? await stopRecording() : await startRecording();
  //   }
  // }

  Future<void> onCapturePressed(DeviceViewSide side) async {
    if (!state.ready) return;

    if (state.mode == CaptureMode.photo) {
      await _takePhoto(side: side);
    } else {
      state.recording ? await stopRecording() : await startRecording();
    }
  }

  Future<void> _takePhoto({required DeviceViewSide side}) async {
    try {
      state = state.copyWith(processing: true);
      debugPrint("CAPTURE_DEBUG: Starting photo capture...");

      // 1️⃣ Capture raw photo + repo orientation
      final rawPath = await repo.takePhoto();
      debugPrint("CAPTURE_DEBUG: Raw photo path: $rawPath, CamOrientation:");

      // 2️⃣ Map UI side to CaptureOrientation
      CaptureOrientation sideOrientation;
      switch (side) {
        case DeviceViewSide.portrait:
          sideOrientation = CaptureOrientation.portraitUp;
          break;
        case DeviceViewSide.landscapeLeft:
          sideOrientation = CaptureOrientation.landscapeLeft;
          break;
        case DeviceViewSide.landscapeRight:
          sideOrientation = CaptureOrientation.landscapeRight;
          break;
        case DeviceViewSide.upsideDown:
          sideOrientation = CaptureOrientation.portraitDown;
          break;
      }

      final lastCameraOrientation = sideOrientation;
      debugPrint("CAPTURE_DEBUG: Using orientation: $lastCameraOrientation");

      // 3️⃣ Get location & address
      final pos = ref.read(locationProvider);
      final addr = ref.read(addressProvider) ?? 'Address unavailable';
      if (pos == null) {
        state = state.copyWith(processing: false, error: "Location unavailable");
        return;
      }

      // 4️⃣ Stamp image
      final stamped = await CaptureOrientationServices.stamp(
        original: File(rawPath!),
        address: addr,
        lat: pos.latitude,
        lng: pos.longitude,
        time: DateTime.now(),
        orientation: lastCameraOrientation,
      );

      debugPrint("CAPTURE_DEBUG: Stamped image saved at: ${stamped.path}");

      // 5️⃣ Update state
      state = state.copyWith(
        processing: false,
        lastFile: stamped.path,
        result: PhotoCapture(
          file: stamped,
          lat: pos.latitude,
          lng: pos.longitude,
          address: addr,
        ),
      );

      debugPrint("CAPTURE_DEBUG: CaptureState updated with result.");
    } catch (e, st) {
      debugPrint("CAPTURE_ERROR: $e\n$st");
      state = state.copyWith(processing: false, error: e.toString());
    }
  }


  /*Future<void> _takePhoto() async {
    try {
      state = state.copyWith(initializing: true);

      final path = await repo.takePhoto();

      print("image path $path");

      state = state.copyWith(
        initializing: false,
        lastFile: path,
        flashMode: repo.flashMode, // 🔥 Sync UI icon
      );
    } catch (e) {
      state = state.copyWith(initializing: false, error: e.toString());
    }
  }*/

  // Future<void> _takePhoto() async {
  //   try {
  //     state = state.copyWith(processing: true);
  //
  //     /// 1. RAW CAPTURE
  //     final rawPath = await repo.takePhoto();
  //
  //     /// 2. LOCATION
  //     final pos = ref.read(locationProvider);
  //     final addr = ref.read(addressProvider) ?? '';
  //
  //     if (pos == null) {
  //       state = state.copyWith(processing: false, error: "Location unavailable");
  //       return;
  //     }
  //
  //     /// 3. STAMP IMAGE
  //     final stamped = await ImageStampUtil.stamp(
  //       original: File(rawPath!),
  //       address: addr,
  //       lat: pos.latitude,
  //       lng: pos.longitude,
  //       time: DateTime.now(),
  //     );
  //
  //     /// 4. EMIT EVENT (🔥 MAIN PART)
  //     state = state.copyWith(
  //       processing: false,
  //       lastFile: stamped.path,
  //       result: PhotoCapture(
  //         file: stamped,
  //         lat: pos.latitude,
  //         lng: pos.longitude,
  //         address: addr,
  //       ),
  //     );
  //
  //   } catch (e) {
  //     state = state.copyWith(processing: false, error: e.toString());
  //   }
  // }


  // ================= VIDEO =================
  Future<void> startRecording() async {
    if (!state.ready || state.recording) return;

    try {
      await repo.startRecording();
      state = state.copyWith(recording: true, recordingDuration: Duration.zero);
      _startTimer();
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  // Future<void> stopRecording() async {
  //   if (!state.recording) return;
  //
  //   try {
  //     final path = await repo.stopRecording();
  //     _stopTimer();
  //     print("video path $path");
  //
  //     state = state.copyWith(
  //       recording: false,
  //       lastFile: path,
  //       recordingDuration: Duration.zero,
  //       flashMode: repo.flashMode, // 🔥 VERY IMPORTANT
  //     );
  //   } catch (e) {
  //     state = state.copyWith(recording: false, error: e.toString());
  //   }
  // }


  Future<void> stopRecording() async {
    if (!state.recording) return;

    try {
      final path = await repo.stopRecording();
      _stopTimer();

      if (path == null) {
        state = state.copyWith(recording: false);
        return;
      }

      final rawFile = File(path);
      final pos = ref.read(locationProvider);
      final addr = ref.read(addressProvider) ?? '';

      if (pos == null) {
        state = state.copyWith(recording: false, error: "Location unavailable");
        return;
      }

      /// loader start
      state = state.copyWith(recording: false, processing: true);

      final finalVideo = await VideoProcessingService.processVideo(
        input: rawFile,
        lat: pos.latitude,
        lng: pos.longitude,
        address: addr,
      );

      /// 🔥 ONLY EMIT RESULT (NO UPLOAD HERE)
      state = state.copyWith(
        processing: false,
        lastFile: finalVideo.path,
        recordingDuration: Duration.zero,
        result: VideoCapture(
          file: finalVideo,
          lat: pos.latitude,
          lng: pos.longitude,
          address: addr,
        ),
      );

    } catch (e) {
      state = state.copyWith(recording: false, processing: false, error: e.toString());
    }
  }



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

  void consumeResult() {
    state = state.copyWith(result: null);
  }


  // ================= PREVIEW =================
  Future<void> onPause() async => repo.pausePreview();
  Future<void> onResume() async => repo.resumePreview();

  // ================= DISPOSE =================
  Future<void> disposeCamera() async {
    _stopTimer();
    await repo.dispose();
    state = CaptureState.initial();
  }
}

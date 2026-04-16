
import '../data/camera_datasource.dart';
import '../presentation/widgets/capture_orientation_services.dart';
import 'capture_result.dart';

enum CaptureStatus {
  idle,
  initializing,
  ready,
  capturingPhoto,
  recordingVideo,
  switchingCamera,
  error,
  disposed,
}

enum CaptureMode { photo, video }


class CaptureState {
  final bool initializing;
  final bool ready;
  final bool recording;
  final bool processing; // 🔥 unified
  final double zoom;
  final double minZoom;
  final double maxZoom;
  final String? lastFile;
  final String? error;
  final CaptureMode mode;
  final AppFlashMode flashMode;
  final Duration recordingDuration;
  final CaptureResult? result; // 👈 ADD THIS
  final CaptureOrientation? lastCameraOrientation; // add this line

  CaptureState({
    required this.initializing,
    required this.ready,
    required this.recording,
    required this.processing,
    required this.zoom,
    required this.minZoom,
    required this.maxZoom,
    required this.mode,
    required this.flashMode,
    required this.recordingDuration,
    this.lastFile,
    this.error,
    this.result, // 👈 ADD
    this.lastCameraOrientation, // add this
  });

  factory CaptureState.initial() => CaptureState(
    initializing: false,
    ready: false,
    recording: false,
    processing: false,
    zoom: 1,
    minZoom: 1,
    maxZoom: 1,
    mode: CaptureMode.photo,
    flashMode: AppFlashMode.off,
    recordingDuration: Duration.zero,
    result: null, // 👈 ADD
    lastCameraOrientation: null, // add this
  );

  CaptureState copyWith({
    bool? initializing,
    bool? ready,
    bool? recording,
    bool? processing,
    double? zoom,
    double? minZoom,
    double? maxZoom,
    String? lastFile,
    String? error,
    CaptureMode? mode,
    AppFlashMode? flashMode,
    Duration? recordingDuration,
    CaptureResult? result, // 👈 ADD
    CaptureOrientation? lastCameraOrientation, // add this
  }) {
    return CaptureState(
      initializing: initializing ?? this.initializing,
      ready: ready ?? this.ready,
      recording: recording ?? this.recording,
      processing: processing ?? this.processing,
      zoom: zoom ?? this.zoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
      lastFile: lastFile ?? this.lastFile,
      error: error,
      mode: mode ?? this.mode,
      flashMode: flashMode ?? this.flashMode,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      result: result, // 👈 IMPORTANT (no ?? this.result)
      lastCameraOrientation: lastCameraOrientation ?? this.lastCameraOrientation, // add this
    );
  }
}

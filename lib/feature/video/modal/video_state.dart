// import 'package:camera/camera.dart';
//
// /// Complete immutable state for video camera
// class VideoState {
//   final CameraController? controller;
//   final bool isRecording;
//   final bool initializing;
//   final bool isFlashOn;
//   final Duration recordingDuration;
//   final String? error;
//   final double zoom;
//
//
//   const VideoState({
//     this.controller,
//     this.isRecording = false,
//     this.initializing = false,
//     this.isFlashOn = false,
//     this.recordingDuration = Duration.zero,
//     this.error,
//     this.zoom = 1.0,
//   });
//
//   /// Camera usable only when fully initialized
//   bool get isReady =>
//       controller != null &&
//           controller!.value.isInitialized &&
//           !initializing;
//
//   VideoState copyWith({
//     CameraController? controller,
//     bool? isRecording,
//     bool? initializing,
//     bool? isFlashOn,
//     Duration? recordingDuration,
//     String? error,
//     double? zoom,
//   }) {
//     return VideoState(
//       controller: controller ?? this.controller,
//       isRecording: isRecording ?? this.isRecording,
//       initializing: initializing ?? this.initializing,
//       isFlashOn: isFlashOn ?? this.isFlashOn,
//       recordingDuration: recordingDuration ?? this.recordingDuration,
//       error: error,
//       zoom: zoom ?? this.zoom,
//     );
//   }
//
//   static const empty = VideoState();
// }


import 'package:camera/camera.dart';

/// Complete immutable state for video camera
class VideoState {
  final CameraController? controller;
  final bool isRecording;
  final bool initializing;
  final bool isFlashOn;
  final Duration recordingDuration;
  final String? error;
  final double zoom;

  const VideoState({
    this.controller,
    this.isRecording = false,
    this.initializing = false,
    this.isFlashOn = false,
    this.recordingDuration = Duration.zero,
    this.error,
    this.zoom = 1.0,
  });

  /// Camera usable only when fully initialized
  bool get isReady =>
      controller != null &&
          controller!.value.isInitialized &&
          !initializing;

  VideoState copyWith({
    CameraController? controller,
    bool? isRecording,
    bool? initializing,
    bool? isFlashOn,
    Duration? recordingDuration,
    String? error,
    double? zoom,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      isRecording: isRecording ?? this.isRecording,
      initializing: initializing ?? this.initializing,
      isFlashOn: isFlashOn ?? this.isFlashOn,
      recordingDuration: recordingDuration ?? this.recordingDuration,
      error: error ?? this.error,  // Keep previous error if not passed
      zoom: zoom ?? this.zoom,
    );
  }

  static const empty = VideoState();
}

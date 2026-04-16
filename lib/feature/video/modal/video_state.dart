import 'package:camera/camera.dart';

class VideoState {
  final CameraController? controller;
  final bool initializing;
  final bool isRecording;
  final bool disposed;
  final Duration recordingDuration;

  const VideoState({
    this.controller,
    this.initializing = false,
    this.isRecording = false,
    this.disposed = false,
    this.recordingDuration = Duration.zero,
  });

  bool get isReady =>
      controller != null && controller!.value.isInitialized;

  VideoState copyWith({
    CameraController? controller,
    bool? initializing,
    bool? isRecording,
    bool? disposed,
    Duration? recordingDuration,
  }) {
    return VideoState(
      controller: controller ?? this.controller,
      initializing: initializing ?? this.initializing,
      isRecording: isRecording ?? this.isRecording,
      disposed: disposed ?? this.disposed,
      recordingDuration: recordingDuration ?? this.recordingDuration,
    );
  }

  static const empty = VideoState();
}

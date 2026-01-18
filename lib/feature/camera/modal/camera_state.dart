
import 'package:camera/camera.dart';

class CameraState {
  final CameraController? controller;
  final bool initializing;
  final bool disposed;
  final bool isRecording;
  final FlashMode flashMode;
  final double zoom;
  final double minZoom;
  final double maxZoom;

  const CameraState({
    this.controller,
    this.initializing = false,
    this.disposed = false,
    this.isRecording = false,
    this.flashMode = FlashMode.off,
    this.zoom = 0.6,
    this.minZoom = 1.0,
    this.maxZoom = 1.0,
  });

  bool get isReady =>
      controller != null && controller!.value.isInitialized;

  CameraState copyWith({
    CameraController? controller,
    bool? initializing,
    bool? disposed,
    bool? isRecording,
    FlashMode? flashMode,
    double? zoom,
    double? minZoom,
    double? maxZoom,
  }) {
    return CameraState(
      controller: controller ?? this.controller,
      initializing: initializing ?? this.initializing,
      disposed: disposed ?? this.disposed,
      isRecording: isRecording ?? this.isRecording,
      flashMode: flashMode ?? this.flashMode,
      zoom: zoom ?? this.zoom,
      minZoom: minZoom ?? this.minZoom,
      maxZoom: maxZoom ?? this.maxZoom,
    );
  }

  static const empty = CameraState();
}


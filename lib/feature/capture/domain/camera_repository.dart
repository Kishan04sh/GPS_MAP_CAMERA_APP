
import 'package:camera/camera.dart';
import '../data/camera_datasource.dart';

abstract class CameraRepository {
  Future<void> initialize();
  Future<void> dispose();
  Future<void> pausePreview();
  Future<void> resumePreview();
  Future<void> switchCamera();
  Future<void> setZoom(double zoom);

  /// Flash cycle (OFF/AUTO/ON or TORCH in video)
  Future<void> cycleFlash();

  Future<String?> takePhoto();
  Future<void> startRecording();
  Future<String?> stopRecording();

  bool get isRecording;
  bool get isReady;
  CameraController? get controller;
  AppFlashMode get flashMode;
}

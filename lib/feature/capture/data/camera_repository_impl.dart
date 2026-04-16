

import 'package:camera/camera.dart';
import '../domain/camera_repository.dart';
import 'camera_datasource.dart';

class CameraRepositoryImpl implements CameraRepository {
  final CameraDatasource _ds;
  CameraRepositoryImpl(this._ds);

  @override
  bool get isRecording => _ds.isRecording;

  @override
  bool get isReady => _ds.isInitialized;

  @override
  CameraController? get controller => _ds.controller;

  @override
  AppFlashMode get flashMode => _ds.flashMode;

  @override
  Future<void> initialize() => _ds.initialize();

  @override
  Future<void> dispose() => _ds.dispose();

  @override
  Future<void> pausePreview() => _ds.pausePreview();

  @override
  Future<void> resumePreview() => _ds.resumePreview();

  @override
  Future<void> switchCamera() => _ds.switchCamera();

  @override
  Future<void> setZoom(double zoom) => _ds.setZoom(zoom);

  @override
  Future<void> cycleFlash() => _ds.cycleFlashMode();

  @override
  Future<String?> takePhoto() async => (await _ds.takePhoto())?.path;

  @override
  Future<void> startRecording() => _ds.startRecording();

  @override
  Future<String?> stopRecording() async => (await _ds.stopRecording())?.path;
}

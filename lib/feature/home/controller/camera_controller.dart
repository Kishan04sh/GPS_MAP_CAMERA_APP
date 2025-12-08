// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:path_provider/path_provider.dart';
//
// class CameraControllerNotifier extends StateNotifier<CameraController?> {
//   CameraControllerNotifier() : super(null);
//
//   Future<void> initCamera(List<CameraDescription> cams) async {
//     final controller = CameraController(
//       cams.first,
//       ResolutionPreset.high,
//       enableAudio: false,
//     );
//
//     await controller.initialize();
//     state = controller;
//   }
//
//   Future<File?> capture() async {
//     if (state == null || !state!.value.isInitialized) return null;
//
//     final pic = await state!.takePicture();
//
//     final dir = await getApplicationDocumentsDirectory();
//     final saved = File('${dir.path}/${DateTime.now().millisecondsSinceEpoch}.jpg');
//
//     return File(pic.path).copy(saved.path);
//   }
// }
//
// final cameraProvider =
// StateNotifierProvider<CameraControllerNotifier, CameraController?>(
//       (ref) => CameraControllerNotifier(),
// );


import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';

final cameraProvider = StateNotifierProvider<CameraControllerNotifier, CameraController?>(
      (ref) => CameraControllerNotifier(),
);

class CameraControllerNotifier extends StateNotifier<CameraController?> {
  CameraControllerNotifier(): super(null);

  Future<void> initCamera(List<CameraDescription> cameras) async {
    if (cameras.isEmpty) return;
    final back = cameras.firstWhere((c) => c.lensDirection == CameraLensDirection.back, orElse: () => cameras.first);
    final controller = CameraController(back, ResolutionPreset.high, enableAudio: false);
    try {
      await controller.initialize();
      state = controller;
    } catch (e) {
      // propagate or log
      rethrow;
    }
  }

  Future<File?> captureAndSave() async {
    final c = state;
    if (c == null || !c.value.isInitialized) return null;

    try {
      final xfile = await c.takePicture();
      final bytes = await xfile.readAsBytes();
      final dir = await getApplicationDocumentsDirectory();
      final saveDir = Directory('${dir.path}/geoproof_images');
      if (!await saveDir.exists()) await saveDir.create(recursive: true);
      final file = File('${saveDir.path}/photo_${DateTime.now().millisecondsSinceEpoch}.jpg');
      await file.writeAsBytes(bytes);
      return file;
    } catch (e) {
      // handle capture error
      rethrow;
    }
  }

  @override
  void dispose() {
    state?.dispose();
    super.dispose();
  }
}

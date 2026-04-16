import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/capture_viewmodel.dart';

class CapturePreview extends ConsumerWidget {
  const CapturePreview({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final repo = ref.watch(cameraRepositoryProvider);

    final controller = repo.controller;

    if (!state.ready || controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    return RepaintBoundary(
      child: CameraPreview(controller),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodal/camera_controller.dart';

class CameraPinchWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const CameraPinchWrapper({super.key, required this.child});

  @override
  ConsumerState<CameraPinchWrapper> createState() => _CameraPinchWrapperState();
}

class _CameraPinchWrapperState extends ConsumerState<CameraPinchWrapper> {
  double _baseZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final cam = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    return GestureDetector(
      onScaleStart: (_) {
        _baseZoom = cam.zoom;
      },
      onScaleUpdate: (details) {
        if (!cam.isReady) return;

        final newZoom = (_baseZoom * details.scale)
            .clamp(cam.minZoom, cam.maxZoom);

        notifier.setZoom(newZoom);
      },
      child: widget.child,
    );
  }
}

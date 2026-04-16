
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../viewmodal/video_controller.dart';

class VideoPinchWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const VideoPinchWrapper({super.key, required this.child});

  @override
  ConsumerState<VideoPinchWrapper> createState() => _VideoPinchWrapperState();
}

class _VideoPinchWrapperState extends ConsumerState<VideoPinchWrapper> {
  double _baseZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final cam = ref.watch(videoCameraProvider);
    final notifier = ref.read(videoCameraProvider.notifier);

    return GestureDetector(
      onScaleStart: (_) {
        _baseZoom = cam.zoom;
      },
      onScaleUpdate: (details) {
        if (!cam.isReady) return;
        final newZoom = _baseZoom * details.scale;
        notifier.setZoom(newZoom);
      },
      child: widget.child,
    );
  }
}

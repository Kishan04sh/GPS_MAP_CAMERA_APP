import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodel/capture_viewmodel.dart';

class ZoomHandlerWrapper extends ConsumerStatefulWidget {
  final Widget child;
  const ZoomHandlerWrapper({super.key, required this.child});

  @override
  ConsumerState<ZoomHandlerWrapper> createState() => _ZoomHandlerWrapperState();
}

class _ZoomHandlerWrapperState extends ConsumerState<ZoomHandlerWrapper> {
  double _baseZoom = 1.0;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(captureProvider);
    final notifier = ref.read(captureProvider.notifier);

    return GestureDetector(
      onScaleStart: (_) {
        _baseZoom = state.zoom;
      },
      onScaleUpdate: (details) {
        if (!state.ready) return;

        final newZoom = (_baseZoom * details.scale)
            .clamp(state.minZoom, state.maxZoom);

        notifier.setZoom(newZoom);
      },
      child: widget.child,
    );
  }
}

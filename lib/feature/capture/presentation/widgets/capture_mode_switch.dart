

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/capture_state.dart';
import '../viewmodel/capture_viewmodel.dart';

class CaptureModeSwitch extends ConsumerWidget {
  const CaptureModeSwitch({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final vm = ref.read(captureProvider.notifier);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _btn("PHOTO", state.mode == CaptureMode.photo, vm.setPhotoMode),
        const SizedBox(width: 20),
        _btn("VIDEO", state.mode == CaptureMode.video, vm.setVideoMode),
      ],
    );
  }

  Widget _btn(String text, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: active ? Colors.white : Colors.white24,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: active ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

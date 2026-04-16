
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/camera_datasource.dart';
import '../viewmodel/capture_viewmodel.dart';

/// Production-ready Capture AppBar
class CaptureAppBar extends ConsumerWidget {
  const CaptureAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(captureProvider);
    final vm = ref.read(captureProvider.notifier);

    final isCameraReady = state.ready && !state.recording && !state.initializing;

    return SafeArea(
      bottom: false,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            /// BACK BUTTON
            // _buildCircleIconButton(
            //   icon: Icons.arrow_back_ios_new,
            //   onTap: () => Navigator.pop(context),
            //   isEnabled: true,
            // ),
            const SizedBox(width: 8),
            const Spacer(),

            /// FLASH BUTTON
            _buildCircleIconButton(
              icon: _getFlashIcon(state.flashMode),
              onTap: isCameraReady ? vm.cycleFlash : null,
              isEnabled: isCameraReady,
            ),

            const SizedBox(width: 8),

            /// SWITCH CAMERA BUTTON
            _buildCircleIconButton(
              icon: Icons.cameraswitch,
              onTap: isCameraReady ? vm.switchCamera : null,
              isEnabled: isCameraReady,
            ),
          ],
        ),
      ),
    );
  }

  /// Circle-style Icon Button
  Widget _buildCircleIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: Material(
        type: MaterialType.transparency,
        shape: const CircleBorder(),
        child: InkWell(
          onTap: isEnabled ? onTap : null,
          borderRadius: BorderRadius.circular(50),
          splashColor: Colors.white24,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(icon, color: Colors.white, size: 24),
          ),
        ),
      ),
    );
  }

  /// Map AppFlashMode → Icon
  IconData _getFlashIcon(AppFlashMode mode) {
    switch (mode) {
      case AppFlashMode.off:
        return Icons.flash_off;
      case AppFlashMode.auto:
        return Icons.flash_auto;
      case AppFlashMode.on:
        return Icons.flash_on;
      case AppFlashMode.torch:
        return Icons.highlight; // Torch icon for video
    }
  }
}

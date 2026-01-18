
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../viewmodal/camera_controller.dart';

class CameraAppBar extends ConsumerWidget {
  const CameraAppBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cam = ref.watch(cameraProvider);
    final notifier = ref.read(cameraProvider.notifier);

    final isCameraReady = cam.controller != null && cam.controller!.value.isInitialized;

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
            _buildCircleIconButton(
              icon: Icons.arrow_back_ios_new,
              onTap: () => Navigator.pop(context),
              isEnabled: true,
            ),

            const Spacer(),

            /// FLASH BUTTON
            _buildCircleIconButton(
              icon: _getFlashIcon(cam.flashMode),
              onTap: isCameraReady ? notifier.toggleFlash : null,
              isEnabled: isCameraReady,
            ),

            const SizedBox(width: 8),

            /// SWITCH CAMERA BUTTON
            _buildCircleIconButton(
              icon: Icons.cameraswitch,
              onTap: isCameraReady ? notifier.switchCamera : null,
              isEnabled: isCameraReady,
            ),
          ],
        ),
      ),
    );
  }

  /// Circle style icon button with ripple & disabled state
  Widget _buildCircleIconButton({
    required IconData icon,
    VoidCallback? onTap,
    bool isEnabled = true,
  }) {
    return Opacity(
      opacity: isEnabled ? 1.0 : 0.45,
      child: Material(
        type: MaterialType.transparency, // important
        color: Colors.black.withOpacity(0.45),
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

  /// Map FlashMode to icon
  static IconData _getFlashIcon(FlashMode mode) {
    switch (mode) {
      case FlashMode.off:
        return Icons.flash_off;
      case FlashMode.auto:
        return Icons.flash_auto;
      case FlashMode.always:
      case FlashMode.torch:
        return Icons.flash_on;
      default:
        return Icons.flash_off;
    }
  }
}

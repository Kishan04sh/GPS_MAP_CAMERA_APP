import 'package:flutter/material.dart';

class VideoTopBar extends StatelessWidget {
  final VoidCallback onBack;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onToggleFlash;
  final bool isFlashOn;

  const VideoTopBar({
    super.key,
    required this.onBack,
    this.onSwitchCamera,
    this.onToggleFlash,
    this.isFlashOn = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          // BACK
          _circleButton(icon: Icons.arrow_back_ios_new, onTap: onBack),

          Row(
            children: [
              // FLASH
              _circleButton(
                icon: isFlashOn ? Icons.flash_on : Icons.flash_off,
                onTap: onToggleFlash,
              ),

              const SizedBox(width: 8),

              // SWITCH CAMERA
              //_circleButton(icon: Icons.cameraswitch, onTap: onSwitchCamera),
            ],
          ),
        ],
      ),
    );
  }

  Widget _circleButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 46,
        height: 46,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.5),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }
}

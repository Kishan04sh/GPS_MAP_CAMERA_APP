
import 'package:flutter/material.dart';

class CameraControlBar extends StatelessWidget {
  final bool canCapture;
  final bool isCapturing;
  final VoidCallback? onCapture;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onVideo;

  const CameraControlBar({
    super.key,
    required this.canCapture,
    required this.isCapturing,
    this.onCapture,
    this.onSwitchCamera,
    this.onVideo,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.transparent,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          /// LEFT: SWITCH CAMERA
          _buildCircleButton(
            icon: Icons.cameraswitch,
            onTap: onSwitchCamera,
          ),

          /// CENTER: CAPTURE BUTTON
          Expanded(
            child: Center(
              child: Opacity(
                opacity: canCapture ? 1.0 : 0.45,
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: canCapture ? onCapture : null,
                  child: Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        colors: [Color(0xFF42A5F5), Color(0xFF1976D2)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      border: Border.all(color: Colors.white.withOpacity(0.3),width: 4),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.35),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    alignment: Alignment.center,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 150),
                      child: isCapturing
                          ? const SizedBox(
                        key: ValueKey('loader'),
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                          : const Icon(
                        Icons.camera,
                        key: ValueKey('icon'),
                        size: 36,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),

          /// RIGHT: VIDEO BUTTON
          _buildCircleButton(
            icon: Icons.videocam,
            onTap: onVideo,
          ),
        ],
      ),
    );
  }

  /// Reusable circular button for switch/video
  Widget _buildCircleButton({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.45),
          border: Border.all(color: Colors.white.withOpacity(0.25)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Icon(icon, color: Colors.white, size: 26),
      ),
    );
  }
}


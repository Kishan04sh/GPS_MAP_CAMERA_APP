
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';

class GpsCameraLoadingOverlay extends StatelessWidget {
  const GpsCameraLoadingOverlay({super.key});

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width * 0.75;

    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          color: Colors.black.withOpacity(0.5),
          child: Center(
            child: Container(
              width: width,
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.75),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.white.withOpacity(0.15),
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.6),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Circular loader with subtle animation
                  SizedBox(
                    height: 56,
                    width: 56,
                    child: CircularProgressIndicator(
                      color: AppColors.primary,
                      strokeWidth: 3.5,
                    ),
                  ),
                  SizedBox(height: 20),

                  // Main loading text
                  Text(
                    'Initializing GPS & Camera…',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.3,
                    ),
                  ),
                  SizedBox(height: 8),

                  // Secondary info text
                  Text(
                    'Please wait while we acquire your location.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

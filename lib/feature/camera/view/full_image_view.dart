import 'dart:io';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';
import 'package:gps_map_camera/core/widgets/app_snackbar.dart';
import '../../../core/widgets/app_animated_loader.dart';

class FullImageView extends StatelessWidget {
  final File file;
  final Position? position;

  const FullImageView({super.key, required this.file ,this.position,});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            // Fullscreen zoomable image
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.file(file, fit: BoxFit.contain),
              ),
            ),

            // Top buttons
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back_ios_new_rounded,
                    onTap: () => Navigator.pop(context),
                  ),
                  _circleButton(
                    icon: Icons.share_outlined,
                    onTap: () => _shareImage(context),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }


  /// **************************************************************************************

  void _shareImage(BuildContext context) async {
    try {
      if (position == null) {
        AppSnackbar.show(
          context,
          message: "No image or location available to share.",
          type: SnackbarType.error,
        );
        return;
      }

      AppAnimatedLoader.show(context, message: "Preparing your location image...");

      final latLong = "${position!.latitude},${position!.longitude}";
      final tempDir = await getTemporaryDirectory();
      final tempFile = await file.copy('${tempDir.path}/${file.uri.pathSegments.last}');
      final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latLong';

      // small delay for smooth UX
      await Future.delayed(const Duration(milliseconds: 300));

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Location proof\n$mapUrl',
      );

      AppAnimatedLoader.hide(context);
    } catch (e, stack) {
      AppAnimatedLoader.hide(context);
      print("Failed to share image: $e");
      print(stack);
      AppSnackbar.show(
        context,
        message: "Failed to share image: $e",
        type: SnackbarType.error,
      );
    }
  }

/// *************************************************************************************

  Widget _circleButton({required IconData icon, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.primary,
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }
}




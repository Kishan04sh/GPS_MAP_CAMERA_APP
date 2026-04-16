
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';
import 'package:gps_map_camera/core/widgets/app_snackbar.dart';
import '../../../core/ads/ad_helper.dart';
import '../../../core/utils/media_saver_file.dart';
import '../../../core/widgets/app_animated_loader.dart';


class FullImageView extends ConsumerStatefulWidget {
  final File file;
  final Position? position;
  final String? address;

  const FullImageView({
    super.key,
    required this.file,
    this.position,
    this.address
  });

  @override ConsumerState<FullImageView> createState() => _FullImageViewState();
}

class _FullImageViewState extends ConsumerState<FullImageView> {
  // bool _uploaded = false;

  @override
  void initState() {
    super.initState();
    // /// Auto upload AFTER screen is rendered
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _autoUploadImage();
    // });
  }

  /// ==========================================================
  /// AUTO IMAGE UPLOAD
  /// ==========================================================
  // Future<void> _autoUploadImage() async {
  //   if (_uploaded || widget.position == null) return;
  //   _uploaded = true;
  //
  //   try {
  //     AppAnimatedLoader.show(
  //       context,
  //       message: "Uploading image...",
  //     );
  //
  //     await ref.read(galleryViewModelProvider.notifier).uploadMedia(
  //       context,
  //       file: widget.file,
  //       latitude: widget.position!.latitude.toString(),
  //       longitude: widget.position!.longitude.toString(),
  //       location: widget.address ?? "NA",
  //       type: MediaType.image, // ✅ IMPORTANT
  //     );
  //   } catch (e, st) {
  //     debugPrint('Auto upload failed: $e');
  //     debugPrint(st.toString());
  //     AppSnackbar.show(
  //       context,
  //       message: 'Image upload failed',
  //       type: SnackbarType.error,
  //     );
  //   } finally {
  //     if (mounted) {
  //       AppAnimatedLoader.hide(context);
  //     }
  //   }
  // }

  /// ==========================================================
  /// UI
  /// ==========================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// Fullscreen zoomable image
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.file(
                  widget.file,
                  fit: BoxFit.contain,
                ),
              ),
            ),

            /// Top buttons
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

                  // _circleButton(
                  //   icon: Icons.share_outlined,
                  //   onTap: () => _shareImage(context),
                  // ),

                  Row(
                    children: [
                      _circleButton(
                        icon: Icons.download_rounded, // ⬇️ DOWNLOAD
                        // onTap: (){
                        //   SafeDownloader.saveLocalFile(
                        //     context: context,
                        //     file: widget.file,
                        //     type: SaveMediaType.image,
                        //   );
                        // },
                        onTap: () async {
                          await ref.read(adHelperProvider).runWithAd(() async {
                            if (!context.mounted) return;
                            SafeDownloader.saveLocalFile(
                              context: context,
                              file: widget.file,
                              type: SaveMediaType.image,
                            );
                          });
                        },
                      ),

                      const SizedBox(width: 12),
                      _circleButton(
                        icon: Icons.share_outlined, // 🔗 SHARE
                        // onTap: () => _shareImage(context),
                        onTap: () async {
                          await ref.read(adHelperProvider).runWithAd(() async {
                            if (!context.mounted) return;
                            await _shareImage(context);
                          });
                        },
                      ),

                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ==========================================================
  /// SHARE IMAGE WITH LOCATION
  /// ==========================================================
  Future<void> _shareImage(BuildContext context) async {
    try {
      if (widget.position == null) {
        AppSnackbar.show(
          context,
          message: "No location available to share.",
          type: SnackbarType.error,
        );
        return;
      }

      AppAnimatedLoader.show(
        context,
        message: "Preparing your location image...",
      );

      final latLong = "${widget.position!.latitude},${widget.position!.longitude}";
      final tempDir = await getTemporaryDirectory();
      final tempFile = await widget.file.copy('${tempDir.path}/${widget.file.uri.pathSegments.last}');
      final mapUrl = 'https://www.google.com/maps/search/?api=1&query=$latLong';

      await Future.delayed(const Duration(milliseconds: 300));

      await Share.shareXFiles(
        [XFile(tempFile.path)],
        text: 'Location proof\n$mapUrl',
      );
    } catch (e, st) {
      debugPrint("Failed to share image: $e");
      debugPrint(st.toString());

      AppSnackbar.show(
        context,
        message: "Failed to share image",
        type: SnackbarType.error,
      );
    } finally {
      if (mounted) {
        AppAnimatedLoader.hide(context);
      }
    }
  }

  /// ==========================================================
  /// CIRCLE BUTTON
  /// ==========================================================
  Widget _circleButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
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
        child: Icon(
          icon,
          color: Colors.white,
          size: 22,
        ),
      ),
    );
  }
}

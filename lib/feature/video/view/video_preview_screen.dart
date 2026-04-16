
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_saver_file.dart';
import '../viewmodal/video_preview_controller.dart';

class VideoPreviewScreen extends StatefulWidget {
  final File video;

  const VideoPreviewScreen({super.key, required this.video});

  @override
  State<VideoPreviewScreen> createState() => _VideoPreviewScreenState();
}

class _VideoPreviewScreenState extends State<VideoPreviewScreen> {
  late VideoPreviewController controller;

  @override
  void initState() {
    super.initState();
    controller = VideoPreviewController(widget.video);
    WidgetsBinding.instance.addObserver(controller);
    controller.addListener(() {
      if (mounted) setState(() {});
    });
  }


  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(controller);
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: controller.isReady
            ? _videoView()
            : const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }

 /// *****************************************************************

  Widget _videoView() {
    return Stack(
      children: [
        /// VIDEO PLAYER
        Center(
          child: Chewie(controller: controller.chewieController!),
        ),

        /// TOP BAR
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
              //   onTap: () => controller.share(context),
              // ),

              Row(
                children: [
                  _circleButton(
                    icon: Icons.download_rounded, // ⬇️ DOWNLOAD
                    onTap: (){
                      SafeDownloader.saveLocalFile(
                        context: context,
                        file: widget.video,
                        type: SaveMediaType.video,
                      );
                    },
                  ),

                  const SizedBox(width: 12),

                  _circleButton(
                    icon: Icons.share_outlined, // 🔗 SHARE
                    onTap: () => controller.share(context),
                  ),

                ],
              ),


            ],
          ),
        ),
      ],
    );
  }


  /// *******************************************************************************

  Widget _circleButton({required IconData icon, required VoidCallback onTap}) {
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


  /// ******************************************************************************
}

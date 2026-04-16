
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_animated_loader.dart';
import '../../../core/widgets/app_snackbar.dart';

class VideoPreviewController extends ChangeNotifier with WidgetsBindingObserver {
  final File videoFile;

  VideoPlayerController? videoPlayerController;
  ChewieController? chewieController;

  bool isReady = false;
  bool _isSharing = false;
  bool _disposed = false;

  VideoPreviewController(this.videoFile) {
    _init();
  }

  /// Initialize video & Chewie safely
  Future<void> _init() async {
    try {
      videoPlayerController = VideoPlayerController.file(videoFile);
      await videoPlayerController!.initialize();
      chewieController = ChewieController(
        videoPlayerController: videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: AppColors.primary,
          bufferedColor: Colors.grey,
          handleColor: AppColors.white,
          backgroundColor: Colors.black26,
        ),
      );

      isReady = true;
      notifyListeners();
    } catch (e) {
      debugPrint('[VideoPreviewController] Initialization failed: $e');
      isReady = false;
      notifyListeners();
    }
  }

  ///************ Share video safely ******************************************
  Future<void> share(BuildContext context) async {
    if (_isSharing) return;
    _isSharing = true;

    if (!videoFile.existsSync()) {
      AppSnackbar.show(context, message: "Video file not found", type: SnackbarType.error);
      _isSharing = false;
      return;
    }

    try {
      AppAnimatedLoader.show(context, message: "Preparing video to share...");

      final tempDir = await Directory.systemTemp.createTemp();
      final tempFile = await videoFile.copy('${tempDir.path}/shared_video.mp4');

      if (_disposed) return; // ✅ safety check

      await Share.shareXFiles(
        [XFile(tempFile.path, mimeType: 'video/mp4')],
        text: 'Shared via My App',
      );
    } catch (e) {
      if (_disposed) return;
      AppSnackbar.show(context, message: "Share failed: ${e.toString()}", type: SnackbarType.error);
    } finally {
      if (_disposed) return;
      AppAnimatedLoader.hide(context);
      _isSharing = false;
    }
  }

  ///********************** Dispose safely *************************************
  void disposeAll() {
    try {
      chewieController?.dispose();
      videoPlayerController?.dispose();
    } catch (e) {
      debugPrint('[VideoPreviewController] Dispose error: $e');
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (_disposed || !isReady) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      videoPlayerController?.pause();
      chewieController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!(videoPlayerController?.value.isPlaying ?? false)) {
        videoPlayerController?.play();
      }
      chewieController?.play();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    disposeAll();
    super.dispose();
  }

  /// ************************************************************************
}

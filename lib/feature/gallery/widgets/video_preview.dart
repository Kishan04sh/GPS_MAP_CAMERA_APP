

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

class VideoPreview extends StatefulWidget {
  final String url; // Network URL or local file path
  final bool isLocal;

  const VideoPreview({
    super.key,
    required this.url,
    this.isLocal = false,
  });

  @override
  State<VideoPreview> createState() => _VideoPreviewState();
}

class _VideoPreviewState extends State<VideoPreview> with WidgetsBindingObserver {
  VideoPlayerController? _videoPlayerController;
  ChewieController? _chewieController;

  bool _isReady = false;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeVideo();
  }

  Future<void> _initializeVideo() async {
    try {
      _videoPlayerController = widget.isLocal
          ? VideoPlayerController.file(File(widget.url))
          : VideoPlayerController.network(widget.url);

      await _videoPlayerController!.initialize();

      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowPlaybackSpeedChanging: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blueAccent,
          bufferedColor: Colors.white38,
          handleColor: Colors.white,
          backgroundColor: Colors.black26,
        ),
      );

      if (!mounted) return;
      setState(() => _isReady = true);
    } catch (e) {
      debugPrint("Video initialization error: $e");
      if (mounted) setState(() => _hasError = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isReady || _hasError) return;

    if (state == AppLifecycleState.paused || state == AppLifecycleState.inactive) {
      _videoPlayerController?.pause();
      _chewieController?.pause();
    } else if (state == AppLifecycleState.resumed) {
      if (!(_videoPlayerController?.value.isPlaying ?? false)) {
        _videoPlayerController?.play();
        _chewieController?.play();
      }
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    try {
      _chewieController?.dispose();
      _videoPlayerController?.dispose();
    } catch (e) {
      debugPrint("Dispose error: $e");
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_hasError) {
      return const Center(
        child: Icon(Icons.error, color: Colors.red, size: 50),
      );
    }

    if (!_isReady) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return Chewie(controller: _chewieController!);
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:camera/camera.dart';
import '../viewmodal/video_controller.dart';
import 'video_preview_screen.dart';

class VideoCameraScreen extends ConsumerStatefulWidget {
  const VideoCameraScreen({super.key});

  @override
  ConsumerState<VideoCameraScreen> createState() =>
      _VideoCameraScreenState();
}

class _VideoCameraScreenState
    extends ConsumerState<VideoCameraScreen> {

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(videoCameraProvider.notifier).initCamera();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCameraProvider);
    final notifier = ref.read(videoCameraProvider.notifier);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          if (state.isReady)
            Positioned.fill(
              child: CameraPreview(state.controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          /// TIMER
          Positioned(
            top: 50,
            left: 0,
            right: 0,
            child: Center(
              child: Text(
                _format(state.recordingDuration),
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          /// CONTROLS
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Center(
              child: GestureDetector(
                onTap: () async {
                  if (!state.isRecording) {
                    await notifier.startRecording();
                  } else {
                    final file = await notifier.stopRecording();
                    if (!mounted || file == null) return;

                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) => VideoPreviewScreen(video: file),
                      ),
                    );
                  }
                },
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color:
                    state.isRecording ? Colors.red : Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _format(Duration d) =>
      '${d.inMinutes.toString().padLeft(2, '0')}:'
          '${(d.inSeconds % 60).toString().padLeft(2, '0')}';
}

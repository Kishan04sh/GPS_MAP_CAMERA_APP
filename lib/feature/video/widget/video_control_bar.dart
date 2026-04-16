import 'package:flutter/material.dart';

class VideoControlBar extends StatefulWidget {
  final bool isRecording;
  final Future<void> Function()? onStart;
  final Future<void> Function()? onStop;
  final Future<void> Function()? onSwitchCamera;

  const VideoControlBar({
    super.key,
    required this.isRecording,
    this.onStart,
    this.onStop,
    this.onSwitchCamera,
  });

  @override
  State<VideoControlBar> createState() => _VideoControlBarState();
}

class _VideoControlBarState extends State<VideoControlBar> {
  bool _busy = false; // 🔒 prevents double-tap

  Future<void> _run(Future<void> Function()? action, String tag) async {
    if (_busy || action == null) {
      print('[ControlBar] $tag blocked');
      return;
    }

    try {
      setState(() => _busy = true);
      print('[ControlBar] $tag start');
      await action();
      print('[ControlBar] $tag success');
    } catch (e, st) {
      print('[ControlBar] $tag error: $e');
      print(st);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 26),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [

            // ================= SWITCH CAMERA =================
            Opacity(
              opacity: (widget.isRecording || _busy) ? 0.4 : 1,
              child: circle(
                icon: Icons.cameraswitch,
                onTap: (widget.isRecording || _busy)
                    ? null
                    : () => _run(widget.onSwitchCamera, 'switch camera'),
              ),
            ),

            //const SizedBox(width: 50),

            // ================= RECORD BUTTON =================
            GestureDetector(
              onTap: _busy
                  ? null
                  : () => _run(
                widget.isRecording ? widget.onStop : widget.onStart,
                widget.isRecording ? 'stop recording' : 'start recording',
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: widget.isRecording ? Colors.red.shade400 : Colors.white,
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black38,
                      blurRadius: 12,
                      offset: Offset(0, 6),
                    ),
                  ],
                ),
                child: Center(
                  child: _busy
                      ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(
                      strokeWidth: 3,
                      color: Colors.red,
                    ),
                  )
                      : Icon(
                    widget.isRecording ? Icons.stop : Icons.circle,
                    size: 36,
                    color: widget.isRecording ? Colors.white : Colors.red,
                  ),
                ),
              ),
            ),

            // ================= PLACEHOLDER (BALANCE SPACE) =================
            const SizedBox(width: 54),
          ],
        ),
      ),
    );
  }


  /// ***********************************************************************

  Widget circle({required IconData icon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 54,
        height: 54,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.black.withOpacity(0.55),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    );
  }


  /// ************************************************************************
}

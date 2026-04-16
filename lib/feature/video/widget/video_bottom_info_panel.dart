import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';
import '../../../core/constants/app_colors.dart';
import 'video_control_bar.dart';
import '../../../core/widgets/static_map_preview.dart';

class VideoBottomInfoPanel extends StatefulWidget {
  final Position? position;
  final String? address;
  final bool isRecording;
  final Duration duration;
  final Future<void> Function()? onStart;
  final Future<void> Function()? onStop;
  final Future<void> Function()? onSwitchCamera;

  const VideoBottomInfoPanel({
    super.key,
    required this.isRecording,
    required this.duration,
    this.position,
    this.address,
    this.onStart,
    this.onStop,
    this.onSwitchCamera,
  });

  @override
  State<VideoBottomInfoPanel> createState() => _VideoBottomInfoPanelState();
}

class _VideoBottomInfoPanelState extends State<VideoBottomInfoPanel> {
  @override
  Widget build(BuildContext context) {
    final time = DateFormat('dd/MM/yyyy hh:mm a').format(DateTime.now());

    return SafeArea(
      top: false,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.position != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    color: Colors.black.withOpacity(0.6),
                    child: Row(
                      children: [

                        /// MAP PREVIEW
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: SizedBox(
                            width: 90,
                            height: 90,
                            child: StaticMapPreview(
                              lat: widget.position!.latitude,
                              lng: widget.position!.longitude,
                              satellite: true,
                            ),
                          ),
                        ),

                        const SizedBox(width: 12),


                        // Expanded(
                        //   child: Column(
                        //     crossAxisAlignment: CrossAxisAlignment.start,
                        //     children: [
                        //       Text(
                        //         address ?? 'Fetching address...',
                        //         maxLines: 2,
                        //         overflow: TextOverflow.ellipsis,
                        //         style: const TextStyle(color: Colors.white, fontSize: 13),
                        //       ),
                        //       const SizedBox(height: 4),
                        //       Text(time, style: const TextStyle(color: Colors.white70, fontSize: 11)),
                        //     ],
                        //   ),
                        // ),

                        /// LOCATION INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.address ?? 'Fetching address...',
                                maxLines: 3,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  height: 1.3,
                                ),
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(Icons.place, size: 14, color: AppColors.grey300),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lat: ${widget.position!.latitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey300.withOpacity(0.9),
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  const Icon(Icons.place, size: 14, color: AppColors.grey300),
                                  const SizedBox(width: 4),
                                  Text(
                                    'Lng: ${widget.position!.longitude.toStringAsFixed(6)}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.grey300.withOpacity(0.9),
                                    ),
                                  ),
                                ],
                              ),

                              const SizedBox(height: 6),

                              Row(
                                children: [
                                  const Icon(Icons.punch_clock, size: 12, color: AppColors.grey300),
                                  const SizedBox(width: 4),
                                  Text(
                                    time,
                                    style: TextStyle(
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.75),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),



                      ],
                    ),
                  ),
                ),
              ),
            ),

          const SizedBox(height: 10),

          if (widget.isRecording)
            Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: Text(
                _fmt(widget.duration),
                style: const TextStyle(color: Colors.red, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),

          VideoControlBar(
            isRecording: widget.isRecording,
            onStart: widget.onStart,
            onStop: widget.onStop,
            onSwitchCamera: widget.onSwitchCamera,
          ),

          /// HELPER TEXT
          Text(
            widget.isRecording ? 'Tap to capture your location' : 'Waiting for GPS location…',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    final mm = d.inMinutes.toString().padLeft(2, '0');
    final ss = (d.inSeconds % 60).toString().padLeft(2, '0');
    return '$mm:$ss';
  }
}

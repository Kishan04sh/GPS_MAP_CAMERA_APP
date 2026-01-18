

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:gps_map_camera/core/constants/app_colors.dart';
import 'package:gps_map_camera/core/widgets/app_snackbar.dart';
import 'package:gps_map_camera/core/widgets/static_map_preview.dart';
import 'package:intl/intl.dart';

import 'camera_bottom_bar.dart';

class BottomInfoPanel extends StatefulWidget {
  final Position? position;
  final String? address;
  final Future<void> Function()? onCapture;
  final VoidCallback? onSwitchCamera;
  final VoidCallback? onVideo; // Optional video callback

  const BottomInfoPanel({
    super.key,
    this.position,
    this.address,
    this.onCapture,
    this.onSwitchCamera,
    this.onVideo,
  });

  @override
  State<BottomInfoPanel> createState() => _BottomInfoPanelState();
}

class _BottomInfoPanelState extends State<BottomInfoPanel> {
  bool _isCapturing = false;

  bool get _canTap => widget.position != null && widget.onCapture != null && !_isCapturing;

  Future<void> _handleCapture() async {
    if (!_canTap) {
      AppSnackbar.show(
        context,
        message: 'Waiting for GPS location…',
        type: SnackbarType.warning,
      );
      return;
    }

    setState(() => _isCapturing = true);

    try {
      await widget.onCapture!.call();
    } catch (e, st) {
      if (!mounted) return;
      AppSnackbar.show(
        context,
        message: 'Failed to capture location',
        type: SnackbarType.error,
      );
      debugPrint('[BOTTOM_INFO_PANEL][ERROR] $e');
      debugPrint(st.toString());
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).viewPadding.bottom;
    final time = DateFormat('dd/MM/yyyy  hh:mm a').format(DateTime.now());

    return Padding(
      padding: EdgeInsets.only(bottom: bottomPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          /// ================= INFO PANEL =================
          if (widget.position != null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 2),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.15),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
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

                        /// LOCATION INFO
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.address?.trim().isNotEmpty == true
                                    ? widget.address!
                                    : 'Fetching address…',
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

          const SizedBox(height: 12),

          /// ================= CAMERA CONTROL BAR =================
          CameraControlBar(
            canCapture: _canTap,
            isCapturing: _isCapturing,
            onCapture: _handleCapture,
            onSwitchCamera: widget.onSwitchCamera,
            onVideo: widget.onVideo,
          ),

          const SizedBox(height: 6),

          /// HELPER TEXT
          Text(
            _canTap ? 'Tap to capture your location' : 'Waiting for GPS location…',
            style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85)),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 6),
        ],
      ),
    );
  }
}



///****************************************************************

//
// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/api/api_constants.dart';
// import '../../../core/utils/build_gps_panel.dart';
// import '../../../core/utils/video_stamp_util.dart';
// import '../../../core/widgets/app_snackbar.dart';
// import '../../../core/widgets/static_map_preview.dart';
// import '../../gallery/modal/media_type.dart';
// import '../../gallery/view_modal/gallery_controller.dart';
// import '../viewmodal/video_controller.dart';
// import '../widget/video_bottom_info_panel.dart';
// import '../widget/video_pinch_wrapper.dart';
// import '../widget/video_top_bar.dart';
// import 'video_preview_screen.dart';
// import '../../camera/viewmodal/location_controller.dart';
// import '../../camera/viewmodal/address_controller.dart';
//
// class VideoCameraScreen extends ConsumerStatefulWidget {
//   const VideoCameraScreen({super.key});
//
//   @override
//   ConsumerState<VideoCameraScreen> createState() => _VideoCameraScreenState();
// }
//
// class _VideoCameraScreenState extends ConsumerState<VideoCameraScreen> {
//   bool _busy = false;
//
//   @override
//   void initState() {
//     super.initState();
//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       try {
//         await ref.read(videoCameraProvider.notifier).initCamera();
//       } catch (e, st) {
//         debugPrint('[VideoScreen][initCamera ERROR] $e');
//         debugPrint(st.toString());
//       }
//     });
//   }
//
//   @override
//   void dispose() {
//     debugPrint('[VideoScreen] dispose');
//     ref.read(videoCameraProvider.notifier).disposeCamera();
//     super.dispose();
//   }
//
//  /// ***************************************************************************
//
//   Future<bool> _handleBack(VideoCameraController notifier) async {
//     if (_busy) {
//       debugPrint('[VideoScreen][BACK] blocked: busy');
//       return false;
//     }
//     _busy = true;
//     try {
//       // 1️⃣ Stop recording safely
//       if (notifier.state.isRecording) {
//         debugPrint('[VideoScreen][BACK] stopping recording');
//         await notifier.stopRecording();
//       }
//       // 2️⃣ Detach preview
//       notifier.detachPreviewSafely.call();
//       // 3️⃣ Dispose camera
//       await notifier.disposeCamera();
//       // 4️⃣ HAL settle
//       await Future.delayed(const Duration(milliseconds: 150));
//       debugPrint('[VideoScreen][BACK] safe exit');
//       return true;
//     } catch (e, st) {
//       debugPrint('[VideoScreen][BACK ERROR] $e');
//       debugPrint(st.toString());
//       return true; // allow exit to avoid lock
//     } finally {
//       _busy = false;
//     }
//   }
//
//
//   /// ****************************************************************************
//
//   @override
//   Widget build(BuildContext context) {
//     final state = ref.watch(videoCameraProvider);
//     final notifier = ref.read(videoCameraProvider.notifier);
//     final position = ref.watch(locationProvider);
//     final address = ref.watch(addressProvider);
//
//     return WillPopScope(
//       onWillPop: () => _handleBack(notifier),
//       child: Scaffold(
//         backgroundColor: Colors.black,
//         body: Stack(
//           children: [
//             // ================= CAMERA PREVIEW =================
//             Positioned.fill(
//               child: SafeArea(
//                 bottom: false,
//                 child: state.isReady
//                     ? VideoPinchWrapper(
//                   child: state.controller != null && state.controller!.value.isInitialized
//                       ? CameraPreview(state.controller!)
//                       : const SizedBox.shrink(),
//
//                 )
//                     : const Center(
//                   child: CircularProgressIndicator(color: Colors.white),
//                 ),
//               ),
//             ),
//
//          /// ================= TOP BAR =================
//             Positioned(
//               top: 0,
//               left: 0,
//               right: 0,
//               child: SafeArea(
//                 bottom: false,
//                 child: VideoTopBar(
//                   onBack: () async {
//                     final canPop = await _handleBack(notifier);
//                     if (canPop && mounted) Navigator.pop(context);
//                   },
//
//                   onSwitchCamera: (!state.isReady || state.isRecording || _busy)
//                       ? null
//                       : () async {
//                     try {
//                       await notifier.switchCamera();
//                     } catch (e) {
//                       debugPrint('[TopBar][SwitchCamera ERROR] $e');
//                     }
//                   },
//
//                   onToggleFlash: (state.isRecording || _busy)
//                       ? null
//                       : () async {
//                     try {
//                       await notifier.toggleFlash();
//                     } catch (e) {
//                       debugPrint('[TopBar][ToggleFlash ERROR] $e');
//                     }
//                   },
//
//                   isFlashOn: state.isFlashOn,
//                 ),
//               ),
//             ),
//
//        /// ================= BOTTOM PANEL =================
//             Positioned(
//               left: 0,
//               right: 0,
//               bottom: 0,
//               child: VideoBottomInfoPanel(
//                 position: position,
//                 address: address,
//                 isRecording: state.isRecording,
//                 duration: state.recordingDuration,
//                 onStart: () async {
//                   if (_busy) return;
//                   _busy = true;
//                   try {
//                     await notifier.startRecording();
//                   } catch (e) {
//                     debugPrint('[BottomPanel][StartRecording ERROR] $e');
//                   } finally {
//                     _busy = false;
//                   }
//                 },
//
//
//                /* onStop: () async {
//                   if (_busy) return;
//                   _busy = true;
//
//                   try {
//                     final file = await notifier.stopRecording();
//                     if (!mounted || file == null) return;
//
//                     // ===== Download Map =====
//                     File mapFile = File('');
//                     try {
//                       final mapUrl =
//                           'https://maps.googleapis.com/maps/api/staticmap'
//                           '?center=${position!.latitude},${position.longitude}'
//                           '&zoom=17'
//                           '&size=800x400'
//                           '&scale=2'
//                           '&maptype=satellite'
//                           '&markers=color:red|${position.latitude},${position.longitude}'
//                           '&key=${ApiURLConstants.mapApiKay}';
//                       mapFile = await downloadMap(mapUrl, file.parent);
//                     } catch (e) {
//                       debugPrint('[VideoScreen][DownloadMap ERROR] $e');
//                     }
//
//                     // ===== Build GPS Panel =====
//                     File gpsPanel = File('');
//                     try {
//                       gpsPanel = await buildGpsPanel(
//                         mapImage: mapFile,
//                         address: address ?? 'Address unavailable',
//                         lat: position!.latitude,
//                         lng: position.longitude,
//                         dateTime: formatDateTime(DateTime.now()),
//                         dir: file.parent,
//                       );
//                     } catch (e) {
//                       debugPrint('[VideoScreen][BuildGPSPanel ERROR] $e');
//                       gpsPanel = mapFile; // fallback
//                     }
//
//                     // ===== Overlay panel on video =====
//                     File finalVideo = file;
//                     try {
//                       finalVideo = await VideoFfmpegService.overlayGpsPanel(
//                         input: file,
//                         panel: gpsPanel,
//                       );
//                     } catch (e) {
//                       debugPrint('[VideoScreen][FFmpeg overlay ERROR] $e');
//                     }
//
//                     // ===== Preview Video =====
//                     if (mounted) {
//                       await Navigator.push(
//                         context,
//                         MaterialPageRoute(
//                           builder: (_) => VideoPreviewScreen(video: finalVideo),
//                         ),
//                       );
//                     }
//
//                     // ===== Re-init Camera =====
//                     if (mounted) {
//                       try {
//                         await notifier.initCamera();
//                       } catch (e) {
//                         debugPrint('[VideoScreen][Re-initCamera ERROR] $e');
//                       }
//                     }
//                   } finally {
//                     _busy = false;
//                   }
//                 },*/
//
//                 onStop: () async {
//                   if (_busy) return;
//                   _busy = true;
//
//                   try {
//                     final file = await notifier.stopRecording();
//                     if (!mounted || file == null) return;
//
//                     File mapFile = File('');
//                     File gpsPanel = File('');
//                     File finalVideo = file;
//
//                     // ----------------- Download Map -----------------
//                     try {
//                       final mapUrl =
//                           'https://maps.googleapis.com/maps/api/staticmap'
//                           '?center=${position!.latitude},${position.longitude}'
//                           '&zoom=17'
//                           '&size=800x400'
//                           '&scale=2'
//                           '&maptype=satellite'
//                           '&markers=color:red|${position.latitude},${position.longitude}'
//                           '&key=${ApiURLConstants.mapApiKay}';
//
//                       mapFile = await downloadMap(mapUrl, file.parent);
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][DownloadMap ERROR] $e\n$st');
//                       mapFile = file; // fallback to raw video folder
//                     }
//
//                     // ----------------- Build GPS Panel -----------------
//                     try {
//                       gpsPanel = await buildGpsPanel(
//                         mapImage: mapFile,
//                         address: address ?? 'Address unavailable',
//                         lat: position!.latitude,
//                         lng: position.longitude,
//                         dateTime: formatDateTime(DateTime.now()),
//                         dir: file.parent,
//                       );
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][BuildGPSPanel ERROR] $e\n$st');
//                       gpsPanel = mapFile; // fallback to map only
//                     }
//
//                     // ----------------- Overlay panel on video -----------------
//                     try {
//                       finalVideo = await VideoFfmpegService.overlayGpsPanel(
//                         input: file,
//                         panel: gpsPanel,
//                       );
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][FFmpeg overlay ERROR] $e\n$st');
//                       finalVideo = file; // fallback to original video
//                     }
//
//                     // ----------------- Upload Video -----------------
//                     try {
//                       await ref.read(galleryViewModelProvider.notifier).uploadMedia(
//                         context,
//                         file: finalVideo,
//                         latitude: position!.latitude.toString(),
//                         longitude: position.longitude.toString(),
//                         location: address ?? "NA",
//                         type: MediaType.video, // ✅ IMPORTANT
//                       );
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][UploadMedia ERROR] $e\n$st');
//                       AppSnackbar.show(
//                         context,
//                         message: "Failed to upload video",
//                         type: SnackbarType.error,
//                       );
//                     }
//
//                     // ----------------- Preview Video -----------------
//                     try {
//                       if (mounted) {
//                         await Navigator.push(
//                           context,
//                           MaterialPageRoute(
//                             builder: (_) => VideoPreviewScreen(video: finalVideo),
//                           ),
//                         );
//                       }
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][VideoPreview ERROR] $e\n$st');
//                     }
//
//                     // ----------------- Re-init Camera -----------------
//                     try {
//                       if (mounted) await notifier.initCamera();
//                     } catch (e, st) {
//                       debugPrint('[VideoScreen][Re-initCamera ERROR] $e\n$st');
//                     }
//
//                   } finally {
//                     _busy = false;
//                   }
//                 },
//
//
//
//                 onSwitchCamera: (!state.isReady || state.isRecording || _busy)
//                     ? null
//                     : () async {
//                   try {
//                     await notifier.switchCamera();
//                   } catch (e) {
//                     debugPrint('[BottomPanel][SwitchCamera ERROR] $e');
//                   }
//                 },
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/static_map_preview.dart';
import '../viewmodal/video_controller.dart';
import '../widget/video_bottom_info_panel.dart';
import '../widget/video_top_bar.dart';
import '../widget/video_pinch_wrapper.dart';
import 'video_preview_screen.dart';
import '../../camera/viewmodal/location_controller.dart';
import '../../camera/viewmodal/address_controller.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/utils/build_gps_panel.dart';
import '../../../core/utils/video_stamp_util.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../../gallery/modal/media_type.dart';
import '../../gallery/view_modal/gallery_controller.dart';
import 'package:go_router/go_router.dart'; // Make sure go_router is imported

class VideoCameraScreen extends ConsumerStatefulWidget {
  const VideoCameraScreen({super.key});

  @override
  ConsumerState<VideoCameraScreen> createState() => _VideoCameraScreenState();
}

class _VideoCameraScreenState extends ConsumerState<VideoCameraScreen> {
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await ref.read(videoCameraProvider.notifier).initCamera();
    });
  }

  // ================= BACK HANDLER =================
  Future<void> _handleBack(VideoCameraController notifier) async {
    if (_busy) return;
    _busy = true;
    try {
      if (notifier.state.isRecording) {
        await notifier.stopRecording();
      }
      notifier.detachPreviewSafely();
      await Future.delayed(const Duration(milliseconds: 150));

      // ✅ Directly navigate to home
      if (mounted) context.go(RouteNames.home);
    } finally {
      _busy = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(videoCameraProvider);
    final notifier = ref.read(videoCameraProvider.notifier);
    final position = ref.watch(locationProvider);
    final address = ref.watch(addressProvider);

    // ==== PERMISSION ERROR UI ====
    if (state.error?.contains('permission') == true) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(
          child: ElevatedButton(
            onPressed: () async {
              await notifier.initCamera();
            },
            child: const Text('Grant Camera & Mic Permission'),
          ),
        ),
      );
    }

    return WillPopScope(
      onWillPop: () async {
        await _handleBack(notifier);
        return false; // Prevent default back pop
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: Stack(
          children: [
            // CAMERA PREVIEW
            Positioned.fill(
              child: SafeArea(
                bottom: false,
                child: state.isReady
                    ? VideoPinchWrapper(
                  child: state.controller != null &&
                      state.controller!.value.isInitialized
                      ? CameraPreview(state.controller!)
                      : const SizedBox.shrink(),
                )
                    : const Center(
                  child: CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // TOP BAR
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SafeArea(
                bottom: false,
                child: VideoTopBar(
                  onBack: () async => await _handleBack(notifier),
                  onSwitchCamera: (!state.isReady || state.isRecording || _busy)
                      ? null
                      : () async {
                    await notifier.switchCamera();
                  },
                  onToggleFlash: (state.isRecording || _busy)
                      ? null
                      : () async {
                    await notifier.toggleFlash();
                  },
                  isFlashOn: state.isFlashOn,
                ),
              ),
            ),
            // BOTTOM PANEL
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: VideoBottomInfoPanel(
                position: position,
                address: address,
                isRecording: state.isRecording,
                duration: state.recordingDuration,
                onStart: () async {
                  if (_busy) return;
                  _busy = true;
                  try {
                    await notifier.startRecording();
                  } finally {
                    _busy = false;
                  }
                },
                onStop: () async {
                  if (_busy) return;
                  _busy = true;
                  try {
                    final file = await notifier.stopRecording();
                    if (!mounted || file == null) return;

                    // ✅ Re-init camera
                    if (mounted) await notifier.initCamera();

                    File mapFile = File('');
                    File gpsPanel = File('');
                    File finalVideo = file;

                    // Download map
                    try {
                      final mapUrl =
                          'https://maps.googleapis.com/maps/api/staticmap'
                          '?center=${position!.latitude},${position.longitude}'
                          '&zoom=17'
                          '&size=800x400'
                          '&scale=2'
                          '&maptype=satellite'
                          '&markers=color:red|${position.latitude},${position.longitude}'
                          '&key=${ApiURLConstants.mapApiKay}';
                      mapFile = await downloadMap(mapUrl, file.parent);
                    } catch (_) {
                      mapFile = file;
                    }

                    // Build GPS Panel
                    try {
                      gpsPanel = await buildGpsPanel(
                        mapImage: mapFile,
                        address: address ?? 'Address unavailable',
                        lat: position!.latitude,
                        lng: position.longitude,
                        dateTime: formatDateTime(DateTime.now()),
                        dir: file.parent,
                      );
                    } catch (_) {
                      gpsPanel = mapFile;
                    }

                    // Overlay GPS on video
                    try {
                      finalVideo = await VideoFfmpegService.overlayGpsPanel(
                        input: file,
                        panel: gpsPanel,
                      );
                    } catch (_) {
                      finalVideo = file;
                    }

                    // Upload video
                    try {
                      await ref
                          .read(galleryViewModelProvider.notifier)
                          .uploadMedia(
                        context,
                        file: finalVideo,
                        latitude: position!.latitude.toString(),
                        longitude: position.longitude.toString(),
                        location: address ?? "NA",
                        type: MediaType.video,
                      );
                    } catch (_) {
                      AppSnackbar.show(
                        context,
                        message: "Failed to upload video",
                        type: SnackbarType.error,
                      );
                    }

                    // Preview video
                    try {
                      if (mounted) {
                        await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                VideoPreviewScreen(video: finalVideo),
                          ),
                        );
                      }
                    } catch (_) {}

                    // Re-init camera
                    try {
                      if (mounted) await notifier.initCamera();
                    } catch (_) {}
                  } finally {
                    _busy = false;
                  }
                },
                onSwitchCamera: (state.isReady && !_busy && !state.isRecording)
                    ? () async {
                  await notifier.switchCamera();
                }
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

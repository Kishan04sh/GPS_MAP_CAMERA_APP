import 'dart:io';

import '../../../core/api/api_constants.dart';
import '../../../core/utils/build_gps_panel.dart';
import '../../../core/utils/video_stamp_util.dart';
import '../../../core/widgets/static_map_preview.dart';

sealed class CaptureResult {
  const CaptureResult();

  File get file;
}

/// PHOTO RESULT
class PhotoCapture extends CaptureResult {
  @override
  final File file;

  final double lat;
  final double lng;
  final String address;

  const PhotoCapture({
    required this.file,
    required this.lat,
    required this.lng,
    required this.address,
  });
}

/// VIDEO RESULT
class VideoCapture extends CaptureResult {
  @override
  final File file;

  final double lat;
  final double lng;
  final String address;

  const VideoCapture({
    required this.file,
    required this.lat,
    required this.lng,
    required this.address,
  });
}


/// *******************************************************************

class VideoProcessingService {

  static Future<File> processVideo({
    required File input,
    required double lat,
    required double lng,
    required String address,
  }) async {

    File mapFile = input;
    File gpsPanel = input;
    File finalVideo = input;

    /// 1️⃣ MAP
    try {
      final mapUrl =
          'https://maps.googleapis.com/maps/api/staticmap'
          '?center=$lat,$lng'
          '&zoom=17'
          '&size=800x400'
          '&scale=2'
          '&maptype=satellite'
          '&markers=color:red|$lat,$lng'
          '&key=${ApiURLConstants.mapApiKay}';

      mapFile = await downloadMap(mapUrl, input.parent);
    } catch (_) {}

    /// 2️⃣ PANEL
    try {
      gpsPanel = await buildGpsPanel(
        mapImage: mapFile,
        address: address,
        lat: lat,
        lng: lng,
        dateTime: formatDateTime(DateTime.now()),
        dir: input.parent,
      );
    } catch (_) {}

    /// 3️⃣ OVERLAY
    try {
      finalVideo = await VideoFfmpegService.overlayGpsPanel(
        input: input,
        panel: gpsPanel,
      );
    } catch (_) {}

    return finalVideo;
  }
}

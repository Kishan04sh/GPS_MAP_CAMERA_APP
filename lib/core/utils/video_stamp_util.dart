//
// import 'dart:io';
// import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
// import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
// import 'dart:async';
//
// class VideoFfmpegService {
//   static Future<File> addWatermarkWithMap({
//     required File input,
//     required String locationText,
//     required String mapUrl,
//   }) async {
//     final outPath =
//         '${input.parent.path}/geo_${DateTime.now().millisecondsSinceEpoch}.mp4';
//     print('[Watermark] Input video: ${input.path}');
//     print('[Watermark] Output video: $outPath');
//
//     final dateTimeText = DateTime.now().toLocal().toString().split('.')[0];
//     final watermarkText = "$locationText\n$dateTimeText";
//
//     final safeText = watermarkText
//         .replaceAll(":", "\\:")
//         .replaceAll("'", "\\'")
//         .replaceAll(",", "\\,")
//         .replaceAll("&", "\\&")
//         .replaceAll("%", "\\%")
//         .replaceAll("(", "\\(")
//         .replaceAll(")", "\\)")
//         .replaceAll("\n", "\\n");
//
//     const fontPath = "/system/fonts/Roboto-Regular.ttf";
//
//     // Download map
//     final tempMapPath =
//         '${input.parent.path}/map_${DateTime.now().millisecondsSinceEpoch}.png';
//     final mapFile = File(tempMapPath);
//     final client = HttpClient();
//     final request = await client.getUrl(Uri.parse(mapUrl));
//     final response = await request.close();
//     final bytes = await consolidateHttpClientResponseBytes(response);
//     await mapFile.writeAsBytes(bytes);
//
//     if (!await mapFile.exists()) {
//       throw Exception('Map file does not exist at path: $tempMapPath');
//     }
//
//     final safeMapPath = tempMapPath.replaceAll("'", "\\'");
//
//     // FFmpeg command: map scaled, overlay bottom-left, text to right
//     final cmd =
//         '-i "${input.path}" -i "$safeMapPath" '
//         '-filter_complex "[1:v]scale=180:100,pad=iw+4:ih+4:2:2:color=black[map];'
//         '[0:v][map]overlay=10:main_h-overlay_h-10[tmp];'
//         '[tmp]drawtext=fontfile=$fontPath:text=\'$safeText\':x=200:y=H-90:fontsize=24:fontcolor=white:box=1:boxcolor=black@0.5:boxborderw=5" '
//         '-c:a copy "$outPath"';
//
//
//     print('[Watermark] FFmpeg command: $cmd');
//
//     final session = await FFmpegKit.execute(cmd);
//     final returnCode = await session.getReturnCode();
//
//     if (ReturnCode.isSuccess(returnCode)) {
//       return File(outPath);
//     } else {
//       final logs = await session.getAllLogsAsString();
//       throw Exception('Failed to add watermark. Logs:\n$logs');
//     }
//   }
// }
//
// Future<List<int>> consolidateHttpClientResponseBytes(
//     HttpClientResponse response) {
//   final completer = Completer<List<int>>();
//   final contents = <int>[];
//   response.listen(
//         (data) => contents.addAll(data),
//     onDone: () => completer.complete(contents),
//     onError: (e) => completer.completeError(e),
//     cancelOnError: true,
//   );
//   return completer.future;
// }


/*
import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';
import 'package:flutter/foundation.dart';

class VideoFfmpegService {
  static Future<File> addWatermarkWithMap({
    required File input,
    required String locationText,
    required String mapUrl,
  }) async {
    const tag = '[FFMPEG-WATERMARK]';

    try {
      print('$tag START');

      if (!await input.exists()) {
        throw Exception('Input video not found');
      }

      final outPath =
          '${input.parent.path}/geo_${DateTime.now().millisecondsSinceEpoch}.mp4';

      final dateTime =
      DateTime.now().toLocal().toString().substring(0, 19);

      final watermarkText = '$locationText\n$dateTime';

      final safeText = watermarkText
          .replaceAll("\\", "\\\\")
          .replaceAll(":", "\\:")
          .replaceAll("'", "\\'")
          .replaceAll(",", "\\,")
          .replaceAll("&", "\\&")
          .replaceAll("%", "\\%")
          .replaceAll("(", "\\(")
          .replaceAll(")", "\\)")
          .replaceAll("\n", "\\n");

      const fontPath = "/system/fonts/Roboto-Regular.ttf";

      final mapPath =
          '${input.parent.path}/map_${DateTime.now().millisecondsSinceEpoch}.png';

      await _downloadMap(mapUrl, mapPath);

      final cmd =
          '-i "${input.path}" -i "$mapPath" '
          '-filter_complex "'
          '[1:v]scale=260:150,'
          'pad=iw+10:ih+10:5:5:color=black[map];'
          '[0:v][map]overlay=20:main_h-overlay_h-30[tmp];'
          '[tmp]drawtext='
          'fontfile=$fontPath:'
          'text=\'$safeText\':'
          'x=310:'                    // ✅ FIXED (20 + 260 + 30)
          'y=main_h-overlay_h-30:'    // ✅ aligned with map
          'fontsize=22:'
          'line_spacing=10:'
          'fontcolor=white:'
          'box=1:'
          'boxcolor=black@0.55:'
          'boxborderw=12:'
          'text_shaping=1'
          '" '
          '-c:a copy "$outPath"';




      print('$tag CMD:\n$cmd');

      final session = await FFmpegKit.execute(cmd);
      final rc = await session.getReturnCode();

      if (!ReturnCode.isSuccess(rc)) {
        final logs = await session.getAllLogsAsString();
        print('$tag FAILED\n$logs');
        throw Exception('FFmpeg failed');
      }

      print('$tag SUCCESS');
      return File(outPath);
    } catch (e, s) {
      print('$tag ERROR: $e');
      print('$tag STACK:\n$s');
      rethrow;
    }
  }

  static Future<void> _downloadMap(String url, String path) async {
    final client = HttpClient();
    try {
      final req = await client.getUrl(Uri.parse(url));
      final res = await req.close();
      if (res.statusCode != 200) {
        throw Exception('Map HTTP ${res.statusCode}');
      }
      final bytes = await consolidateHttpClientResponseBytes(res);
      await File(path).writeAsBytes(bytes);
    } finally {
      client.close();
    }
  }
}
*/


import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:ffmpeg_kit_flutter_new_full/return_code.dart';

class VideoFfmpegService {
  static Future<File> overlayGpsPanel({
    required File input,
    required File panel,
  }) async {
    final outPath =
        '${input.parent.path}/final_${DateTime.now().millisecondsSinceEpoch}.mp4';

    final cmd =
        '-i "${input.path}" -i "${panel.path}" '
        '-filter_complex "overlay=20:main_h-overlay_h-20" '
        '-c:a copy "$outPath"';

    final session = await FFmpegKit.execute(cmd);
    final rc = await session.getReturnCode();

    if (!ReturnCode.isSuccess(rc)) {
      final logs = await session.getAllLogsAsString();
      throw Exception('FFmpeg failed:\n$logs');
    }

    return File(outPath);
  }
}

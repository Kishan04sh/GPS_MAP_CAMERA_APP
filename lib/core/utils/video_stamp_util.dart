import 'dart:io';
import 'package:ffmpeg_kit_flutter_new_full/ffmpeg_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

class VideoStampUtil {
  static Future<File> stamp({
    required File input,
    required String address,
    required double lat,
    required double lng,
    required DateTime time,
  }) async {
    final dir = await getApplicationDocumentsDirectory();
    final output = File('${dir.path}/video_gps_${DateTime.now().millisecondsSinceEpoch}.mp4');
    final formattedTime = DateFormat('dd/MM/yyyy hh:mm a').format(time);

    debugPrint('[VIDEO STAMP] Input video: ${input.path}');
    debugPrint('[VIDEO STAMP] Output video: ${output.path}');
    debugPrint('[VIDEO STAMP] Lat: $lat, Lng: $lng, Time: $formattedTime, Address: $address');

    // ================= FFMPEG COMMAND =================
    final cmd = '''
-i "${input.path}"
-vf "drawbox=x=0:y=ih-260:w=iw:h=260:color=black@0.65:t=fill,
drawtext=text='LAT: ${lat.toStringAsFixed(6)} Lng: ${lng.toStringAsFixed(6)}'
:x=20:y=h-220:fontsize=22:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2,
drawtext=text='${formattedTime}'
:x=20:y=h-180:fontsize=20:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2,
drawtext=text='${address.replaceAll(":", "\\:").replaceAll("'", "\\'")}'
:x=20:y=h-140:fontsize=18:fontcolor=white:shadowcolor=black:shadowx=2:shadowy=2
" -c:a copy "${output.path}"
''';

    debugPrint('[VIDEO STAMP] Executing FFmpeg command...');
    final session = await FFmpegKit.execute(cmd);

    final returnCode = await session.getReturnCode();
    if (returnCode!.isValueSuccess()) {
      debugPrint('[VIDEO STAMP] Video stamping completed successfully.');
    } else {
      debugPrint('[VIDEO STAMP] Video stamping failed with code: ${returnCode.getValue()}');
    }

    return output;
  }
}

import 'dart:io';
import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

enum CaptureOrientation {
  portraitUp,
  portraitDown,
  landscapeLeft,
  landscapeRight,
}

class CaptureOrientationServices {
  static const bool debugPaint = false;
  static const bool debugLog = true;

  static void log(Object o) {
    if (debugLog) print("STAMP_DEBUG: $o");
  }

  static Future<File> stamp({
    required File original,
    required String address,
    required double lat,
    required double lng,
    required DateTime time,
    required CaptureOrientation orientation,
  }) async {
    try {
      log("============== STAMP START ==============");
      log("Original file path: ${original.path}");

      // ================= LOAD IMAGE =================
      final bytes = await original.readAsBytes();
      final codec = await ui.instantiateImageCodec(bytes);
      final frame = await codec.getNextFrame();
      final photo = frame.image;

      log("Input image size: ${photo.width} x ${photo.height}");
      log("Orientation: $orientation");

      // Canvas size
      final isLandscape = orientation == CaptureOrientation.landscapeLeft ||
          orientation == CaptureOrientation.landscapeRight;
      final drawWidth = isLandscape ? photo.height.toDouble() : photo.width.toDouble();
      final drawHeight = isLandscape ? photo.width.toDouble() : photo.height.toDouble();

      log("Canvas size: $drawWidth x $drawHeight");

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder, Rect.fromLTWH(0, 0, drawWidth, drawHeight));

      // ================= DRAW ROTATED IMAGE =================
      canvas.save();
      _applyRotation(canvas, orientation, drawWidth, drawHeight);
      canvas.drawImage(photo, Offset.zero, Paint());
      canvas.restore(); // restore so bottom panel stays fixed

      // ================= BOTTOM PANEL =================
      final panelHeight = drawHeight * 0.26;
      final panelTop = drawHeight - panelHeight;

      final panelPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.25),
            Colors.black.withOpacity(0.88),
          ],
        ).createShader(Rect.fromLTWH(0, panelTop, drawWidth, panelHeight));

      canvas.drawRect(Rect.fromLTWH(0, panelTop, drawWidth, panelHeight), panelPaint);

      // ================= MAP =================
      ui.Image? mapImage;
      const padding = 14.0;
      const mapSize = 220.0;

      try {
        final url =
            'https://maps.googleapis.com/maps/api/staticmap'
            '?center=$lat,$lng'
            '&zoom=18'
            '&size=500x500'
            '&scale=2'
            '&maptype=satellite'
            '&markers=color:red|$lat,$lng'
            '&key=${ApiURLConstants.mapApiKay}';

        final response = await http.get(Uri.parse(url));
        if (response.statusCode == 200) {
          final mapCodec = await ui.instantiateImageCodec(response.bodyBytes);
          final mapFrame = await mapCodec.getNextFrame();
          mapImage = mapFrame.image;
          log("Map image downloaded: ${mapImage.width} x ${mapImage.height}");
        }
      } catch (e) {
        log("Map fetch error: $e");
      }

      final mapRect = Rect.fromLTWH(
        padding,
        panelTop + (panelHeight - mapSize) / 2,
        mapSize,
        mapSize,
      );

      canvas.drawRRect(RRect.fromRectAndRadius(mapRect, const Radius.circular(12)),
          Paint()..color = Colors.white);

      if (mapImage != null) {
        canvas.save();
        canvas.clipRRect(RRect.fromRectAndRadius(mapRect.deflate(5), const Radius.circular(10)));
        canvas.drawImageRect(
          mapImage,
          Rect.fromLTWH(0, 0, mapImage.width.toDouble(), mapImage.height.toDouble()),
          mapRect.deflate(5),
          Paint(),
        );
        canvas.restore();
      } else {
        final iconPainter = TextPainter(
          text: const TextSpan(text: '📍', style: TextStyle(fontSize: 46)),
          textDirection: TextDirection.ltr,
        )..layout();

        iconPainter.paint(
          canvas,
          Offset(
            mapRect.center.dx - iconPainter.width / 2,
            mapRect.center.dy - iconPainter.height / 2,
          ),
        );
      }

      // ================= TIME FORMAT =================
      String formatTime(DateTime dt) {
        final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';
        return '${dt.day.toString().padLeft(2, '0')}/'
            '${dt.month.toString().padLeft(2, '0')}/'
            '${dt.year}  '
            '${hour.toString().padLeft(2, '0')}:'
            '${dt.minute.toString().padLeft(2, '0')} $amPm';
      }

      final formattedTime = formatTime(time);

      // ================= TEXT =================
      final infoText = '''
📍 ${address.isNotEmpty ? address : 'Address unavailable'}
🌐 Lat: ${lat.toStringAsFixed(6)} | Lng: ${lng.toStringAsFixed(6)}
⏰ $formattedTime
''';

      final textPainter = TextPainter(
        text: TextSpan(
          text: infoText,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23,
            fontWeight: FontWeight.w700,
            height: 1.45,
            shadows: [Shadow(blurRadius: 6, color: Colors.black, offset: Offset(1, 1))],
          ),
        ),
        maxLines: 6,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: drawWidth - mapSize - padding * 2 - 20);
      canvas.save();
      canvas.translate(padding + mapSize + 18, panelTop + (panelHeight - textPainter.height) / 2);
      textPainter.paint(canvas, Offset.zero);
      canvas.restore();

      // ================= EXPORT =================
      final picture = recorder.endRecording();
      final img = await picture.toImage(drawWidth.toInt(), drawHeight.toInt());
      final pngBytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getApplicationDocumentsDirectory();
      final output = File('${dir.path}/geo_${DateTime.now().millisecondsSinceEpoch}.png');
      await output.writeAsBytes(pngBytes!.buffer.asUint8List());

      log("Stamped image saved: ${output.path}");
      log("============== STAMP END ==============");
      return output;
    } catch (e) {
      log("ERROR: $e");
      return original;
    }
  }

  // static void _applyRotation(Canvas canvas, CaptureOrientation o, double w, double h) {
  //   switch (o) {
  //     case CaptureOrientation.portraitUp:
  //       break;
  //     case CaptureOrientation.portraitDown:
  //       canvas.translate(w, h);
  //       canvas.rotate(math.pi);
  //       break;
  //     case CaptureOrientation.landscapeLeft:
  //       canvas.translate(0, h);
  //       canvas.rotate(-math.pi / 2);
  //       break;
  //     case CaptureOrientation.landscapeRight:
  //       canvas.translate(w, 0);
  //       canvas.rotate(math.pi / 2);
  //       break;
  //   }
  // }

  static void _applyRotation(Canvas canvas, CaptureOrientation o, double w, double h) {
    switch (o) {
      case CaptureOrientation.portraitUp:
      // no rotation needed
        break;
      case CaptureOrientation.portraitDown:
        canvas.translate(w, h);
        canvas.rotate(math.pi); // 180°
        break;
      case CaptureOrientation.landscapeLeft:
      // rotate 90° clockwise
        canvas.translate(w, 0);
        canvas.rotate(math.pi / 2);
        break;
      case CaptureOrientation.landscapeRight:
      // rotate 90° counter-clockwise
        canvas.translate(0, h);
        canvas.rotate(-math.pi / 2);
        break;
    }
  }

}

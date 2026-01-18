
import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';
import 'package:http/http.dart' as http;
import 'package:path_provider/path_provider.dart';

class ImageStampUtil {
  static Future<File> stamp({
    required File original,
    required String address,
    required double lat,
    required double lng,
    required DateTime time,
  }) async {
    try {
      /// ================= LOAD ORIGINAL IMAGE =================
      final originalBytes = await original.readAsBytes();
      final codec = await ui.instantiateImageCodec(originalBytes);
      final frame = await codec.getNextFrame();
      final photo = frame.image;

      final recorder = ui.PictureRecorder();
      final canvas = Canvas(
        recorder,
        Rect.fromLTWH(
          0,
          0,
          photo.width.toDouble(),
          photo.height.toDouble(),
        ),
      );

      canvas.drawImage(photo, Offset.zero, Paint());

      /// ================= BOTTOM PANEL =================
      final panelHeight = photo.height * 0.26;
      final panelTop = photo.height - panelHeight;

      final panelPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.black.withOpacity(0.25),
            Colors.black.withOpacity(0.88),
          ],
        ).createShader(
          Rect.fromLTWH(0, panelTop, photo.width.toDouble(), panelHeight),
        );

      canvas.drawRect(
        Rect.fromLTWH(0, panelTop, photo.width.toDouble(), panelHeight),
        panelPaint,
      );

      /// ================= MAP CONFIG =================
      const padding = 14.0;
      const mapSize = 220.0;
      const borderRadius = Radius.circular(12);

      ui.Image? mapImage;

      try {
        final mapUrl =
            'https://maps.googleapis.com/maps/api/staticmap'
            '?center=$lat,$lng'
            '&zoom=18'
            '&size=500x500'
            '&scale=2'
            '&maptype=satellite'
            '&markers=color:red|$lat,$lng'
            '&key=${ApiURLConstants.mapApiKay}';

        final response = await http.get(Uri.parse(mapUrl));
        if (response.statusCode == 200) {
          final mapCodec =
          await ui.instantiateImageCodec(response.bodyBytes);
          final mapFrame = await mapCodec.getNextFrame();
          mapImage = mapFrame.image;
        }
      } catch (_) {
        mapImage = null;
      }

      /// ================= MAP DRAW =================
      final mapRect = Rect.fromLTWH(
        padding,
        panelTop + (panelHeight - mapSize) / 2,
        mapSize,
        mapSize,
      );

      canvas.drawRRect(
        RRect.fromRectAndRadius(mapRect, borderRadius),
        Paint()..color = Colors.white,
      );

      if (mapImage != null) {
        canvas.drawImageRect(
          mapImage,
          Rect.fromLTWH(
            0,
            0,
            mapImage.width.toDouble(),
            mapImage.height.toDouble(),
          ),
          mapRect.deflate(5),
          Paint(),
        );
      } else {
        final iconPainter = TextPainter(
          text: const TextSpan(
            text: '📍',
            style: TextStyle(fontSize: 46),
          ),
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

      /// ================= TIME FORMAT =================
      String formatTime(DateTime dt) {
        final hour = dt.hour > 12 ? dt.hour - 12 : dt.hour == 0 ? 12 : dt.hour;
        final amPm = dt.hour >= 12 ? 'PM' : 'AM';

        return
          '${dt.day.toString().padLeft(2, '0')}/'
              '${dt.month.toString().padLeft(2, '0')}/'
              '${dt.year}  '
              '${hour.toString().padLeft(2, '0')}:'
              '${dt.minute.toString().padLeft(2, '0')} $amPm';
      }

      final formattedTime = formatTime(time);

      /// ================= TEXT INFO =================
      const textX = padding + mapSize + 18;
      final maxTextWidth = photo.width - textX - padding;

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
            shadows: [
              Shadow(
                blurRadius: 6,
                color: Colors.black,
                offset: Offset(1, 1),
              )
            ],
          ),
        ),
        maxLines: 6,
        textDirection: TextDirection.ltr,
      );

      textPainter.layout(maxWidth: maxTextWidth);
      textPainter.paint(
        canvas,
        Offset(
          textX,
          panelTop + (panelHeight - textPainter.height) / 2,
        ),
      );

      /// ================= EXPORT IMAGE =================
      final picture = recorder.endRecording();
      final stampedImage = await picture.toImage(photo.width, photo.height);
      final pngBytes = await stampedImage.toByteData(format: ui.ImageByteFormat.png);
      final dir = await getApplicationDocumentsDirectory();
      final output = File(
        '${dir.path}/geo_${DateTime.now().millisecondsSinceEpoch}.png',
      );

      await output.writeAsBytes(pngBytes!.buffer.asUint8List());
      return output;
    } catch (e) {
      /// SAFETY
      return original;
    }
  }
}

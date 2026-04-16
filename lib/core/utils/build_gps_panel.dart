

import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';

Future<File> buildGpsPanel({
  required File mapImage,
  required String address,
  required double lat,
  required double lng,
  required String dateTime,
  required Directory dir,
}) async {
  const int panelWidth = 680;
  const int panelHeight = 230;

  const double outerPadding = 12;
  const double mapWidth = 240;
  const double mapHeight = 180;
  const double borderRadius = 20;

  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);

  // ================= PANEL BACKGROUND =================
  final bgPaint = Paint()..color = Colors.black.withOpacity(0.7);
  final bgRRect = RRect.fromRectAndRadius(
    Rect.fromLTWH(0, 0, panelWidth.toDouble(), panelHeight.toDouble()),
    const Radius.circular(borderRadius),
  );
  canvas.drawRRect(bgRRect, bgPaint);

  // ================= PANEL BORDER =================
  final borderPaint = Paint()
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.4
    ..color = Colors.white.withOpacity(0.22);
  canvas.drawRRect(bgRRect, borderPaint);

  // ================= MAP (CLEAR & SHARP) =================
  final mapBytes = await mapImage.readAsBytes();
  final codec = await ui.instantiateImageCodec(
    mapBytes,
    targetWidth: 900, // 🔥 sharp map
  );
  final frame = await codec.getNextFrame();

  final mapRect = RRect.fromRectAndRadius(
    const Rect.fromLTWH(
      outerPadding,
      (panelHeight - mapHeight) / 2,
      mapWidth,
      mapHeight,
    ),
    const Radius.circular(14),
  );

  canvas.save();
  canvas.clipRRect(mapRect);
  canvas.drawImageRect(
    frame.image,
    Rect.fromLTWH(
      0,
      0,
      frame.image.width.toDouble(),
      frame.image.height.toDouble(),
    ),
    mapRect.outerRect,
    Paint(),
  );
  canvas.restore();

  // Map border
  canvas.drawRRect(
    mapRect,
    Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withOpacity(0.3),
  );

  // ================= TEXT SAFE AREA =================
  const double textLeft = outerPadding + mapWidth + 20; // 🔥 gap from map
  const double textRightPadding = 15; // 🔥 RIGHT MARGIN

  const double textWidth = panelWidth - textLeft - textRightPadding;

  final textPainter = TextPainter(
    textDirection: TextDirection.ltr,
    maxLines: 6,
    ellipsis: '...',
    text: TextSpan(
      children: [
        // Address
        TextSpan(
          text: address,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 23, // 🔥 BIG & CLEAR
            height: 1.45,
            fontWeight: FontWeight.w600,
          ),
        ),


        const TextSpan(text: '\n\n'),

        // Lat Lng
        TextSpan(
          text:
          '📍 Lat: ${lat.toStringAsFixed(6)}, '
              'Lng: ${lng.toStringAsFixed(6)}\n',
          style: const TextStyle(
            fontSize: 20,
            height: 1.4,
            color: Colors.white70,
          ),
        ),

        // Date Time
        TextSpan(
          text: '🕒 $dateTime',
          style: const TextStyle(
            fontSize: 20,
            height: 1.4,
            color: Colors.white70,
          ),
        ),
      ],
    ),
  );

  textPainter.layout(maxWidth: textWidth);

  // 🔥 Vertical centering
  final double textY = (panelHeight - textPainter.height) / 2;

  textPainter.paint(
    canvas,
    Offset(textLeft, textY),
  );

  // ================= EXPORT =================
  final picture = recorder.endRecording();
  final img = await picture.toImage(panelWidth, panelHeight);
  final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
  final file = File('${dir.path}/gps_panel.png');
  await file.writeAsBytes(bytes!.buffer.asUint8List());
  return file;
}

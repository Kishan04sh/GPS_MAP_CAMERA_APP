/*
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';
import 'package:intl/intl.dart';

class StaticMapPreview extends StatelessWidget {
  final double lat;
  final double lng;
  final bool satellite;

  const StaticMapPreview({
    super.key,
    required this.lat,
    required this.lng,
    this.satellite = true,
  });

  @override
  Widget build(BuildContext context) {
    final mapType = satellite ? 'satellite' : 'roadmap';

    final url =
        'https://maps.googleapis.com/maps/api/staticmap'
        '?center=$lat,$lng'
        '&zoom=17'
        '&size=600x300'
        '&scale=2'
        '&maptype=$mapType'
        '&markers=color:red|$lat,$lng'
        '&key=${ApiURLConstants.mapApiKay}';

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: Image.network(
        url,
        height: 120,
        width: double.infinity,
        fit: BoxFit.cover,
        loadingBuilder: (c, w, p) {
          if (p == null) return w;
          return Container(
            height: 120,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(strokeWidth: 2),
          );
        },
        errorBuilder: (_, __, ___) {
          return Container(
            height: 120,
            color: Colors.black12,
            alignment: Alignment.center,
            child: const Text(
              'Map unavailable',
              style: TextStyle(color: Colors.white),
            ),
          );
        },
      ),
    );
  }
}

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// *************************************************************************

Future<File> downloadMap(String url, Directory dir) async {
  final file = File('${dir.path}/static_map.png');
  final client = HttpClient();

  try {
    final req = await client.getUrl(Uri.parse(url));
    final res = await req.close();
    final bytes = await consolidateHttpClientResponseBytes(res);
    await file.writeAsBytes(bytes);
    return file;
  } finally {
    client.close();
  }
}


*/


import 'dart:async';
import 'package:flutter/material.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';

class StaticMapPreview extends StatefulWidget {
  final double lat;
  final double lng;
  final bool satellite;

  const StaticMapPreview({
    super.key,
    required this.lat,
    required this.lng,
    this.satellite = true,
  });

  @override
  State<StaticMapPreview> createState() => _StaticMapPreviewState();
}

class _StaticMapPreviewState extends State<StaticMapPreview> {
  late final String _url;
  bool _hasError = false;

  @override
  void initState() {
    super.initState();
    final mapType = widget.satellite ? 'satellite' : 'roadmap';

    _url =
    'https://maps.googleapis.com/maps/api/staticmap'
        '?center=${widget.lat},${widget.lng}'
        '&zoom=17'
        '&size=600x300'
        '&scale=2'
        '&maptype=$mapType'
        '&markers=color:red|${widget.lat},${widget.lng}'
        '&key=${ApiURLConstants.mapApiKay}';
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: AspectRatio(
        aspectRatio: 1, // keeps map square & responsive
        child: _hasError ? _errorWidget() : _buildImage(),
      ),
    );
  }

  Widget _buildImage() {
    return Image.network(
      _url,
      fit: BoxFit.cover,

      /// 🔥 Prevent memory crash on low RAM phones
      cacheWidth: 600,
      filterQuality: FilterQuality.low,

      /// ⏳ Timeout if Google API hangs
      loadingBuilder: (context, child, progress) {
        if (progress == null) return child;

        return const Center(
          child: SizedBox(
            height: 22,
            width: 22,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        );
      },

      errorBuilder: (_, __, ___) {
        if (mounted) {
          Future.microtask(() => setState(() => _hasError = true));
        }
        return _errorWidget();
      },
    );
  }

  Widget _errorWidget() {
    return Container(
      color: Colors.black26,
      alignment: Alignment.center,
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.map_outlined, color: Colors.white70, size: 28),
          SizedBox(height: 6),
          Text(
            'Map unavailable',
            style: TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }
}


/// ****************************************************************************

String formatDateTime(DateTime dateTime) {
  return DateFormat('dd/MM/yyyy HH:mm').format(dateTime);
}

/// *************************************************************************

Future<File> downloadMap(String url, Directory dir) async {
  final filePath =
      '${dir.path}/static_map_${DateTime.now().millisecondsSinceEpoch}.png';

  final file = File(filePath);
  final client = HttpClient();

  try {
    final uri = Uri.parse(url);

    final request = await client
        .getUrl(uri)
        .timeout(const Duration(seconds: 10));

    final response = await request.close();

    // ❗ HTTP error handling
    if (response.statusCode != HttpStatus.ok) {
      throw HttpException(
        'Failed to download map. HTTP ${response.statusCode}',
        uri: uri,
      );
    }

    final bytes = await consolidateHttpClientResponseBytes(response);

    // ❗ Empty response protection
    if (bytes.isEmpty) {
      throw const FileSystemException('Downloaded map is empty');
    }

    await file.writeAsBytes(bytes, flush: true);

    debugPrint('Map downloaded: ${file.path}');
    return file;
  } on SocketException catch (e) {
    throw SocketException('No internet connection', osError: e.osError);
  } on FormatException {
    throw const FormatException('Invalid map URL');
  } on HttpException {
    rethrow; // already meaningful
  } on TimeoutException {
    throw TimeoutException('Map download timed out');
  } catch (e) {
    throw FileSystemException('Failed to save map file: $e');
  } finally {
    client.close(force: true);
  }
}

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

// import 'dart:ui';
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:geolocator/geolocator.dart';
// import '../../../../core/widgets/static_map_preview.dart';
//
// class LocationOverlayCard extends ConsumerWidget {
//   final Position? position;
//   final String? address;
//   final String time;
//
//   const LocationOverlayCard({
//     super.key,
//     required this.position,
//     required this.address,
//     required this.time,
//   });
//
//   /// Scale relative to 375px design width
//   double rs(BuildContext c, double v) => v * (MediaQuery.of(c).size.width / 375);
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     if (position == null) return const SizedBox.shrink();
//
//     final orientation = MediaQuery.of(context).orientation;
//     final isLandscape = orientation == Orientation.landscape;
//
//     // Fixed camera-style overlay size
//     final overlayWidth = isLandscape ? 300.0 : 350.0;
//     final overlayHeight = 100.0; // minHeight of the card
//
//     final mapSize = 80.0;
//     final padding = 10.0;
//     final radius = 14.0;
//     final gap = 8.0;
//
//     final titleSize = 14.0;
//     final infoSize = 12.0;
//     final metaSize = 11.0;
//
//     return ClipRRect(
//       borderRadius: BorderRadius.circular(radius),
//       child: BackdropFilter(
//         filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
//         child: Container(
//           width: overlayWidth,
//           constraints: BoxConstraints(
//             minHeight: overlayHeight,
//           ),
//           padding: EdgeInsets.all(padding * 0.6),
//           decoration: BoxDecoration(
//             color: Colors.black.withOpacity(0.55),
//             borderRadius: BorderRadius.circular(radius),
//             border: Border.all(color: Colors.white.withOpacity(0.18)),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               // Map Preview
//               ClipRRect(
//                 borderRadius: BorderRadius.circular(10),
//                 child: SizedBox(
//                   width: mapSize,
//                   height: mapSize,
//                   child: StaticMapPreview(
//                     lat: position!.latitude,
//                     lng: position!.longitude,
//                     satellite: true,
//                   ),
//                 ),
//               ),
//
//               SizedBox(width: gap),
//
//               // Text Info
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     Text(
//                       address?.trim().isNotEmpty == true
//                           ? address!
//                           : 'Fetching address…',
//                       maxLines: 3,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         color: Colors.white,
//                         fontSize: titleSize,
//                         fontWeight: FontWeight.w600,
//                         height: 1.25,
//                       ),
//                     ),
//                     SizedBox(height: gap * 0.7),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.place, color: Colors.white70, size: 14),
//                         SizedBox(width: 4),
//                         Flexible(
//                           child: Text(
//                             "${position!.latitude.toStringAsFixed(6)}, ${position!.longitude.toStringAsFixed(6)}",
//                             overflow: TextOverflow.ellipsis,
//                             style: TextStyle(
//                               fontSize: infoSize,
//                               color: Colors.white.withOpacity(.85),
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                     SizedBox(height: gap * 0.5),
//                     Row(
//                       mainAxisSize: MainAxisSize.min,
//                       children: [
//                         const Icon(Icons.access_time_rounded,
//                             color: Colors.white70, size: 13),
//                         SizedBox(width: 4),
//                         Text(
//                           time,
//                           style: TextStyle(
//                             fontSize: metaSize,
//                             color: Colors.white.withOpacity(.75),
//                           ),
//                         ),
//                       ],
//                     ),
//
//                     const Divider(),
//                   ],
//                 ),
//               ),
//
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../core/widgets/static_map_preview.dart';

class LocationOverlayCard extends ConsumerWidget {
  final Position? position;
  final String? address;
  final String time;

  const LocationOverlayCard({
    super.key,
    required this.position,
    required this.address,
    required this.time,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (position == null) return const SizedBox.shrink();

    final size = MediaQuery.of(context).size;
    final isLandscape = size.width > size.height;
    final overlayWidth = isLandscape ? size.width * 0.59 : size.width * 0.99;
    final mapSize = isLandscape ? 80.0 : 90.0;
    final radius = 14.0;
    final gap = 8.0;

    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: Container(
          width: overlayWidth,
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.50),
            borderRadius: BorderRadius.circular(radius),
            border: Border.all(color: Colors.white.withOpacity(0.18)),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              /// Map
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: mapSize,
                  height: mapSize,
                  child: StaticMapPreview(
                    lat: position!.latitude,
                    lng: position!.longitude,
                    satellite: true,
                  ),
                ),
              ),

              SizedBox(width: gap),

              /// Text info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      address?.trim().isNotEmpty == true
                          ? address!
                          : 'Fetching address…',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        height: 1.25,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place, color: Colors.white70, size: 14),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            "${position!.latitude.toStringAsFixed(6)}, "
                                "${position!.longitude.toStringAsFixed(6)}",
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white.withOpacity(.85),
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 4),

                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded, color: Colors.white70, size: 13),
                        const SizedBox(width: 4),
                        Text(
                          time,
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.white.withOpacity(.75),
                          ),
                        ),
                      ],
                    ),

                    const Divider(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

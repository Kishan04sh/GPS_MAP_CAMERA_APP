//
//
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:flutter_map/flutter_map.dart';
// import 'package:latlong2/latlong.dart';
// import 'package:geolocator/geolocator.dart';
//
// class FullImageView extends StatelessWidget {
//   final File file;
//   final Position? position;
//   final String? address;
//
//   const FullImageView({
//     super.key,
//     required this.file,
//     required this.position,
//     required this.address,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     final timestamp = DateTime.now().toLocal().toString().split('.')[0];
//     final size = MediaQuery.of(context).size;
//
//     return Scaffold(
//       backgroundColor: Colors.black,
//       body: SafeArea(
//         child: Stack(
//           children: [
//             /// BACK IMAGE
//             Positioned.fill(
//               child: InteractiveViewer(
//                 child: Image.file(file, fit: BoxFit.contain),
//               ),
//             ),
//
//             /// BACK BUTTON + SHARE
//             Positioned(
//               top: 10,
//               left: 10,
//               right: 10,
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   _circleButton(
//                     icon: Icons.arrow_back,
//                     onTap: () => Navigator.pop(context),
//                   ),
//                   _circleButton(
//                     icon: Icons.share,
//                     onTap: () {
//                       Share.shareXFiles(
//                         [XFile(file.path)],
//                         text:
//                         "Lat: ${position?.latitude ?? 'N/A'}\nLng: ${position?.longitude ?? 'N/A'}\nAddress: ${address ?? 'N/A'}\nTime: $timestamp",
//                       );
//                     },
//                   ),
//                 ],
//               ),
//             ),
//
//             /// INFO CARD (NO OVERFLOW)
//             Positioned(
//               left: 12,
//               right: 12,
//               bottom: 12,
//               child: Container(
//                 padding: const EdgeInsets.all(14),
//                 constraints: BoxConstraints(
//                   maxHeight: size.height * 0.35, // responsive height limit
//                 ),
//                 decoration: BoxDecoration(
//                   color: Colors.black.withOpacity(0.55),
//                   borderRadius: BorderRadius.circular(16),
//                 ),
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   children: [
//                     /// MINI MAP
//                     Flexible(
//                       flex: 3,
//                       child: ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Container(
//                           decoration: BoxDecoration(
//                             border: Border.all(color: Colors.white24, width: 1),
//                           ),
//                           child: position == null
//                               ? const Center(
//                             child: Text("Location not found",
//                                 style:
//                                 TextStyle(color: Colors.white70)),
//                           )
//                               : FlutterMap(
//                             options: MapOptions(
//                               initialCenter: LatLng(
//                                 position!.latitude,
//                                 position!.longitude,
//                               ),
//                               initialZoom: 16,
//                               interactionOptions:
//                               const InteractionOptions(
//                                 flags:
//                                 InteractiveFlag.none, // disable zoom
//                               ),
//                             ),
//                             children: [
//                               TileLayer(
//                                 urlTemplate:
//                                 "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
//                               ),
//                               MarkerLayer(
//                                 markers: [
//                                   Marker(
//                                     point: LatLng(
//                                       position!.latitude,
//                                       position!.longitude,
//                                     ),
//                                     width: 40,
//                                     height: 40,
//                                     child: const Icon(
//                                       Icons.location_on,
//                                       color: Colors.red,
//                                       size: 36,
//                                     ),
//                                   ),
//                                 ],
//                               )
//                             ],
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     /// ADDRESS (SCROLLABLE)
//                     Flexible(
//                       flex: 2,
//                       child: SingleChildScrollView(
//                         physics: const BouncingScrollPhysics(),
//                         child: Text(
//                           address ?? "Fetching address...",
//                           style: const TextStyle(
//                             fontSize: 14,
//                             color: Colors.white,
//                             height: 1.4,
//                             fontWeight: FontWeight.w600
//                           ),
//                         ),
//                       ),
//                     ),
//
//                     const SizedBox(height: 10),
//
//                     /// LAT / LNG + TIME
//                     Column(
//                       children: [
//                         Row(
//                           //mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Chip(
//                               backgroundColor: Colors.indigo,
//                               label: Text(
//                                 "Lat: ${position?.latitude.toStringAsFixed(5) ?? 'N/A'}",
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//                             const SizedBox(width: 6),
//                             Chip(
//                               backgroundColor: Colors.indigo,
//                               label: Text(
//                                 "Lng: ${position?.longitude.toStringAsFixed(5) ?? 'N/A'}",
//                                 style: const TextStyle(color: Colors.white),
//                               ),
//                             ),
//
//                           ],
//                         ),
//
//                         const SizedBox(height: 10,),
//                         Text(
//                           timestamp,
//                           style: const TextStyle(
//                             color: Colors.white70,
//                             fontSize: 14,
//                             fontWeight: FontWeight.w600
//                           ),
//                         )
//                       ],
//                     ),
//
//
//
//                   ],
//                 ),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   /// Round button for back/share
//   Widget _circleButton({required IconData icon, required Function() onTap}) {
//     return InkWell(
//       onTap: onTap,
//       borderRadius: BorderRadius.circular(40),
//       child: Container(
//         padding: const EdgeInsets.all(10),
//         decoration: BoxDecoration(
//           color: Colors.black.withOpacity(0.4),
//           shape: BoxShape.circle,
//           border: Border.all(color: Colors.white30),
//         ),
//         child: Icon(icon, color: Colors.white, size: 22),
//       ),
//     );
//   }
// }


import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class FullImageView extends StatelessWidget {
  final File file;
  final Position? position;
  final String? address;

  const FullImageView({
    super.key,
    required this.file,
    required this.position,
    required this.address,
  });

  @override
  Widget build(BuildContext context) {
    final timestamp = DateTime.now().toLocal().toString().split('.')[0];
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            /// BACKGROUND IMAGE WITH ZOOM
            Positioned.fill(
              child: InteractiveViewer(
                child: Image.file(file, fit: BoxFit.contain),
              ),
            ),

            /// TOP BUTTONS (BACK + SHARE)
            Positioned(
              top: 10,
              left: 12,
              right: 12,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _circleButton(
                    icon: Icons.arrow_back,
                    onTap: () => Navigator.pop(context),
                  ),
                  _circleButton(
                    icon: Icons.share,
                    onTap: () {
                      Share.shareXFiles(
                        [XFile(file.path)],
                        text:
                        "Lat: ${position?.latitude ?? 'N/A'}\nLng: ${position?.longitude ?? 'N/A'}\nAddress: ${address ?? 'N/A'}\nTime: $timestamp",
                      );
                    },
                  ),
                ],
              ),
            ),

            /// BOTTOM GLASS CARD
            Positioned(
              left: 12,
              right: 12,
              bottom: 12,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(color: Colors.white.withOpacity(0.15)),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        /// MAP
                        Container(
                          height: size.height * 0.18,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: Colors.white.withOpacity(0.2)),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(18),
                            child: position == null
                                ? const Center(
                              child: Text(
                                "Location not found",
                                style: TextStyle(color: Colors.white70),
                              ),
                            )
                                : FlutterMap(
                              options: MapOptions(
                                initialCenter: LatLng(
                                  position!.latitude,
                                  position!.longitude,
                                ),
                                initialZoom: 16,
                                interactionOptions:
                                const InteractionOptions(
                                  flags: InteractiveFlag.none,
                                ),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                  "https://tile.openstreetmap.org/{z}/{x}/{y}.png",
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point: LatLng(
                                        position!.latitude,
                                        position!.longitude,
                                      ),
                                      width: 45,
                                      height: 45,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.redAccent,
                                        size: 40,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// ADDRESS
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(Icons.location_pin,
                                color: Colors.white70, size: 20),
                            SizedBox(width: 6),
                            Text(
                              "Address",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                                fontSize: 15,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),

                        Container(
                          constraints:
                          BoxConstraints(maxHeight: size.height * 0.12),
                          child: SingleChildScrollView(
                            child: Text(
                              address ?? "Fetching address...",
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                height: 1.3,
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 14),

                        /// LAT - LNG ROW
                        Row(
                          children: [
                            _pill("Lat", position?.latitude),
                            const SizedBox(width: 10),
                            _pill("Lng", position?.longitude),
                          ],
                        ),

                        const SizedBox(height: 12),

                        /// TIME
                        Row(
                          children: [
                            const Icon(Icons.access_time_rounded,
                                size: 18, color: Colors.white70),
                            const SizedBox(width: 6),
                            Text(
                              timestamp,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            )
                          ],
                        )
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 🔵 NICE ROUND BUTTON
  Widget _circleButton({required IconData icon, required Function() onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(40),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(0.12),
          border: Border.all(color: Colors.white30),
        ),
        child: Icon(icon, color: Colors.white, size: 22),
      ),
    );
  }

  /// 🔥 MODERN LAT/LNG PILL
  Widget _pill(String title, num? value) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: Colors.indigoAccent.withOpacity(0.8),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            const SizedBox(height: 2),
            Text(
              value != null ? value.toStringAsFixed(5) : "N/A",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

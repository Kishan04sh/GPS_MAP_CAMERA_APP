
import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../controller/address_controller.dart';
import '../controller/camera_controller.dart';
import '../controller/location_controller.dart';
import 'full_image_view.dart';

final lastImageProvider = StateProvider<File?>((ref) => null);

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});
  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      try {
        await ref.read(locationProvider.notifier).initLocation();
        final cams = await availableCameras();
        await ref.read(cameraProvider.notifier).initCamera(cams);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(content: Text("Camera Init Error: $e")));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final pos = ref.watch(locationProvider);
    final addr = ref.watch(addressProvider);
    final camCtrl = ref.watch(cameraProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          /// CAMERA PREVIEW
          Positioned.fill(
            child: camCtrl == null
                ? const Center(child: CircularProgressIndicator(color: Colors.white))
                : CameraPreview(camCtrl),
          ),

          /// TOP TITLE
          Positioned(
            top: 45,
            left: 20,
            child: Text(
              "GeoProof Camera",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.8),
                    blurRadius: 12,
                  ),
                ],
              ),
            ),
          ),

          /// BOTTOM GLASS PANEL → NOW FIXED! FULLY COVER
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.95),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(26),
                  topRight: Radius.circular(26),
                ),
              ),
              child: SafeArea(   /// ← SPACE ISSUE FIXED
                top: false,
                child: Column(
                  mainAxisSize: MainAxisSize.min,

                  children: [
                    /// MAP + ADDRESS
                    Row(
                      children: [
                        Container(
                          width: 110,
                          height: 110,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: Colors.indigo, width: 2),
                          ),
                          child: pos == null
                              ? const Center(child: CircularProgressIndicator())
                              : ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: FlutterMap(
                              options: MapOptions(
                                initialCenter:
                                LatLng(pos.latitude, pos.longitude),
                                initialZoom: 16,
                                interactionOptions:
                                const InteractionOptions(
                                    flags: InteractiveFlag.none),
                              ),
                              children: [
                                TileLayer(
                                  urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                ),
                                MarkerLayer(
                                  markers: [
                                    Marker(
                                      point:
                                      LatLng(pos.latitude, pos.longitude),
                                      width: 40,
                                      height: 40,
                                      child: const Icon(
                                        Icons.location_on,
                                        color: Colors.red,
                                        size: 35,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(width: 14),

                        Expanded(
                          child: Text(
                            addr ??
                                (pos == null
                                    ? "Getting GPS..."
                                    : "Fetching address..."),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.black87,
                              height: 1.3,
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 4,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 14),

                    /// LAT - LNG ROW
                    Row(
                      children: [
                        const Icon(Icons.location_on,
                        size: 18, color: Colors.indigo),

                        const SizedBox(width: 6),
                        Text(
                          "Lat: ${pos!.latitude}",
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),

                        const SizedBox(width: 10),

                        Text(
                          "Lng: ${pos!.latitude}",
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),

                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 18, color: Colors.indigo),
                        const SizedBox(width: 6),
                        Text(
                          DateTime.now().toString().split('.')[0],
                          style: const TextStyle(
                            color: Colors.indigo,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      ],
                    ),

                    const SizedBox(height: 18),
                    
                    const Divider(color: Colors.grey,),
                    /// CAPTURE BUTTON
                    Center(
                      child: GestureDetector(
                        onTap: () async {
                          if (camCtrl == null) return;

                          final imgFile = await ref
                              .read(cameraProvider.notifier)
                              .captureAndSave();

                          if (!mounted || imgFile == null) return;

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => FullImageView(
                                file: imgFile,
                                position: pos,
                                address: addr,
                              ),
                            ),
                          );
                        },
                        child: Container(
                          width: 85,
                          height: 85,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xff4c61ff),
                                Color(0xff7184ff),
                              ],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.indigo.withOpacity(0.4),
                                blurRadius: 12,
                                offset: const Offset(0, 4),
                              )
                            ],
                          ),
                          child: const Icon(
                            Icons.camera_alt,
                            color: Colors.white,
                            size: 34,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/widgets/app_error_screen.dart';
import '../../../core/widgets/inline_animated_loader.dart';
import '../viewmodel/map_controller.dart';
import '../model/map_state.dart';

class MapTab extends ConsumerStatefulWidget {
  const MapTab({super.key});

  @override
  ConsumerState<MapTab> createState() => _MapTabState();
}

class _MapTabState extends ConsumerState<MapTab> {
  GoogleMapController? controller;

  @override
  void initState() {
    super.initState();
    // Load current location on init
    Future.microtask(() {
      ref.read(mapControllerProvider.notifier).loadCurrentLocation();
    });
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(mapControllerProvider);
    final notifier = ref.read(mapControllerProvider.notifier);

    // ===================== LOADING =====================
    if (state.status == MapStatus.loading ||
        state.status == MapStatus.initial) {
      return const Center(
        child: InlineAnimatedLoader(size: 48),
      );
    }

    // ===================== ERROR =====================
    if (state.status == MapStatus.error) {
      return AppErrorScreen(
        message: _mapErrorMessage(state.error),
      );
    }

    // ===================== SAFETY CHECK =====================
    if (state.currentLocation == null) {
      return const AppErrorScreen(
        message: 'Unable to fetch current location',
      );
    }

    // Animate camera to current location if controller is ready
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (controller != null) {
        controller!.animateCamera(
          CameraUpdate.newLatLng(state.currentLocation!),
        );
      }
    });

    return Stack(
      children: [
        GoogleMap(
          initialCameraPosition: CameraPosition(
            target: state.currentLocation!,
            zoom: 16,
          ),
          mapType: state.mapType == MapTypeMode.normal
              ? MapType.normal
              : MapType.satellite,
          myLocationEnabled: true,
          markers: _buildMarkers(state),
          onMapCreated: (c) => controller = c,
        ),

        // ===================== FABs =====================
        _fab(
          top: 70,
          icon: Icons.my_location,
          tooltip: 'Refresh Location',
          onTap: notifier.refreshLocation,
        ),

        _fab(
          top: 135,
          icon: Icons.layers,
          tooltip: 'Toggle Map Type',
          onTap: notifier.toggleMapType,
        ),

        _fab(
          top: 200,
          icon: Icons.camera_alt,
          tooltip: 'Open Camera',
          onTap: () {
            // Implement camera functionality
          },
        ),
      ],
    );
  }

  Set<Marker> _buildMarkers(MapState state) {
    final markers = <Marker>{};

    // User location marker
    markers.add(
      Marker(
        markerId: const MarkerId('me'),
        position: state.currentLocation!,
      ),
    );

    // Photo markers
    for (final photo in state.photoMarkers) {
      markers.add(
        Marker(
          markerId: MarkerId(photo.imagePath), // Ensure unique
          position: photo.position,
          icon: BitmapDescriptor.defaultMarkerWithHue(
            BitmapDescriptor.hueAzure,
          ),
        ),
      );
    }

    return markers;
  }

  Widget _fab({
    required double top,
    required IconData icon,
    required VoidCallback onTap,
    String? tooltip,
  }) {
    return Positioned(
      right: 12,
      top: top,
      child: FloatingActionButton(
        heroTag: 'fab_$top', // Unique hero tag
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.primary,
        onPressed: onTap,
        tooltip: tooltip,
        child: Icon(icon),
      ),
    );
  }

  String _mapErrorMessage(String? error) {
    if (error == null) return 'Something went wrong';

    if (error.contains('disabled')) {
      return 'Location service is disabled.\nPlease enable GPS.';
    }

    if (error.contains('deniedForever')) {
      return 'Location permission permanently denied.\nEnable it from settings.';
    }

    if (error.contains('denied')) {
      return 'Location permission denied.\nPlease allow access.';
    }

    return 'Unable to fetch location.\nPlease try again.';
  }
}

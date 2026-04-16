import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../../core/utils/location_utils.dart';
import '../../../core/utils/permission_utils.dart';

final permissionStateProvider =
StateNotifierProvider<PermissionController, PermissionState>(
      (ref) => PermissionController(),
);

class PermissionController extends StateNotifier<PermissionState> {
  PermissionController() : super(PermissionState.initial()) {
    _init();
  }

  StreamSubscription<ServiceStatus>? _serviceSub;
  bool _checkedOnce = false;

  /// 🔥 INIT (VERY IMPORTANT)
  Future<void> _init() async {
    await _checkLocationServiceOnce();
    _listenLocationService();
    await checkOnAppStart(); // 👈 MUST
  }

  /// ✅ ONE-TIME GPS CHECK (FIXES YOUR ISSUE)
  Future<void> _checkLocationServiceOnce() async {
    final enabled = await LocationServiceUtil.isServiceEnabled();
    state = state.copyWith(locationServiceEnabled: enabled);
  }

  /// 🔄 REAL-TIME GPS LISTENER
  void _listenLocationService() {
    _serviceSub =
        Geolocator.getServiceStatusStream().listen((status) {
          state = state.copyWith(
            locationServiceEnabled: status == ServiceStatus.enabled,
          );
        });
  }

  /// 🔐 App start permission check
  Future<void> checkOnAppStart() async {
    if (_checkedOnce) return;
    _checkedOnce = true;

    state = state.copyWith(isChecking: true);

    await loadStatus();

    if (!state.allGranted) {
      await requestPermissions();
    }

    state = state.copyWith(isChecking: false); // 👈 MOST IMPORTANT
  }


  /// 🔎 Permission status
  Future<void> loadStatus() async {
    final camera = await PermissionUtil.isCameraGranted();
    final location = await PermissionUtil.isLocationGranted();

    state = state.copyWith(
      cameraGranted: camera,
      locationGranted: location,
    );
  }

  /// 📥 Request permissions
  Future<void> requestPermissions() async {
    await PermissionUtil.requestAll();
    await loadStatus();
  }

  /// ⚙️ Open app permission settings
  Future<void> openAppSettings() async {
    await PermissionUtil.openSettings();
  }

  /// 📍 Open GPS settings
  Future<void> openLocationSettings() async {
    await LocationServiceUtil.openLocationSettings();
  }

  @override
  void dispose() {
    _serviceSub?.cancel();
    super.dispose();
  }
}

/// ****************************************************************************************
class PermissionState {
  final bool isChecking;
  final bool cameraGranted;
  final bool locationGranted;
  final bool locationServiceEnabled;

  const PermissionState({
    required this.isChecking,
    required this.cameraGranted,
    required this.locationGranted,
    required this.locationServiceEnabled,
  });

  factory PermissionState.initial() => const PermissionState(
    isChecking: true,
    cameraGranted: false,
    locationGranted: false,
    locationServiceEnabled: false,
  );

  bool get allGranted =>
      cameraGranted && locationGranted && locationServiceEnabled;

  PermissionState copyWith({
    bool? isChecking,
    bool? cameraGranted,
    bool? locationGranted,
    bool? locationServiceEnabled,
  }) {
    return PermissionState(
      isChecking: isChecking ?? this.isChecking,
      cameraGranted: cameraGranted ?? this.cameraGranted,
      locationGranted: locationGranted ?? this.locationGranted,
      locationServiceEnabled:
      locationServiceEnabled ?? this.locationServiceEnabled,
    );
  }
}


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_map_camera/core/widgets/permission_blocked_view.dart';
import '../../feature/settings/viewmodal/permission_controller.dart';
import '../routing/route_names.dart';

class PermissionGateScreen extends ConsumerWidget {
  const PermissionGateScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(permissionStateProvider);

    /// while checking
    if (state.isChecking) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    /// not granted → show UI
    if (!state.allGranted) {
      return const PermissionBlockedView();
    }

    /// granted → go home automatically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(RouteNames.home);
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

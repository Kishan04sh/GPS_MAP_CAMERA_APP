
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../feature/settings/viewmodal/permission_controller.dart';

class PermissionBlockedView extends ConsumerStatefulWidget {
  const PermissionBlockedView({super.key});

  @override
  ConsumerState<PermissionBlockedView> createState() =>
      _PermissionBlockedViewState();
}

class _PermissionBlockedViewState
    extends ConsumerState<PermissionBlockedView> with SingleTickerProviderStateMixin {
  late AnimationController _iconController;
  late Animation<double> _iconAnimation;

  @override
  void initState() {
    super.initState();
    _iconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
    _iconAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _iconController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _iconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(permissionStateProvider);
    final controller = ref.read(permissionStateProvider.notifier);

    final media = MediaQuery.of(context).size;

    // Determine icon based on GPS & permission state
    final iconData = !state.locationServiceEnabled
        ? Icons.location_off
        : !state.allGranted
        ? Icons.location_on
        : Icons.check_circle_outline;

    final iconColor = !state.locationServiceEnabled
        ? Colors.redAccent
        : !state.allGranted
        ? Colors.orange
        : Colors.green;

    final messageText = !state.locationServiceEnabled
        ? 'Please enable Location (GPS) to continue.'
        : 'Camera and Location permissions are required to proceed.';

    final buttonText = !state.locationServiceEnabled
        ? 'Enable Location'
        : 'Open App Settings';

    final buttonColor = !state.locationServiceEnabled
        ? Colors.orangeAccent
        : AppColors.primary;

    return Container(
      width: double.infinity,
      height: double.infinity,
      decoration: const BoxDecoration(
        gradient: AppColors.blueSoftGradient,
      ),
      child: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Soft floating circle behind card

            Padding(
              padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 30),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ScaleTransition(
                    scale: _iconAnimation,
                    child: Icon(
                      iconData,
                      size: 80,
                      color: iconColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Permissions Required',
                    style: TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.w800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    messageText,
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[800],
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () {
                        if (!state.locationServiceEnabled) {
                          controller.openLocationSettings();
                        } else {
                          controller.openAppSettings();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: buttonColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 8,
                        shadowColor: Colors.black45,
                      ),
                      child: Text(
                        buttonText,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextButton(
                    onPressed: () async {
                      await controller.checkOnAppStart();
                    },
                    child: Text(
                      'Retry Permissions',
                      style: TextStyle(
                        color: AppColors.primary.withOpacity(0.9),
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

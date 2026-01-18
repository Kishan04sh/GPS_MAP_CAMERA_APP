
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/widgets/app_animated_loader.dart';
import '../../auth/viewmodel/auth_view_model.dart';
import '../viewmodal/permission_controller.dart';

class SettingsTab extends ConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(permissionStateProvider);
    final controller = ref.read(permissionStateProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.blueActionGradient.colors.first.withOpacity(0.05),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 12),

            // ================= Permissions Section =================
            Text(
              'App Permissions',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            PermissionTile(
              title: 'Camera Permission',
              granted: state.cameraGranted,
              onTap: controller.requestPermissions,
            ),
            const SizedBox(height: 12),
            PermissionTile(
              title: 'Location Permission',
              granted: state.locationGranted,
              onTap: controller.requestPermissions,
            ),
            const SizedBox(height: 16),

            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Open App Settings'),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: controller.openAppSettings,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              tileColor: Colors.white,
              contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            ),

            const Divider(height: 32, thickness: 1),

            // ================= Logout Section =================
            Text(
              'Account',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),

            const LogoutTile(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ================= Modern Permission Tile =================
class PermissionTile extends StatelessWidget {
  final String title;
  final bool granted;
  final VoidCallback onTap;

  const PermissionTile({
    super.key,
    required this.title,
    required this.granted,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: granted ? Colors.green.shade50 : Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: granted ? Colors.green.shade200 : Colors.red.shade200,
          width: 1,
        ),
      ),
      child: ListTile(
        leading: CircleAvatar(
          radius: 18,
          backgroundColor: granted ? Colors.green : Colors.red,
          child: Icon(
            granted ? Icons.check : Icons.close,
            size: 20,
            color: Colors.white,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            color: Colors.grey.shade800,
          ),
        ),
        subtitle: Text(
          granted ? 'Granted' : 'Not granted',
          style: TextStyle(
            color: granted ? Colors.green.shade700 : Colors.red.shade700,
          ),
        ),
        trailing: Switch(
          value: granted,
          onChanged: (_) {
            if (!granted) onTap();
          },
          activeColor: Colors.green,
          inactiveThumbColor: Colors.redAccent,
        ),
      ),
    );
  }
}


/// *************************************************************************

class LogoutTile extends ConsumerWidget {
  const LogoutTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.red.shade200,
          width: 1,
        ),
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () async {
          // 1️⃣ Show loader immediately
          AppAnimatedLoader.show(
            context,
            message: 'Signing you out…',
          );

          try {
            // 2️⃣ Perform logout
            await ref.read(authViewModelProvider.notifier).logout();

            // 3️⃣ Navigate after logout
            if (context.mounted) {
              context.go(RouteNames.login);
            }
          } finally {
            // 4️⃣ Always hide loader (success or error)
            if (context.mounted) {
              AppAnimatedLoader.hide(context);
            }
          }
        },
        // onTap: () async {
        //   await ref.read(authViewModelProvider.notifier).logout();
        //   if (context.mounted) {
        //     context.go(RouteNames.login);
        //   }
        // },
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              /// LEADING ICON (same pattern as PermissionTile)
              CircleAvatar(
                radius: 18,
                backgroundColor: Colors.red,
                child: Icon(
                  Icons.logout,
                  size: 18,
                  color: Colors.white,
                ),
              ),

              SizedBox(width: 12),

              /// TEXT CONTENT
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Logout',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                        fontSize: 14,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Sign out from your account',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.redAccent,
                      ),
                    ),
                  ],
                ),
              ),

              /// TRAILING ICON
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Colors.red,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

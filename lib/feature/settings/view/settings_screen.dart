
/*
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodal/permission_controller.dart';
import '../widgets/logout_tile.dart';

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

            // ✅ PROFILE HEADER
            const ProfileHeader(
              name: "Kishan User",
              email: "kishan@gmail.com",
            ),


            const SizedBox(height: 12),


            // ================= PROFILE DETAILS =================
            _sectionTitle("Profile Details"),
            const SizedBox(height: 10),

            _infoCard([
              _infoRow(Icons.location_city, "City", "Navi Mumbai"),
              _divider(),
              _infoRow(Icons.work, "Profession", "Flutter Developer"),
              _divider(),
              _infoRow(Icons.pin_drop, "Pincode", "400701"),
              _divider(),
              _infoRow(Icons.calendar_today, "Joined", "2026-02-16"),
            ]),
            const SizedBox(height: 12),
            // ================= PERMISSIONS =================
            _sectionTitle("App Permissions"),
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

            // ================= ACCOUNT =================
            _sectionTitle("Account"),
            const SizedBox(height: 12),
            const LogoutTile(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.grey.shade800,
      ),
    );
  }

  /// ================= CARD CONTAINER =================
  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  /// ================= INFO ROW (OVERFLOW SAFE) =================
  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),

          const SizedBox(width: 10),

          Expanded(
            flex: 3,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// ================= DIVIDER =================
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.grey.shade200,
    );
  }



}
*/



import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../viewmodal/permission_controller.dart';
import '../viewmodal/setting_controller.dart';
import '../widgets/logout_tile.dart';
import '../widgets/permisstion_tile_widget.dart';
import '../widgets/profile_widgets.dart';


class SettingsTab extends ConsumerStatefulWidget {
  const SettingsTab({super.key});

  @override
  ConsumerState<SettingsTab> createState() => _SettingsTabState();
}

class _SettingsTabState extends ConsumerState<SettingsTab> {

  @override
  void initState() {
    super.initState();

    // ✅ Load user once
    Future.microtask(() {
      ref.read(settingsControllerProvider.notifier).getUser();
    });
  }

  @override
  Widget build(BuildContext context) {
    final permissionState = ref.watch(permissionStateProvider);
    final permissionController = ref.read(permissionStateProvider.notifier);
    final user = ref.watch(userProvider);
    final loadingState = ref.watch(settingsControllerProvider);

    return Scaffold(
      backgroundColor:
      AppColors.blueActionGradient.colors.first.withOpacity(0.05),
      body: SafeArea(
        child: loadingState is AsyncLoading
            ? const Center(child: CircularProgressIndicator())
            : user == null
            ? const Center(child: Text("No user data found"))
            : ListView(
          padding: const EdgeInsets.all(16),
          children: [

            const SizedBox(height: 12),

            // ================= PROFILE HEADER =================
            ProfileHeader(
              name: user.name,
              email: user.email,
            ),

            const SizedBox(height: 16),

            // ================= PROFILE DETAILS =================
            _sectionTitle("Profile Details"),
            const SizedBox(height: 10),

            _infoCard([
              _infoRow(Icons.location_city, "City", user.city),
              _divider(),
              _infoRow(Icons.work, "Profession", user.profession),
              _divider(),
              _infoRow(Icons.pin_drop, "Pincode", user.pincode),
              _divider(),
              _infoRow(Icons.calendar_today, "Joined", user.formattedDate),
            ]),

            const SizedBox(height: 16),

            // ================= PERMISSIONS =================
            _sectionTitle("App Permissions"),
            const SizedBox(height: 10),

            PermissionTile(
              title: 'Camera Permission',
              granted: permissionState.cameraGranted,
              onTap: permissionController.requestPermissions,
            ),

            const SizedBox(height: 12),

            PermissionTile(
              title: 'Location Permission',
              granted: permissionState.locationGranted,
              onTap: permissionController.requestPermissions,
            ),

            const SizedBox(height: 12),

            _settingsTile(
              icon: Icons.settings,
              title: "Open App Settings",
              onTap: permissionController.openAppSettings,
            ),

            const SizedBox(height: 20),

            // ================= ACCOUNT =================
            _sectionTitle("Account"),
            const SizedBox(height: 10),

            const LogoutTile(),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  // ================= SECTION TITLE =================
  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: Colors.grey.shade800,
      ),
    );
  }

  // ================= CARD =================
  Widget _infoCard(List<Widget> children) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(children: children),
    );
  }

  // ================= INFO ROW =================
  Widget _infoRow(IconData icon, String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: AppColors.primary),

          const SizedBox(width: 10),

          Expanded(
            flex: 3,
            child: Text(
              title,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),

          const SizedBox(width: 8),

          Expanded(
            flex: 2,
            child: Text(
              value,
              textAlign: TextAlign.right,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ================= DIVIDER =================
  Widget _divider() {
    return Divider(
      height: 1,
      thickness: 0.8,
      color: Colors.grey.shade200,
    );
  }

  // ================= SETTINGS TILE =================
  Widget _settingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: Icon(icon, color: AppColors.primary),
        title: Text(title),
        trailing: const Icon(Icons.arrow_forward_ios, size: 14),
        onTap: onTap,
      ),
    );
  }
}


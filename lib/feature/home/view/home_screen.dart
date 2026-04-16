
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/permission_blocked_view.dart';
import '../../capture/presentation/screens/capture_screen.dart';
import '../../gallery/view/gallery_screen.dart';
import '../../map/view/map_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../../settings/viewmodal/permission_controller.dart';
import '../widgets/bottom_nav_bar.dart';

final bottomNavIndexProvider = StateProvider<int>((ref)=> 0);

/// ***************HomeScreen************************************************************

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<String> _tabTitles = [
    'Home',
    'Gallery',
    'Map',
    'Settings',
  ];

  static final List<Widget> _pages = [
    // const HomeTab(),
    const CaptureScreen(),
    const GalleryTab(),
    const MapTab(),
    const SettingsTab(),
  ];


  /// ***************************************************************

  // @override
  // void initState() {
  //   super.initState();
  //   _bootHardware();
  // }


  /// *****************_bootHardware**************************************

  // Future<void> _bootHardware() async {
  //   Future.microtask(() async {
  //     try {
  //       await ref.read(captureProvider.notifier).initialize();
  //       await ref.read(locationProvider.notifier).initLocation();
  //     } catch (e) {
  //       debugPrint("Hardware boot failed: $e");
  //     }
  //   });
  // }


/// *****************************************************************************

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final permissionState = ref.watch(permissionStateProvider);
    final safeIndex = currentIndex.clamp(0, _pages.length - 1);


    return Scaffold(
      // appBar: CommonAppBar(
      //   title: _tabTitles[safeIndex],
      // ),

      appBar: safeIndex == 0 ? null : CommonAppBar(title: _tabTitles[safeIndex]),

      /// ✅ CLEAN PERMISSION HANDLING (NO FLICKER)
      body: SafeArea(
        child: permissionState.isChecking
            ? const Center(
          child: CircularProgressIndicator(strokeWidth: 2),
        )
            : permissionState.allGranted
            ? IndexedStack(
          index: safeIndex,
          children: _pages,
        )
            :  const PermissionBlockedView(),
      ),

      bottomNavigationBar: BottomNavBar(
        pagesLength: _pages.length,
      ),
    );
  }
}

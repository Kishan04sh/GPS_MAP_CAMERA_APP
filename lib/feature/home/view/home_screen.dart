
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/widgets/common_app_bar.dart';
import '../../../core/widgets/permission_blocked_view.dart';
import '../../gallery/view/gallery_screen.dart';
import '../../map/view/map_screen.dart';
import '../../settings/view/settings_screen.dart';
import '../../settings/viewmodal/permission_controller.dart';
import '../services/home_service.dart';
import '../widgets/bottom_nav_bar.dart';
import 'home_tab.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  static const List<String> _tabTitles = [
    'Home',
    'Gallery',
    'Map',
    'Settings',
  ];

  static final List<Widget> _pages = [
    const HomeTab(),
    const GalleryTab(),
    const MapTab(),
    const SettingsTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final currentIndex = ref.watch(bottomNavIndexProvider);
    final permissionState = ref.watch(permissionStateProvider);
    final safeIndex = currentIndex.clamp(0, _pages.length - 1);


    return Scaffold(

      // appBar: AppBar(
      //   elevation: 3,
      //   automaticallyImplyLeading: false,
      //   backgroundColor: Colors.transparent,
      //   titleSpacing: 0,
      //   flexibleSpace: Container(
      //     decoration: const BoxDecoration(
      //       gradient: AppColors.blueActionGradient,
      //     ),
      //   ),
      //   title: Row(
      //     children: [
      //       const SizedBox(width: 15),
      //       Expanded(
      //         child: Text(
      //           _tabTitles[safeIndex],
      //           overflow: TextOverflow.ellipsis,
      //           style: const TextStyle(
      //             color: Colors.white,
      //             fontSize: 22,
      //             fontWeight: FontWeight.w700,
      //           ),
      //         ),
      //       ),
      //       Row(
      //         children: [
      //           const Icon(
      //             Icons.wb_sunny_outlined,
      //             color: Color(0xFFFFD54F),
      //             size: 24,
      //           ),
      //           const SizedBox(width: 8),
      //           Column(
      //             crossAxisAlignment: CrossAxisAlignment.end,
      //             mainAxisAlignment: MainAxisAlignment.center,
      //             children: [
      //               Text(
      //                 formattedDate,
      //                 style: const TextStyle(
      //                   color: Colors.white,
      //                   fontSize: 14,
      //                   fontWeight: FontWeight.w500,
      //                 ),
      //               ),
      //               Text(
      //                 weekDay,
      //                 style: TextStyle(
      //                   color: Colors.white.withOpacity(0.85),
      //                   fontSize: 12,
      //                 ),
      //               ),
      //             ],
      //           ),
      //           const SizedBox(width: 16),
      //         ],
      //       ),
      //     ],
      //   ),
      // ),

      appBar: CommonAppBar(
        title: _tabTitles[safeIndex],
      ),

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

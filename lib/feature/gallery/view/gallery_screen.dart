//
// import 'package:flutter/material.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import '../../../core/constants/app_colors.dart';
// import '../../../core/utils/media_utils.dart';
// import '../../../core/widgets/state_place_holder.dart';
// import '../modal/gallery_state.dart';
// import '../view_modal/gallery_controller.dart';
// import '../view/gallery_preview_screen.dart';
// import '../widgets/gallery_grid_card.dart';
//
// class GalleryTab extends ConsumerWidget {
//   const GalleryTab({super.key});
//
//   @override
//   Widget build(BuildContext context, WidgetRef ref) {
//     final state = ref.watch(galleryViewModelProvider);
//     final vm = ref.read(galleryViewModelProvider.notifier);
//
//     return Stack(
//       children: [
//         Scaffold(
//           backgroundColor:
//           AppColors.blueActionGradient.colors.first.withOpacity(0.05),
//           body: RefreshIndicator(
//             onRefresh: vm.fetchGallery,
//             child: _buildBody(context, state, vm),
//           ),
//         ),
//
//         // GLOBAL LOADER
//         if (state.isLoading)
//           const Positioned.fill(
//             child: ColoredBox(
//               color: Colors.black26,
//               child: Center(child: CircularProgressIndicator()),
//             ),
//           ),
//       ],
//     );
//   }
//
//   Widget _buildBody(BuildContext context, GalleryState state, GalleryViewModel vm) {
//     if (state.error != null) {
//       return StatePlaceholder.error(
//         message: state.error!,
//         onRetry: vm.fetchGallery,
//       );
//     }
//
//     if (state.items.isEmpty) {
//       return StatePlaceholder.empty(onRetry: vm.fetchGallery);
//     }
//
//     // ===== GRID STATE =====
//     return GridView.builder(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.all(12),
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 12,
//         crossAxisSpacing: 12,
//         childAspectRatio: 0.75,
//       ),
//       itemCount: state.items.length,
//       itemBuilder: (_, index) {
//         final item = state.items[index];
//
//         return GalleryGridCard(
//           item: item,
//           onTap: () async {
//             final isDeleted = await Navigator.push<bool>(
//               context,
//               MaterialPageRoute(
//                 builder: (_) => GalleryPreviewScreen(
//                   items: List.of(state.items),
//                   initialIndex: index,
//                   onDelete: (delItem) => vm.deleteMedia(
//                     context,
//                     imgVid: delItem.imgVid,
//                   ),
//                 ),
//               ),
//             );
//
//             if (isDeleted == true) {
//               await vm.fetchGallery();
//             }
//           },
//           onDelete: () async {
//             await deleteMedia(
//               context: context,
//               deleteAction: () async {
//                 await vm.deleteMedia(context, imgVid: item.imgVid);
//               },
//               successMessage: "Media deleted successfully",
//               errorMessage: "Failed to delete media",
//             );
//           },
//         );
//       },
//     );
//   }
// }
//


import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_utils.dart';
import '../../../core/widgets/state_place_holder.dart';
import '../modal/gallery_state.dart';
import '../view_modal/gallery_controller.dart';
import '../view/gallery_preview_screen.dart';
import '../widgets/gallery_grid_card.dart';

class GalleryTab extends ConsumerStatefulWidget {
  const GalleryTab({super.key});

  @override
  ConsumerState<GalleryTab> createState() => _GalleryTabState();
}

class _GalleryTabState extends ConsumerState<GalleryTab> {

  /// 🔥 FIRST TIME AUTO FETCH
  @override
  void initState() {
    super.initState();
    // after build frame
    Future.microtask(() {
      ref.read(galleryViewModelProvider.notifier).fetchGallery();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(galleryViewModelProvider);
    final vm = ref.read(galleryViewModelProvider.notifier);

    return Stack(
      children: [
        Scaffold(
          backgroundColor:
          AppColors.blueActionGradient.colors.first.withOpacity(0.05),

          body: RefreshIndicator(
            onRefresh: vm.fetchGallery,
            child: _buildBody(context, state, vm),
          ),
        ),

        /// GLOBAL LOADER
        if (state.isLoading)
          const Positioned.fill(
            child: ColoredBox(
              color: Colors.black26,
              child: Center(child: CircularProgressIndicator()),
            ),
          ),
      ],
    );
  }

  Widget _buildBody(
      BuildContext context,
      GalleryState state,
      GalleryViewModel vm,
      ) {

    /// ERROR STATE
    if (state.error != null) {
      return StatePlaceholder.error(
        message: state.error!,
        onRetry: vm.fetchGallery,
      );
    }

    /// EMPTY STATE
    if (state.items.isEmpty) {
      return StatePlaceholder.empty(onRetry: vm.fetchGallery);
    }

    /// GRID VIEW
    return GridView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(12),

      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        mainAxisSpacing: 12,
        crossAxisSpacing: 12,
        childAspectRatio: 0.75,
      ),

      itemCount: state.items.length,

      itemBuilder: (_, index) {
        final item = state.items[index];

        return GalleryGridCard(
          item: item,

          /// OPEN PREVIEW
          onTap: () async {
            final isDeleted = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) => GalleryPreviewScreen(
                  items: List.of(state.items),
                  initialIndex: index,

                  onDelete: (delItem) => vm.deleteMedia(
                    context,
                    imgVid: delItem.imgVid,
                  ),
                ),
              ),
            );

            /// REFRESH AFTER DELETE FROM PREVIEW
            if (isDeleted == true) {
              await vm.fetchGallery();
            }
          },

          /// DELETE FROM GRID
          onDelete: () async {
            await deleteMedia(
              context: context,
              deleteAction: () async {
                await vm.deleteMedia(context, imgVid: item.imgVid);
              },
              successMessage: "Media deleted successfully",
              errorMessage: "Failed to delete media",
            );

            /// reload after delete
            await vm.fetchGallery();
          },
        );
      },
    );
  }
}

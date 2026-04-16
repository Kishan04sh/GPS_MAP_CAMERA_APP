// import 'package:flutter/material.dart';
// import 'package:cached_network_image/cached_network_image.dart';
// import '../../../core/api/api_constants.dart';
// import '../modal/gallery_modal.dart';
//
// class GalleryGridCard extends StatelessWidget {
//   final GalleryItem item;
//   final VoidCallback onTap;
//   final VoidCallback onDelete;
//
//   const GalleryGridCard({
//     super.key,
//     required this.item,
//     required this.onTap,
//     required this.onDelete,
//   });
//
//   @override
//   Widget build(BuildContext context) {
//     return Material(
//       elevation: 3,
//       shadowColor: Colors.black.withOpacity(0.15),
//       borderRadius: BorderRadius.circular(16),
//       clipBehavior: Clip.antiAlias,
//       child: InkWell(
//         onTap: onTap,
//         onLongPress: onDelete,
//         splashColor: Colors.black12,
//         highlightColor: Colors.black.withOpacity(0.05),
//         child: Stack(
//           fit: StackFit.expand,
//           children: [
//             /// ---------------- MEDIA IMAGE ----------------
//             Hero(
//               tag: 'media_${item.id}', // ✅ Safe & unique
//               child: CachedNetworkImage(
//                 imageUrl: "${ApiURLConstants.baseImageUrl}${item.filePath}",
//                 fit: BoxFit.cover,
//                 fadeInDuration: const Duration(milliseconds: 200),
//                 placeholder: (_, __) => const _ImageLoader(),
//                 errorWidget: (_, __, ___) => const _ImageError(),
//               ),
//             ),
//
//             /// ---------------- VIDEO OVERLAY ----------------
//             if (item.isVideo) ...[
//               const _VideoGradient(),
//
//               const Center(
//                 child: Icon(
//                   Icons.play_circle_fill_rounded,
//                   size: 48,
//                   color: Colors.white,
//                 ),
//               ),
//             ],
//           ],
//         ),
//       ),
//     );
//   }
// }
//
// /// **************_ImageLoader*************************************************************
// class _ImageLoader extends StatelessWidget {
//   const _ImageLoader();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: SizedBox(
//         width: 22,
//         height: 22,
//         child: CircularProgressIndicator(strokeWidth: 2),
//       ),
//     );
//   }
// }
//
// /// ***********_VideoGradient****************************************************************
// class _VideoGradient extends StatelessWidget {
//   const _VideoGradient();
//
//   @override
//   Widget build(BuildContext context) {
//     return const DecoratedBox(
//       decoration: BoxDecoration(
//         gradient: LinearGradient(
//           begin: Alignment.bottomCenter,
//           end: Alignment.center,
//           colors: [
//             Colors.black54,
//             Colors.transparent,
//           ],
//         ),
//       ),
//     );
//   }
// }
//
//
//
// /// ******************************************************************************
// class _ImageError extends StatelessWidget {
//   const _ImageError();
//
//   @override
//   Widget build(BuildContext context) {
//     return const Center(
//       child: Icon(
//         Icons.broken_image_outlined,
//         size: 42,
//         color: Colors.grey,
//       ),
//     );
//   }
// }
//



import 'package:flutter/material.dart';
import '../../../core/api/api_constants.dart';
import '../modal/gallery_modal.dart';

class GalleryGridCard extends StatelessWidget {
  final GalleryItem item;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const GalleryGridCard({
    super.key,
    required this.item,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 3,
      shadowColor: Colors.black.withOpacity(0.15),
      borderRadius: BorderRadius.circular(16),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        onLongPress: onDelete,
        splashColor: Colors.black12,
        highlightColor: Colors.black.withOpacity(0.05),
        child: Stack(
          fit: StackFit.expand,
          children: [
            /// ---------------- MEDIA IMAGE ----------------
            Hero(
              tag: 'media_${item.id}',
              child: _ProductionImage(
                imageUrl: "${ApiURLConstants.baseImageUrl}${item.filePath}",
              ),
            ),

            /// ---------------- VIDEO OVERLAY ----------------
            if (item.isVideo) ...[
              const _VideoGradient(),
              const Center(
                child: Icon(
                  Icons.play_circle_fill_rounded,
                  size: 48,
                  color: Colors.white,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// ************************ PRODUCTION IMAGE WIDGET ****************************
class _ProductionImage extends StatelessWidget {
  final String imageUrl;
  const _ProductionImage({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    if (imageUrl.isEmpty) {
      return _buildErrorPlaceholder();
    }

    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
        // Show image immediately if already loaded
        if (wasSynchronouslyLoaded) return child;

        // If frame is null, show a polished placeholder (instead of circular loader)
        if (frame == null) {
          return _buildPlaceholder();
        }

        // Image loaded successfully
        return child;
      },
      errorBuilder: (context, error, stackTrace) {
        debugPrint("Failed to load image: $imageUrl | $error");
        return _buildErrorPlaceholder();
      },
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(
          Icons.image,
          size: 32,
          color: Colors.white70,
        ),
      ),
    );
  }

  Widget _buildErrorPlaceholder() {
    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          size: 36,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// ********************* VIDEO OVERLAY ***********************************
class _VideoGradient extends StatelessWidget {
  const _VideoGradient();
  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.center,
          colors: [
            Colors.black54,
            Colors.transparent,
          ],
        ),
      ),
    );
  }
}

 /// *************************************************************************************
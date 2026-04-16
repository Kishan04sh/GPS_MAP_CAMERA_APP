import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImagePreview extends StatelessWidget {
  final String url;
  final String heroTag;

  const ImagePreview({
    super.key,
    required this.url,
    required this.heroTag,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: (details) {
        if (details.primaryDelta != null && details.primaryDelta! > 50) {
          Navigator.of(context).pop();
        }
      },
      child: Hero(
        tag: heroTag,
        child: PhotoView(
          imageProvider: CachedNetworkImageProvider(url),
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 3,
          initialScale: PhotoViewComputedScale.contained,
          enableRotation: true,
          enablePanAlways: true,
          tightMode: true,

          // Loader
          loadingBuilder: (context, event) => Center(
            child: SizedBox(
              width: 60,
              height: 60,
              child: CircularProgressIndicator(
                strokeWidth: 5,
                value: event == null
                    ? null
                    : event.cumulativeBytesLoaded / (event.expectedTotalBytes ?? 1),
                color: Colors.blueAccent,
              ),
            ),
          ),

          // Error
          errorBuilder: (context, error, stackTrace) => const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.broken_image, color: Colors.white, size: 80),
                SizedBox(height: 12),
                Text(
                  "Failed to load image",
                  style: TextStyle(color: Colors.white70),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

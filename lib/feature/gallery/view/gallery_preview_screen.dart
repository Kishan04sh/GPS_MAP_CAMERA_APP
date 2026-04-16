
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/ads/ad_helper.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/utils/media_saver_file.dart';
import '../../../core/utils/media_utils.dart';
import '../modal/gallery_modal.dart';
import '../widgets/image_preview.dart';
import '../widgets/video_preview.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';

class GalleryPreviewScreen extends ConsumerStatefulWidget {

  final List<GalleryItem> items;
  final int initialIndex;
  final Future<void> Function(GalleryItem item) onDelete;

  const GalleryPreviewScreen({
    super.key,
    required this.items,
    required this.initialIndex,
    required this.onDelete,
  });

  @override
  ConsumerState<GalleryPreviewScreen> createState() => _GalleryPreviewScreenState();
}

class _GalleryPreviewScreenState extends ConsumerState<GalleryPreviewScreen> {
  late final PageController _controller;
  late int _currentIndex;
  late List<GalleryItem> _items; // ✅ LOCAL MUTABLE LIST

  GalleryItem get _currentItem => _items[_currentIndex];

  @override
  void initState() {
    super.initState();
    _items = List.of(widget.items); // ✅ COPY LIST
    _currentIndex = widget.initialIndex;
    _controller = PageController(initialPage: _currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    final item = _currentItem;
    final mediaUrl = "${ApiURLConstants.baseImageUrl}${item.filePath}";

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: AppColors.white),
        backgroundColor: Colors.black,
        elevation: 0,
      ),

      // ================= PAGE VIEW =================
      body: PageView.builder(
        controller: _controller,
        itemCount: _items.length,
        onPageChanged: (i) => setState(() => _currentIndex = i),
        itemBuilder: (_, index) {
          final it = _items[index];
          final url = "${ApiURLConstants.baseImageUrl}${it.filePath}";
          final heroTag = "media_${it.id}_$index";

          // return it.isVideo
          //     ? VideoPreview(url: url)
          //     : ImagePreview(url: url, heroTag: heroTag);

          return Builder(
            builder: (_) {
              // 🚫 invalid / unknown media
              if (!it.canPreview) {
                return const Center(
                  child: Icon(
                    Icons.broken_image_outlined,
                    color: Colors.white54,
                    size: 48,
                  ),
                );
              }

              // 🎥 VIDEO
              if (it.isVideo) {
                return VideoPreview(url: url);
              }

              // 🖼 IMAGE
              if (it.isImage) {
                return ImagePreview(
                  url: url,
                  heroTag: heroTag,
                );
              }

              // 🔁 fallback (never crash)
              return const Center(
                child: Icon(
                  Icons.help_outline,
                  color: Colors.white38,
                ),
              );
            },
          );

        },
      ),

      // ================= BOTTOM BAR =================
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.black,
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 12,
              offset: Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 1,
            type: BottomNavigationBarType.fixed,
            selectedItemColor: AppColors.primary,
            unselectedItemColor: AppColors.white,
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.delete_outline, color: Colors.redAccent),
                label: 'Delete',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.share_outlined),
                label: 'Share',
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.download_outlined),
                label: 'Download',
              ),
            ],
            onTap: (index) async {
              switch (index) {

              // ================= DELETE =================
                case 0:
                  await deleteMedia(
                    context: context,
                    deleteAction: () async {
                      await widget.onDelete(_currentItem);

                      setState(() {
                        _items.removeAt(_currentIndex);

                        /// LAST ITEM DELETED
                        if (_items.isEmpty) {
                          Navigator.pop(context, true);
                          return;
                        }

                        /// INDEX ADJUST
                        if (_currentIndex >= _items.length) {
                          _currentIndex = _items.length - 1;
                        }
                      });

                      /// 🔔 INFORM PARENT GRID
                      Navigator.pop(context, true);
                    },
                    successMessage: "Media deleted successfully",
                    errorMessage: "Failed to delete media",
                  );
                  break;

              // ================= SHARE =================
              //   case 1:
              //     await shareMedia(
              //       context: context,
              //       url: mediaUrl,
              //       text: "Shared from Gallery",
              //     );
              //     break;

                case 1:
                  await ref.read(adHelperProvider).runWithAd(() async {
                    if (!context.mounted) {
                      debugPrint("⚠️ Context disposed → skip share");
                      return;
                    }
                    await shareMedia(
                      context: context,
                      url: mediaUrl,
                      text: "Shared from Gallery",
                    );
                  });
                  break;

              // ================= DOWNLOAD =================
              //   case 2:
              //     await SafeDownloader.downloadFromUrl(
              //       context: context,
              //       url: mediaUrl,
              //       successMessage: "Downloading started",
              //     );
              //     break;

                case 2:
                  await ref.read(adHelperProvider).runWithAd(
                        () async {
                      await SafeDownloader.downloadFromUrl(
                        context: context,
                        url: mediaUrl,
                        successMessage: "Downloading started",
                      );
                    },
                  );
                  break;
              }
            },
          ),
        ),
      ),
    );
  }
}

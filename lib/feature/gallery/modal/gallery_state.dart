
import 'gallery_modal.dart';

enum GalleryFilter { all, image, video }

class GalleryState {
  final bool isLoading;
  final List<GalleryItem> items;
  final String? error;
  final GalleryFilter filter;

  const GalleryState({
    required this.isLoading,
    required this.items,
    required this.filter,
    this.error,
  });

  factory GalleryState.initial() {
    return const GalleryState(
      isLoading: false,
      items: [],
      filter: GalleryFilter.all,
    );
  }

  GalleryState copyWith({
    bool? isLoading,
    List<GalleryItem>? items,
    String? error,
    GalleryFilter? filter,
  }) {
    return GalleryState(
      isLoading: isLoading ?? this.isLoading,
      items: items ?? this.items,
      error: error,
      filter: filter ?? this.filter,
    );
  }
}

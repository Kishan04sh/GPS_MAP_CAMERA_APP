enum MediaType { image, video, unknown }

extension MediaTypeX on MediaType {
  bool get isImage => this == MediaType.image;
  bool get isVideo => this == MediaType.video;

  String get apiValue {
    switch (this) {
      case MediaType.image:
        return 'image';
      case MediaType.video:
        return 'video';
      default:
        return '';
    }
  }

  // backend → enum
  static MediaType fromBackend(String? value) {
    switch (value?.toLowerCase()) {
      case 'image':
      case 'img':
      case 'photo':
        return MediaType.image;
      case 'video':
      case 'vid':
        return MediaType.video;
      default:
        return MediaType.unknown;
    }
  }

  // url → enum
  static MediaType fromUrl(String url) {
    final u = url.toLowerCase();
    if (u.endsWith('.jpg') ||
        u.endsWith('.jpeg') ||
        u.endsWith('.png') ||
        u.endsWith('.webp')) {
      return MediaType.image;
    }
    if (u.endsWith('.mp4') ||
        u.endsWith('.mov') ||
        u.endsWith('.avi') ||
        u.endsWith('.mkv')) {
      return MediaType.video;
    }
    return MediaType.unknown;
  }
}

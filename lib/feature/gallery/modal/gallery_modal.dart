import 'media_type.dart';

class GalleryItem {
  final String id;
  final String userId;
  final String imgVid;
  final String date;
  final String latitude;
  final String longitude;
  final String location;
  final String type;
  final String fileUrl;
  final String filePath;

  const GalleryItem({
    required this.id,
    required this.userId,
    required this.imgVid,
    required this.date,
    required this.latitude,
    required this.longitude,
    required this.location,
    required this.type,
    required this.fileUrl,
    required this.filePath,
  });

  factory GalleryItem.fromJson(Map<String, dynamic> json) {
    return GalleryItem(
      id: json['id']?.toString() ?? '',
      userId: json['userId']?.toString() ?? '',
      imgVid: json['imgVid']?.toString() ?? '',
      date: json['date']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      fileUrl: json['fileUrl']?.toString() ?? '',
      filePath: json['filePath']?.toString() ?? '',
    );
  }

  /// ---------- DOMAIN LOGIC ----------
  /// 2️⃣ fallback → url extension
  MediaType get mediaType {
    final backendType = MediaTypeX.fromBackend(type);
    if (backendType != MediaType.unknown) {
      return backendType;
    }

    return MediaTypeX.fromUrl(previewUrl);
  }

  bool get isImage => mediaType.isImage;
  bool get isVideo => mediaType.isVideo;

  /// priority: fileUrl > filePath
  String get previewUrl =>
      fileUrl.isNotEmpty ? fileUrl : filePath;

  double? get lat => double.tryParse(latitude);
  double? get lng => double.tryParse(longitude);

  bool get hasLocation => lat != null && lng != null;

  /// UI safety check
  bool get canPreview => mediaType != MediaType.unknown;
}

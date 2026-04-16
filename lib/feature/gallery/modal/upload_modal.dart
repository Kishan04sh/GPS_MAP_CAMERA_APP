
class UploadMediaResponse {
  final int insertId;
  final String fileName;
  final String filePath;

  UploadMediaResponse({
    required this.insertId,
    required this.fileName,
    required this.filePath,
  });

  factory UploadMediaResponse.fromJson(Map<String, dynamic> json) {
    return UploadMediaResponse(
      insertId: json['insert_id'] ?? 0,
      fileName: json['file_name'] ?? '',
      filePath: json['file_path'] ?? '',
    );
  }
}

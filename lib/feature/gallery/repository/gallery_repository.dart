
import 'dart:io';
import 'package:dio/dio.dart';
import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_services.dart';
import '../modal/gallery_modal.dart';
import '../modal/upload_modal.dart';

class GalleryRepository {
  final ApiService _apiService;

  GalleryRepository({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  /// ==========================================================
  /// FETCH GALLERY (Image / Video / All)
  /// ==========================================================
  Future<ApiResponse<List<GalleryItem>>> fetchGallery({
    String? type, // image | video | null
  }) async {
    try {
      final Map<String, dynamic> body = {};

      // Optional filter
      if (type != null && type.isNotEmpty) {
        body['type'] = type;
      }

      final response = await _apiService.post(
        ApiURLConstants.userFetchImgVio,
        body,
        useUserId: true,
      );

      return ApiResponseParser.parse<List<GalleryItem>>(
        response, (json) {
          if (json is List) {
            return json.map((e) => GalleryItem.fromJson(e)).toList();
          }
          return [];
        },
      );
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure(
        "Unable to fetch gallery. Please try again.",
      );
    }
  }

  /// ==========================================================
  /// UPLOAD IMAGE / VIDEO (MULTIPART)
  /// ==========================================================
  Future<ApiResponse<UploadMediaResponse>> uploadMedia({
    required File file,
    required String latitude,
    required String longitude,
    required String location,
    required String type, // image | video
    String? date,
  }) async {
    try {
      final formData = FormData.fromMap({
        'latitude': latitude,
        'longitude': longitude,
        'location': location,
        'type': type,
        'file': await MultipartFile.fromFile(
          file.path, filename: file.path.split('/').last,
        ),
      });

      final response = await _apiService.postFormData(
        ApiURLConstants.userUpload,
        formData,
        useUserId: true,
      );

      return ApiResponseParser.parse<UploadMediaResponse>(
        response, (json) => UploadMediaResponse.fromJson(json),
      );
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure(
        'Media upload failed. Please try again.',
      );
    }
  }

  /// ==========================================================
  /// DELETE OPERATIONS
  /// ==========================================================
  Future<ApiResponse<bool>> deleteById(int id) async {
    return _delete({'id': id});
  }

  Future<ApiResponse<bool>> deleteByImgVid(String imgVid) async {
    return _delete({'imgVid': imgVid});
  }

  Future<ApiResponse<bool>> deleteAllUserMedia() async {
    return _delete({}, useUserId: true);
  }

  /// 🔒 Internal delete handler
  Future<ApiResponse<bool>> _delete(
      Map<String, dynamic> body, {
        bool useUserId = false,
      }) async {
    try {
      final response = await _apiService.post(
        ApiURLConstants.userDeleteImgVio,
        body,
        useUserId: useUserId,
      );

      return ApiResponseParser.parse<bool>(
        response, (_) => true,
      );
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure(
        'Unable to delete media. Please try again.',
      );
    }
  }

 /// **********************************************************************************

}


import 'package:dio/dio.dart';

import 'api_exception.dart';

class ApiResponse<T> {
  final bool success;
  final String message;
  final T? data;

  ApiResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory ApiResponse.success(T data, {String message = 'Success'}) {
    return ApiResponse(success: true, message: message, data: data);
  }

  factory ApiResponse.failure(String message) {
    return ApiResponse(success: false, message: message);
  }
}


/// ************************************************************************************
class ApiResponseParser {
  static ApiResponse<T> parse<T>(
      Response response,
      T Function(dynamic json) fromJson,
      ) {
    final data = response.data;

    if (data is Map<String, dynamic>) {
      final bool success =
          data['success'] ?? data['status'] ?? true;
      final String message =
          data['message'] ?? data['msg'] ?? 'Success';

      if (!success) {
        return ApiResponse.failure(message);
      }

      return ApiResponse.success(
        fromJson(data['data'] ?? data),
        message: message,
      );
    }

    return ApiResponse.success(fromJson(data));
  }

  static ApiResponse<T> error<T>(Object error) {
    if (error is ApiException) {
      return ApiResponse.failure(error.message);
    }
    return ApiResponse.failure("Unexpected error occurred");
  }
}

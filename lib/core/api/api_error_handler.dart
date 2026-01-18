import 'package:dio/dio.dart';

class ApiErrorHandler {
  /// -------------------------------------------------------
  /// Convert DioException → User Friendly Message
  /// -------------------------------------------------------
  static String getMessage(DioException e) {
    switch (e.type) {

    // ⏱ Connection timeout
      case DioExceptionType.connectionTimeout:
        return "Connection timeout. Please try again.";

    // ⏱ Receive timeout
      case DioExceptionType.receiveTimeout:
        return "Server is taking too long to respond.";

    // ❌ Server returned error response (4xx / 5xx)
      case DioExceptionType.badResponse:
        return _handleResponseError(e);

    // 🌐 No internet / DNS issue
      case DioExceptionType.connectionError:
        return "No internet connection.";

    // ❌ Request cancelled
      case DioExceptionType.cancel:
        return "Request cancelled.";

    // ❓ Unknown error
      default:
        return "Something went wrong. Please try again.";
    }
  }

  /// -------------------------------------------------------
  /// Handle API Response Errors (4xx / 5xx)
  /// -------------------------------------------------------
  static String _handleResponseError(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // If backend sends { message: "..." }
    if (data is Map<String, dynamic> && data["message"] != null) {
      return data["message"].toString();
    }

    // Fallback based on status code
    switch (statusCode) {
      case 400:
        return "Bad request.";
      case 401:
        return "Unauthorized access.";
      case 403:
        return "Access denied.";
      case 404:
        return "Resource not found.";
      case 500:
        return "Internal server error.";
      default:
        return "Unexpected server error.";
    }
  }
}

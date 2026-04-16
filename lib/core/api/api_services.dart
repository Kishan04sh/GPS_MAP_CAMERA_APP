import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import '../storege/secure_storage_service.dart';
import 'api_constants.dart';
import 'api_exception.dart';
import 'api_error_handler.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;
  final SecureStorageService _secureStorage = SecureStorageService();

  ApiService._internal() {
    _dio = Dio(
      BaseOptions(
        baseUrl: ApiURLConstants.baseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        headers: {
          "Accept": "application/json",
        },
      ),
    );

    /// ===================== INTERCEPTOR =====================
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bool useUserId = options.extra["useUserId"] ?? true;

          if (useUserId) {
            final userId = await _secureStorage.read(AuthStorageKeys.userId);

            if (userId != null && userId.isNotEmpty) {
              print("🆔 Injecting userId => $userId");

              /// BODY MAP (JSON / MAP)
              if (options.data is Map<String, dynamic>) {
                options.data.putIfAbsent("userId", () => userId);
              }

              /// FORM DATA
              if (options.data is FormData) {
                final hasUserId = options.data.fields.any((e) => e.key == "userId");

                if (!hasUserId) {
                  options.data.fields.add(
                    MapEntry("userId", userId),
                  );
                }
              }
            }
          }

          // 🔍 LOG REQUEST
          print("➡️ API REQUEST");
          print("URL    : ${options.uri}");
          print("METHOD : ${options.method}");
          print("HEADERS: ${options.headers}");
          print("QUERY  : ${options.queryParameters}");
          print("BODY   : ${options.data}");

          handler.next(options);
        },

        onResponse: (response, handler) {
          print("✅ API RESPONSE");
          print("URL    : ${response.requestOptions.uri}");
          print("STATUS : ${response.statusCode}");
          print("DATA   : ${response.data}");
          handler.next(response);
        },

        onError: (error, handler) {
          print("❌ API ERROR");
          print("URL    : ${error.requestOptions.uri}");
          print("ERROR  : ${error.message}");
          print("DATA   : ${error.response?.data}");
          handler.next(error);
        },
      ),
    );

  }


  /// ***************************************************************
  /// INTERNET CHECK
  /// ***************************************************************
  Future<void> _checkInternet() async {
    final connectivity = await Connectivity().checkConnectivity();
    if (connectivity == ConnectivityResult.none) {
      throw ApiException("No Internet Connection");
    }
  }

  /// ***************************************************************
  /// POST API (JSON)
  /// ***************************************************************
  Future<Response> post(
      String endpoint,
      Map<String, dynamic> body, {
        bool useUserId = true,
      }) async {
    await _checkInternet();
    try {
      print("📤 POST API CALL => $endpoint");
      print("📦 PAYLOAD BEFORE SEND => $body");

      return await _dio.post(
        endpoint,
        data: body,
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          extra: {"useUserId": useUserId},
        ),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorHandler.getMessage(e));
    }
  }


  /// ***************************************************************
  /// GET API
  /// ***************************************************************
  Future<Response> get(
      String endpoint, {
        bool useUserId = true,
        Map<String, dynamic>? queryParams,
      }) async {
    await _checkInternet();
    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(extra: {"useUserId": useUserId}),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorHandler.getMessage(e));
    }
  }

  /// ***************************************************************
  /// MULTIPART FORM DATA (FILE UPLOAD)
  /// ***************************************************************
  Future<Response> postFormData(
      String endpoint,
      FormData formData, {
        bool useUserId = true,
      }) async {
    await _checkInternet();

    try {
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(extra: {"useUserId": useUserId}),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorHandler.getMessage(e));
    }
  }


}



/// *********************************************************************************
extension SmsService on ApiService {
  /// Sends OTP via GET request to PayYou SMS API
  // Future<void> sendSmsOtp({
  //   required String mobile,
  //   required String otp,
  // }) async {
  //   final url = "https://sms.payyou.co.in/send-message"
  //       "?api_key=${ApiURLConstants.apiKay}"
  //       "&sender=${ApiURLConstants.sender}" // must remain +917458993334
  //       "&number=+91$mobile"
  //       "&message=Your GPS Map Camera OTP is $otp. Valid for 2 minutes."
  //       "&footer=Sent via MPWA";
  //
  //   try {
  //     final response = await Dio().get(
  //       url,
  //       options: Options(
  //         headers: {"Accept": "application/json"},
  //         extra: {"useToken": false},
  //       ),
  //     );
  //     print("response data $response");
  //
  //     // Check response
  //     if (response.data == null || response.data['status'] != true) {
  //       throw ApiException(
  //         "OTP sending failed: ${response.data?['msg'] ?? 'Unknown error'}",
  //       );
  //     }
  //   } on DioException catch (e) {
  //     throw ApiException("OTP sending failed: ${e.message}");
  //   }
  // }

  /// ***********************************************************

  Future<void> sendWhatsappOtp(String mobile, String otp) async {
    const url = "${ApiURLConstants.baseUrl}${ApiURLConstants.sendWhatsapp}";
    try {
      final response = await _dio.post(
        url,
        data: {
          "number": "+91$mobile",
          // "message": "Your GPS Map Camera OTP is $otp. Valid for 2 minutes.",
          "message": "GPS CAM BHARAT: $otp is your verification code. Valid for 2 minutes. Do not share this code with anyone.",
        },
        options: Options(
          contentType: Headers.formUrlEncodedContentType,
          responseType: ResponseType.json, // IMPORTANT
        ),
      );

      _validateWhatsappResponse(response);
    } on DioException catch (e) {
      throw ApiException(_parseDioError(e));
    }
  }



  void _validateWhatsappResponse(Response response) {
    if (response.statusCode != 200) {
      throw ApiException("Server not reachable");
    }

    if (response.data == null || response.data is! Map) {
      throw ApiException("Invalid server response");
    }

    final data = response.data as Map<String, dynamic>;

    final success = data["success"] == true;
    final message = (data["message"] ?? "").toString();

    if (!success) {
      throw ApiException(message.isEmpty ? "WhatsApp sending failed" : message);
    }

    // Extra safety: number mismatch protection
    if (!data.containsKey("number")) {
      throw ApiException("Delivery confirmation missing");
    }
  }


  String _parseDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return "Connection timeout";
      case DioExceptionType.receiveTimeout:
        return "Server not responding";
      case DioExceptionType.connectionError:
        return "No internet connection";
      case DioExceptionType.badResponse:
        return "Server error";
      default:
        return "Unexpected network error";
    }
  }


/// *******************************************************************************

}

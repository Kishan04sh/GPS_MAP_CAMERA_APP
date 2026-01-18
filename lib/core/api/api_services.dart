import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:dio/dio.dart';
import 'api_constants.dart';
import 'api_exception.dart';
import 'api_error_handler.dart';


/// ***************************************************************
/// API SERVICE (SINGLETON)
/// ***************************************************************

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;

  late final Dio _dio;

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

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final bool useToken = options.extra["useToken"] ?? true;

          if (useToken) {
            // final token = await LocalStorage.getToken();
            // if (token != null && token.isNotEmpty) {
            //   options.headers["Authorization"] = "Bearer $token";
            // }
          } else {
            options.headers.remove("Authorization");
          }

          // Automatically set JSON header only when NOT FormData
          if (options.data is! FormData) {
            options.headers["Content-Type"] = "application/json";
          }

          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        onError: (error, handler) {
          return handler.next(error);
        },
      ),
    );

    /// ===================== LOG INTERCEPTOR =====================
    _dio.interceptors.add(
      LogInterceptor(
        request: true,
        requestHeader: true,
        requestBody: true,
        responseHeader: false,
        responseBody: true,
        error: true,
        logPrint: (object) {
          // ignore: avoid_print
          print(object);
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
        bool useToken = true,
      }) async {
    await _checkInternet();

    try {
      return await _dio.post(
        endpoint,
        data: body,
        options: Options(extra: {"useToken": useToken}),
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
        bool useToken = true,
        Map<String, dynamic>? queryParams,
      }) async {
    await _checkInternet();

    try {
      return await _dio.get(
        endpoint,
        queryParameters: queryParams,
        options: Options(extra: {"useToken": useToken}),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorHandler.getMessage(e));
    }
  }

  /// ***************************************************************
  /// POST FORM DATA (FILE UPLOAD)
  /// ***************************************************************
  Future<Response> postFormData(
      String endpoint,
      FormData formData, {
        bool useToken = true,
      }) async {
    await _checkInternet();

    try {
      return await _dio.post(
        endpoint,
        data: formData,
        options: Options(extra: {"useToken": useToken}),
      );
    } on DioException catch (e) {
      throw ApiException(ApiErrorHandler.getMessage(e));
    }
  }


 /// ******************************************************************************************************

}

/// *********************************************************************************
extension SmsService on ApiService {
  /// Sends OTP via GET request to PayYou SMS API
  Future<void> sendSmsOtp({
    required String mobile,
    required String otp,
  }) async {
    final url = "https://sms.payyou.co.in/send-message"
        "?api_key=${ApiURLConstants.apiKay}"
        "&sender=${ApiURLConstants.sender}" // must remain +917458993334
        "&number=+91$mobile"
        "&message=Your GPS Map Camera OTP is $otp. Valid for 2 minutes."
        "&footer=Sent via MPWA";

    try {
      final response = await Dio().get(
        url,
        options: Options(
          headers: {"Accept": "application/json"},
          extra: {"useToken": false},
        ),
      );

      // Check response
      if (response.data == null || response.data['status'] != true) {
        throw ApiException(
          "OTP sending failed: ${response.data?['msg'] ?? 'Unknown error'}",
        );
      }
    } on DioException catch (e) {
      throw ApiException("OTP sending failed: ${e.message}");
    }
  }
}

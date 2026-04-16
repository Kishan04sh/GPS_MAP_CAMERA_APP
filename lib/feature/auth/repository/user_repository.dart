import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_map_camera/core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_services.dart';
import '../../../core/storege/secure_storage_service.dart';
import '../model/auth_user_model.dart';

/// *************************************************************************

final userRepositoryProvider = Provider<UserRepository>((ref) {
  return UserRepository(
    apiService: ApiService(),
    secureStorage: SecureStorageService(),
  );
});


class UserRepository {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  UserRepository({
    ApiService? apiService,
    SecureStorageService? secureStorage,
  })  : _apiService = apiService ?? ApiService(),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// ***************************************************************
  /// ADD USER + STORE USER ID (FROM ROOT RESPONSE)
  /// ***************************************************************

  Future<ApiResponse<UserModel>> addUser({
    required String phone,
    required String fireBaseId,
    required String name,
    required String email,
    required String city,
  }) async {
    try {
      final payload = {
        'phone': phone.trim().isEmpty ? "" : phone.trim(),
        'fireBaseId': fireBaseId.trim(),
        'name': name.trim().isEmpty ? "" : name.trim(),
        'email': email.trim(),
        'city': city.trim().isEmpty ? "" : city.trim(),
      };

      final response = await _apiService.post(
        ApiURLConstants.userAdd,
        payload,
        useUserId: false,
      );

      final data = response.data;

      if (data is! Map<String, dynamic>) {
        return ApiResponse.failure("Invalid server response");
      }

      final bool success = data['success'] ?? false;
      final String message = data['message'] ?? 'Success';

      final Map<String, dynamic>? userJson =
      data['data'] as Map<String, dynamic>?;

      if (!success || userJson == null) {
        return ApiResponse.failure(message);
      }
      final user = UserModel.fromJson(userJson);
      if (user.id == 0) {
        return ApiResponse.failure("Invalid user data");
      }
      await _secureStorage.write(
        AuthStorageKeys.userId,
        user.id.toString(),
      );
      /// ✅ RETURN USER (IMPORTANT)
      return ApiResponse.success(user, message: message);

    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure(
        "Something went wrong. Please try again.",
      );
    }
  }



  /// Updates user profile data on the server.
  ///===============================================================
  Future<ApiResponse<void>> updateUserData({
    required int id,
    required String profession,
    required String name,
    required String pincode,
    required String city,
    required String email,
    required String phone,
  }) async {
    try {
      /// Prepare request payload
      final Map<String, dynamic> payload = {
        'id': id,
        'profession': profession,
        'name': name,
        'pincode': pincode,
        'city': city,
        'email': email,
        'phone': phone,
      };

      /// Execute API request
      final response = await _apiService.post(
        ApiURLConstants.updateUserData,
        payload,
        useUserId: false,
      );

      /// Validate response structure
      final data = response.data;
      if (data is! Map<String, dynamic>) {
        return ApiResponse.failure("Invalid server response");
      }

      /// Extract response fields
      final bool status = data['status'] ?? false;
      final String message = data['message'] ?? "Update failed";

      /// Handle failure response from backend
      if (!status) {
        return ApiResponse.failure(message);
      }

      /// Return success response
      return ApiResponse.success(
        null,
        message: message,
      );

    } catch (e) {
      /// Handle unexpected errors (network, parsing, etc.)
      return ApiResponse.failure(
        "Something went wrong. Please try again.",
      );
    }
  }


  ///=================================================================

}

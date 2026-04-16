import '../../../core/api/api_constants.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/api/api_response.dart';
import '../../../core/api/api_services.dart';
import '../../../core/storege/secure_storage_service.dart';
import '../../auth/model/auth_user_model.dart';

class SettingsRepository {
  final ApiService _apiService;
  final SecureStorageService _secureStorage;

  SettingsRepository({
    ApiService? apiService,
    SecureStorageService? secureStorage,
  })  : _apiService = apiService ?? ApiService(),
        _secureStorage = secureStorage ?? SecureStorageService();

  /// ***************************************************************
  /// DELETE USER
  /// ***************************************************************

  Future<ApiResponse<void>> deleteUser() async {
    try {
      final firebaseUid = await _secureStorage.read(AuthStorageKeys.firebaseUid);
      final phone = await _secureStorage.read(AuthStorageKeys.mobileNumber);

      final Map<String, dynamic> payload = {};

      if (firebaseUid != null && firebaseUid.isNotEmpty) {
        payload['fireBaseId'] = firebaseUid;
      } else if (phone != null && phone.isNotEmpty) {
        payload['phone'] = phone;
      } else {
        return ApiResponse.failure(
          "No Firebase ID or phone number found",
        );
      }

      final response = await _apiService.post(
        ApiURLConstants.userDelete,
        payload,
        useUserId: true, // ✅ interceptor injects userId
      );

      final data = response.data as Map<String, dynamic>?;

      if (data == null || data['success'] != true) {
        return ApiResponse.failure(
          data?['message'] ?? 'Delete failed',
        );
      }

      return ApiResponse.success(
        null,
        message: data['message'],
      );
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure("Something went wrong");
    }
  }

///============================================================================
  /// ***************************************************************
  /// GET USER BY ID
  /// ***************************************************************

  Future<ApiResponse<UserModel>> getUserById() async {
    try {
      // ✅ Get userId from secure storage
      final userId = await _secureStorage.read(AuthStorageKeys.userId);
      if (userId == null || userId.isEmpty) {
        return ApiResponse.failure("User ID not found");
      }
      // ✅ API Payload
      final payload = {
        "id": userId,
      };
      final response = await _apiService.post(
        ApiURLConstants.getUserById,
        payload,
        useUserId: true,
      );
      final data = response.data as Map<String, dynamic>?;
      if (data == null || data['status'] != true) {
        return ApiResponse.failure(
          data?['message'] ?? "Failed to fetch user",
        );
      }
      // ✅ Parse Model
      final user = UserModel.fromJson(data['data']);
      return ApiResponse.success(
        user,
        message: "User fetched successfully",
      );
    } on ApiException catch (e) {
      return ApiResponse.failure(e.message);
    } catch (_) {
      return ApiResponse.failure("Something went wrong");
    }
  }
  ///================================================================

}

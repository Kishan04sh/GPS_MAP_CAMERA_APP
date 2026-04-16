import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/api/api_response.dart';
import '../../auth/model/auth_user_model.dart';
import '../repository/setting_repository.dart';

/// ================= Provider =================
final settingsControllerProvider =
StateNotifierProvider<SettingsController, AsyncValue<void>>(
      (ref) => SettingsController(ref),
);


final settingsRepositoryProvider = Provider<SettingsRepository>(
      (ref) => SettingsRepository(),
);


final userProvider = StateProvider<UserModel?>((ref) => null);


/// ================= Controller =================
class SettingsController extends StateNotifier<AsyncValue<void>> {
  final Ref _ref;

  SettingsController(this._ref) : super(const AsyncData(null));

  Future<ApiResponse<void>> deleteUser() async {
    state = const AsyncLoading();
    final result = await _ref.read(settingsRepositoryProvider).deleteUser();
    if (result.success) {
      state = const AsyncData(null);
    } else {
      state = AsyncError(result.message, StackTrace.current);
    }

    return result;
  }



  /// ================= GET USER =================
  Future<void> getUser() async {
    state = const AsyncLoading();

    final result =
    await _ref.read(settingsRepositoryProvider).getUserById();

    if (result.success) {
      // ✅ store user globally
      _ref.read(userProvider.notifier).state = result.data;

      state = const AsyncData(null);
    } else {
      state = AsyncError(result.message, StackTrace.current);
    }
  }

  //======================================================
}

/// ***************************************************************************

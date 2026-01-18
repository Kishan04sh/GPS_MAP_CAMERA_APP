
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:gps_map_camera/feature/auth/model/auth_session.dart';
import '../../../core/services/google_auth_service.dart';
import 'auth_session_notifier.dart';

/// Provider for AuthViewModel
final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>(
      (ref) => AuthViewModel(
    GoogleAuthService(),
    ref.read(authSessionProvider.notifier),
  ),
);

/// *************************************************************************
/// AuthViewModel
/// *************************************************************************
class AuthViewModel extends StateNotifier<AuthState> {
  final GoogleAuthService _googleAuth;
  final AuthSessionNotifier _session;

  AuthViewModel(this._googleAuth, this._session)
      : super(AuthState.initial());

  /// ================= GOOGLE LOGIN =================
  Future<void> loginWithGoogle() async {
    try {
      state = const AuthState(status: AuthStatus.loading);
      final user = await _googleAuth.signInWithGoogle();
      // Save session
      await _session.saveLogin(uid:user.uid, loginType: LoginType.google);
      // Update state
      state = const AuthState(status: AuthStatus.authenticated);
    } catch (e, st) {
      // Robust error handling
      print('❌ [AuthViewModel] Google login error: $e\n$st');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
      await _session.logout();
    }
  }

  /// ================= LOGOUT =================
  Future<void> logout() async {
    try {
      state = const AuthState(status: AuthStatus.loading);

      await _googleAuth.signOut();
      await _session.logout();

      state = const AuthState(status: AuthStatus.unauthenticated);
    } catch (e, st) {
      print('❌ [AuthViewModel] Logout error: $e\n$st');
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );

      // Force clear session if anything went wrong
      await _session.logout();
      state = const AuthState(status: AuthStatus.unauthenticated);
    }
  }
}

/// *************************************************************************
/// AuthState
/// *************************************************************************
enum AuthStatus {
  initial,
  loading,
  authenticated,
  unauthenticated,
  error,
}

class AuthState {
  final AuthStatus status;
  final String? errorMessage;

  const AuthState({
    required this.status,
    this.errorMessage,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
}



/// *******************************************************************************************

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:gps_map_camera/feature/auth/model/auth_session.dart';
import '../../../core/api/api_exception.dart';
import '../../../core/routing/route_names.dart';
import '../../../core/services/google_auth_service.dart';
import '../../../core/widgets/app_snackbar.dart';
import '../model/auth_user_model.dart';
import '../repository/user_repository.dart';
import 'auth_session_notifier.dart';

/// Provider for AuthViewModel
final authViewModelProvider =
StateNotifierProvider<AuthViewModel, AuthState>(
      (ref) => AuthViewModel(
          ref,
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
  final Ref _ref;

  AuthViewModel(
      this._ref,
      this._googleAuth,
      this._session) : super(AuthState.initial());

  /// ================= GOOGLE LOGIN =================

  Future<void> loginWithGoogle() async {
    // state = const AuthState(status: AuthStatus.loading);
    state = const AuthState(status: AuthStatus.googleLoading);

    try {
      /// 1️⃣ Google Sign-In
      final googleUser = await _googleAuth.signInWithGoogle();
      final userRepository = _ref.read(userRepositoryProvider);

      final result = await userRepository.addUser(
        phone: googleUser.phoneNumber ?? "",
        fireBaseId: googleUser.uid,
        name: googleUser.displayName ?? "NA",
        email: googleUser.email ?? "NA",
        city: "NA",
      );

      /// ❌ FAILURE
      if (!result.success || result.data == null) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
        return;
      }

      final user = result.data!;

      print("user data : $user");
      /// 🔴 MAIN LOGIC (MISSING IN YOUR CODE)
      if (!user.register) {
        state = AuthState(
          status: AuthStatus.needsRegistration,
          user: user, // ✅ PASS USER
        );
        return;
      }

      print("user uid : ${googleUser.uid}");
      /// ✅ NORMAL LOGIN
      await _session.saveLogin(
        uid: googleUser.uid,
        loginType: LoginType.google,
      );

      state = const AuthState(status: AuthStatus.authenticated);

    } on ApiException catch (e) {
      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );
      await _session.logout();

    } catch (e, st) {
      print('❌ [AuthViewModel] Google login error: $e\n$st');
      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: "Something went wrong. Please try again.",
      );
      await _session.logout();
    }
  }

  ///======================updateUserProfile=====================================

  Future<void> updateUserProfile({
    required BuildContext context,
    required int id,
    required String uid,
    required String name,
    required String email,
    required String city,
    required String profession,
    required String pincode,
    required String phone,
  }) async {
    print("🚀 [updateUserProfile] Called");
    print("📥 Input -> id: $id, name: $name, email: $email, "
        "city: $city, profession: $profession, pincode: $pincode");
    /// Start loading
    state = const AuthState(status: AuthStatus.loading);
    try {
      final userRepository = _ref.read(userRepositoryProvider);
      /// API CALL
      final result = await userRepository.updateUserData(
        id: id,
        name: name.trim(),
        email: email.trim(),
        city: city.trim(),
        profession: profession.trim(),
        pincode: pincode.trim(),
        phone: phone.trim(),
      );

      print("📦 API Response -> success: ${result.success}, message: ${result.message}");

      /// FAILURE CASE
      if (!result.success) {
        print("❌ Update failed");

        state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.message,
        );

        AppSnackbar.show(
          context,
          message: result.message,
          type: SnackbarType.error,
        );
        return;
      }

      /// SUCCESS CASE
      print("✅ Update successful");
      state = const AuthState(status: AuthStatus.authenticated);
      final authSessionNotifier = _ref.read(authSessionProvider.notifier);
      await authSessionNotifier.saveLogin(
        uid: uid,
        loginType: LoginType.google,
      );
      // await _storage.write(AuthStorageKeys.isLoggedIn, 'true');

      AppSnackbar.show(
        context,
        message: result.message,
        type: SnackbarType.success,
      );

      print("🏠 Navigating to home");
      context.go(RouteNames.home);

    } on ApiException catch (e) {
      print("⚠️ ApiException: ${e.message}");

      state = AuthState(
        status: AuthStatus.error,
        errorMessage: e.message,
      );

      AppSnackbar.show(
        context,
        message: e.message,
        type: SnackbarType.error,
      );

    } catch (e, st) {
      print("❌ Unexpected Error: $e");
      print("🧾 StackTrace: $st");

      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: "Something went wrong",
      );

      AppSnackbar.show(
        context,
        message: "Something went wrong. Please try again.",
        type: SnackbarType.error,
      );
    }
  }



  ///===================Login With Email======================================

  /*Future<void> loginWithEmail(String email, String password) async {
    state = const AuthState(status: AuthStatus.emailLoading);
    try {
      UserCredential credential;
      try {
        /// 🔵 TRY LOGIN
        credential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      } on FirebaseAuthException catch (e) {
        print("🔥 Firebase Code: ${e.code}");
        print("🔥 Firebase Message: ${e.message}");

        /// 🔴 USER NOT FOUND / INVALID → CREATE ACCOUNT
        if (e.code == 'user-not-found' || e.code == 'invalid-credential') {

          credential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

        }
        else if (e.code == 'wrong-password') {

          state = const AuthState(
            status: AuthStatus.error,
            errorMessage: "Wrong password",
          );
          return;

        }
        else if (e.code == 'invalid-email') {

          state = const AuthState(
            status: AuthStatus.error,
            errorMessage: "Invalid email format",
          );
          return;

        }
        else {

          state = AuthState(
            status: AuthStatus.error,
            errorMessage: e.message ?? "Login failed",
          );
          return;
        }
      }

      /// ✅ USER CHECK
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: "User not found",
        );
        return;
      }

      /// 🔵 API CALL (SAME AS GOOGLE)
      final userRepository = _ref.read(userRepositoryProvider);

      final result = await userRepository.addUser(
        phone: "",
        fireBaseId: firebaseUser.uid,
        name: firebaseUser.email ?? "NA",
        email: firebaseUser.email ?? "NA",
        city: "NA",
      );

      if (!result.success || result.data == null) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
        return;
      }

      final user = result.data!;

      /// 🔴 NEED REGISTRATION
      if (!user.register) {
        state = AuthState(
          status: AuthStatus.needsRegistration,
          user: user,
        );
        return;
      }

      /// ✅ SAVE SESSION
      await _session.saveLogin(
        uid: firebaseUser.uid,
        loginType: LoginType.email,
      );

      state = const AuthState(status: AuthStatus.authenticated);

    } catch (e, st) {
      print('❌ Email login error: $e\n$st');

      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: "Something went wrong",
      );

      await _session.logout();
    }
  }*/



  Future<void> loginWithEmail(String email, String password) async {
    state = const AuthState(status: AuthStatus.emailLoading);

    try {
      UserCredential credential;

      try {
        /// ✅ NORMAL LOGIN
        credential = await FirebaseAuth.instance
            .signInWithEmailAndPassword(
          email: email,
          password: password,
        );

      } on FirebaseAuthException catch (e) {

        print("🔥 Firebase Code: ${e.code}");

        /// 🔴 USER EXISTS BUT NO PASSWORD (GOOGLE USER)
        if (e.code == 'wrong-password' || e.code == 'invalid-credential') {

          final user = FirebaseAuth.instance.currentUser;

          if (user != null && user.email == email) {

            /// 🔥 LINK PASSWORD WITH GOOGLE ACCOUNT
            final credentialLink = EmailAuthProvider.credential(
              email: email,
              password: password,
            );

            await user.linkWithCredential(credentialLink);

            /// 🔁 NOW LOGIN AGAIN
            credential = await FirebaseAuth.instance
                .signInWithEmailAndPassword(
              email: email,
              password: password,
            );

          } else {
            state = const AuthState(
              status: AuthStatus.error,
              errorMessage: "Wrong password",
            );
            return;
          }

        }

        /// 🔴 NEW USER → CREATE
        else if (e.code == 'user-not-found') {

          credential = await FirebaseAuth.instance
              .createUserWithEmailAndPassword(
            email: email,
            password: password,
          );

        }

        else {
          state = AuthState(
            status: AuthStatus.error,
            errorMessage: e.message ?? "Login failed",
          );
          return;
        }
      }

      /// ✅ USER CHECK
      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        state = const AuthState(
          status: AuthStatus.error,
          errorMessage: "User not found",
        );
        return;
      }

      /// 🔵 API CALL
      final userRepository = _ref.read(userRepositoryProvider);

      final result = await userRepository.addUser(
        phone: "",
        fireBaseId: firebaseUser.uid,
        name: firebaseUser.email ?? "NA",
        email: firebaseUser.email ?? "NA",
        city: "NA",
      );

      if (!result.success || result.data == null) {
        state = AuthState(
          status: AuthStatus.error,
          errorMessage: result.message,
        );
        return;
      }

      final user = result.data!;

      /// 🔴 NEED REGISTRATION
      if (!user.register) {
        state = AuthState(
          status: AuthStatus.needsRegistration,
          user: user,
        );
        return;
      }

      /// ✅ SAVE SESSION
      await _session.saveLogin(
        uid: firebaseUser.uid,
        loginType: LoginType.email,
      );

      state = const AuthState(status: AuthStatus.authenticated);

    } catch (e, st) {
      print('❌ Email login error: $e\n$st');

      state = const AuthState(
        status: AuthStatus.error,
        errorMessage: "Something went wrong",
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
  emailLoading,
  googleLoading,
  authenticated,
  unauthenticated,
  error,
  needsRegistration, // ✅ ADD THIS
}



class AuthState {
  final AuthStatus status;
  final String? errorMessage;
  final UserModel? user; // ✅ ADD THIS

  const AuthState({
    required this.status,
    this.errorMessage,
    this.user,
  });

  factory AuthState.initial() => const AuthState(status: AuthStatus.initial);
  bool get isAuthenticated => status == AuthStatus.authenticated;
  bool get isUnauthenticated => status == AuthStatus.unauthenticated;
  bool get hasError => status == AuthStatus.error;
}



/// *******************************************************************************************
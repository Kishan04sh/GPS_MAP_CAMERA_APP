// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:google_sign_in/google_sign_in.dart';
// import '../api/api_exception.dart';
//
//
// class GoogleAuthService {
//   final FirebaseAuth _firebaseAuth;
//   final GoogleSignIn _googleSignIn;
//
//   GoogleAuthService({
//     FirebaseAuth? firebaseAuth,
//     GoogleSignIn? googleSignIn,
//   })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
//         _googleSignIn = googleSignIn ?? GoogleSignIn();
//
//   Future<User> signInWithGoogle() async {
//     try {
//       final googleUser = await _googleSignIn.signIn();
//       if (googleUser == null) {
//         throw ApiException("Login cancelled by user");
//       }
//
//       final googleAuth = await googleUser.authentication;
//
//       final credential = GoogleAuthProvider.credential(
//         accessToken: googleAuth.accessToken,
//         idToken: googleAuth.idToken,
//       );
//
//       final userCredential = await _firebaseAuth.signInWithCredential(credential);
//
//       return userCredential.user!;
//     } catch (e) {
//       print("error ${e.toString()}");
//       throw ApiException("Google login failed. Please try again.");
//     }
//   }
//
//   Future<void> signOut() async {
//     await _googleSignIn.signOut();
//     await _firebaseAuth.signOut();
//   }
//
//
// }




import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../api/api_exception.dart';


/// **************************************************************************

class GoogleAuthService {
  final FirebaseAuth _firebaseAuth;
  final GoogleSignIn _googleSignIn;

  GoogleAuthService({ FirebaseAuth? firebaseAuth, GoogleSignIn? googleSignIn,})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  /// ===================== LOGIN =====================
  Future<User> signInWithGoogle() async {
    try {
      print('🔵 Google sign-in started');

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        print('🟡 Google sign-in cancelled by user');
        throw ApiException('Login cancelled by user');
      }

      print('🟢 Google account selected: ${googleUser.email}');

      final googleAuth = await googleUser.authentication;

      print('🟢 Google auth tokens received');

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);

      print('✅ Google sign-in success | UID: ${userCredential.user?.uid}');

      return userCredential.user!;
    } catch (e) {
      print('❌ Google sign-in error: $e');
      throw ApiException('Google login failed. Please try again.');
    }
  }

  /// ===================== LOGOUT =====================
  Future<void> signOut() async {
    try {
      print('🔵 Logout started');

      await _googleSignIn.signOut();
      print('🟢 Google account signed out');

      await _firebaseAuth.signOut();
      print('🟢 Firebase auth signed out');

      print('✅ Logout completed successfully');
    } catch (e) {
      print('❌ Logout error: $e');
      throw ApiException('Logout failed. Please try again.');
    }
  }
}

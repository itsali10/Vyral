import 'package:google_sign_in/google_sign_in.dart';

/// Returns Google ID token for backend [POST /auth/google], or null if cancelled.
class GoogleSignInHelper {
  GoogleSignInHelper._();

  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  static bool _cancelRequested = false;

  static Future<String?> signInAndGetIdToken() async {
    _cancelRequested = false;
    final account = await _googleSignIn.signIn();
    if (_cancelRequested || account == null) return null;
    final auth = await account.authentication;
    if (_cancelRequested) return null;
    return auth.idToken;
  }

  /// Stops an in-progress sign-in and clears the Google session picker.
  static Future<void> cancelSignIn() async {
    _cancelRequested = true;
    try {
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect();
    } catch (_) {
      await _googleSignIn.signOut();
    }
  }

  static Future<void> signOut() async {
    await _googleSignIn.signOut();
  }
}

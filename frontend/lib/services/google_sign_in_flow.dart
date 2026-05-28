import 'package:flutter/material.dart';

import '../screens/google_sign_in_progress_screen.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/api_error_messages.dart';

/// Starts Google sign-in with an in-app cancel screen, then logs in via the API.
class GoogleSignInFlow {
  GoogleSignInFlow._();

  /// Returns `true` if the user signed in successfully.
  static Future<bool> run(
    BuildContext context, {
    void Function()? onSuccess,
  }) async {
    final token = await Navigator.of(context).push<String?>(
      MaterialPageRoute<String?>(
        fullscreenDialog: true,
        builder: (_) => const GoogleSignInProgressScreen(),
      ),
    );

    if (token == null || token.isEmpty) {
      return false;
    }

    try {
      await AuthService.instance.loginWithGoogleIdToken(token);
      onSuccess?.call();
      return true;
    } on ApiException catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(friendlyApiMessage(e, authContext: true))),
        );
      }
      return false;
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Google sign-in failed. Try email and password.'),
          ),
        );
      }
      return false;
    }
  }
}

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_scaffold.dart';
import 'change_password_screen.dart';
import 'forgot_password_screen.dart';

class PasswordSecurityScreen extends StatelessWidget {
  const PasswordSecurityScreen({super.key});

  Future<void> _sendResetEmail(BuildContext context) async {
    var userEmail = AuthService.instance.user?.email;
    userEmail ??= await _resolveEmail();
    if (userEmail == null || userEmail.isEmpty) {
      if (!context.mounted) return;
      Navigator.of(context).push<void>(
        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
      );
      return;
    }
    try {
      await AuthService.instance.forgotPassword(email: userEmail);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('If your account exists, a reset link was sent to your email'),
        ),
      );
    } on ApiException catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e, authContext: true))),
      );
    }
  }

  Future<String?> _resolveEmail() async {
    try {
      final data = await ApiClient.instance.get('/users/me');
      return data['email'] as String?;
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return VyralScaffold(
      appBar: AppBar(
        title: Text('Password & security', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.lock_reset_rounded),
            title: const Text('Change password'),
            subtitle: const Text('Update your password while logged in'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => Navigator.of(context).push<void>(
              MaterialPageRoute<void>(builder: (_) => const ChangePasswordScreen()),
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.mail_outline_rounded),
            title: const Text('Email reset link'),
            subtitle: const Text('Send a password reset link to your account email'),
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => _sendResetEmail(context),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/google_sign_in_flow.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_scaffold.dart';

/// Explains Google linking and avoids trapping users in the system sign-in UI.
class LinkedAccountsScreen extends StatefulWidget {
  const LinkedAccountsScreen({super.key});

  @override
  State<LinkedAccountsScreen> createState() => _LinkedAccountsScreenState();
}

class _LinkedAccountsScreenState extends State<LinkedAccountsScreen> {
  bool _busy = false;

  Future<void> _tryGoogle() async {
    setState(() => _busy = true);
    try {
      final ok = await GoogleSignInFlow.run(
        context,
        onSuccess: () {
          if (!mounted) return;
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Signed in with Google')),
          );
        },
      );
      if (!ok && mounted) {
        _snack('Google sign-in was cancelled');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  @override
  Widget build(BuildContext context) {
    final email = AuthService.instance.user?.email ?? '—';

    return VyralScaffold(
      appBar: AppBar(
        title: Text('Linked accounts', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(
            'Your Vyral account',
            style: VyralTypography.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.mail_outline_rounded),
            title: Text(email),
            subtitle: const Text('Sign-in email (email & password)'),
          ),
          const SizedBox(height: 24),
          Text(
            'Google',
            style: VyralTypography.inter(fontWeight: FontWeight.w600, fontSize: 15),
          ),
          const SizedBox(height: 8),
          Text(
            'Optional. Not required for the course demo — email login works with the backend.',
            style: VyralTypography.inter(
              fontSize: 13,
              color: VyralColors.secondaryText,
            ),
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: _busy ? null : _tryGoogle,
            icon: _busy
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('G', style: TextStyle(fontWeight: FontWeight.bold)),
            label: const Text('Sign in with Google'),
          ),
          const SizedBox(height: 12),
          Text(
            'A Cancel button appears on the Vyral screen while Google opens. '
            'If you only see Google\'s screen, press Back (◀) once to return to Vyral, then tap Cancel.',
            style: VyralTypography.inter(fontSize: 12, color: VyralColors.secondaryText),
          ),
        ],
      ),
    );
  }
}

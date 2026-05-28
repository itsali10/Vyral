import 'package:flutter/material.dart';

import '../services/google_sign_in_helper.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';

/// Full-screen Vyral UI with a clear **Cancel** while Google sign-in runs.
/// If the system Google screen opens on top, use Back or return here and tap Cancel.
class GoogleSignInProgressScreen extends StatefulWidget {
  const GoogleSignInProgressScreen({super.key});

  @override
  State<GoogleSignInProgressScreen> createState() =>
      _GoogleSignInProgressScreenState();
}

class _GoogleSignInProgressScreenState extends State<GoogleSignInProgressScreen> {
  bool _cancelling = false;
  bool _finished = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _runSignIn());
  }

  Future<void> _runSignIn() async {
    final token = await GoogleSignInHelper.signInAndGetIdToken();
    if (!mounted || _cancelling) return;
    _finished = true;
    Navigator.of(context).pop(token);
  }

  Future<void> _cancel() async {
    if (_cancelling || _finished) return;
    setState(() => _cancelling = true);
    await GoogleSignInHelper.cancelSignIn();
    if (!mounted) return;
    Navigator.of(context).pop<String?>(null);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _cancel();
      },
      child: Scaffold(
        backgroundColor: bg,
        appBar: AppBar(
          backgroundColor: bg,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.close_rounded),
            tooltip: 'Cancel',
            onPressed: _cancelling ? null : _cancel,
          ),
          title: Text(
            'Google sign-in',
            style: VyralTypography.inter(
              fontSize: 17,
              fontWeight: FontWeight.w500,
              color: heading,
            ),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const Spacer(),
                if (_cancelling)
                  const CircularProgressIndicator()
                else
                  const CircularProgressIndicator(),
                const SizedBox(height: 20),
                Text(
                  _cancelling ? 'Cancelling…' : 'Connecting to Google',
                  style: VyralTypography.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: heading,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'If the Google account screen opened on top of this, finish sign-in there '
                  'or tap Cancel below to return to Vyral.',
                  style: VyralTypography.inter(fontSize: 14, color: muted),
                  textAlign: TextAlign.center,
                ),
                const Spacer(),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: FilledButton(
                    onPressed: _cancelling ? null : _cancel,
                    style: FilledButton.styleFrom(
                      backgroundColor: VyralColors.error,
                      foregroundColor: VyralColors.white,
                    ),
                    child: Text(
                      'Cancel',
                      style: VyralTypography.inter(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: _cancelling ? null : _cancel,
                  child: Text(
                    'Back to Vyral',
                    style: VyralTypography.inter(
                      fontSize: 15,
                      color: muted,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

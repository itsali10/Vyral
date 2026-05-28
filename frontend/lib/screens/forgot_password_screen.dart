import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/api_client.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_input_field.dart';
import '../widgets/vyral_scaffold.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitting = false;
  bool _sent = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final email = _emailController.text.trim();
    return RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$').hasMatch(email);
  }

  Future<void> _submit() async {
    if (!_emailValid) return;
    setState(() => _submitting = true);
    try {
      await AuthService.instance.forgotPassword(
        email: _emailController.text.trim(),
      );
      if (!mounted) return;
      setState(() => _sent = true);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e, authContext: true))),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Request failed. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final body = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;

    return VyralScaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Reset password',
          style: VyralTypography.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: heading,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: _sent
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Icon(Icons.mark_email_read_outlined,
                      size: 48, color: heading),
                  const SizedBox(height: 16),
                  Text(
                    'Check your email',
                    style: VyralTypography.display(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: heading,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'If an account exists for ${_emailController.text.trim()}, '
                    'you will receive a password reset link.',
                    style: VyralTypography.inter(fontSize: 14, color: body),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Back to login'),
                  ),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Enter your email and we will send a reset link.',
                    style: VyralTypography.inter(fontSize: 14, color: body),
                  ),
                  const SizedBox(height: 24),
                  VyralInputField(
                    label: 'Email',
                    hint: 'you@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _submitting || !_emailValid ? null : _submit,
                    child: _submitting
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Send reset link'),
                  ),
                ],
              ),
      ),
    );
  }
}

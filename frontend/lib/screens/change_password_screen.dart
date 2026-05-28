import 'package:flutter/material.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_theme.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_input_field.dart';
import '../widgets/vyral_scaffold.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _submitting = false;
  bool _obscure = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final current = _currentController.text;
    final next = _newController.text;
    final confirm = _confirmController.text;

    if (next.length < 8) {
      _snack('New password must be at least 8 characters');
      return;
    }
    if (next != confirm) {
      _snack('New passwords do not match');
      return;
    }

    setState(() => _submitting = true);
    try {
      await AuthService.instance.changePassword(
        currentPassword: current,
        newPassword: next,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password updated successfully')),
      );
    } on ApiException catch (e) {
      _snack(friendlyApiMessage(e, authContext: true));
    } catch (e) {
      _snack('Could not update password: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _snack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    return VyralScaffold(
      appBar: AppBar(
        title: Text('Change password', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          VyralInputField(
            controller: _currentController,
            label: 'Current password',
            hint: 'Enter current password',
            obscureText: _obscure,
          ),
          const SizedBox(height: 12),
          VyralInputField(
            controller: _newController,
            label: 'New password',
            hint: 'At least 8 characters',
            obscureText: _obscure,
          ),
          const SizedBox(height: 12),
          VyralInputField(
            controller: _confirmController,
            label: 'Confirm new password',
            hint: 'Repeat new password',
            obscureText: _obscure,
          ),
          const SizedBox(height: 8),
          Text(
            'Use at least 8 characters with letters and numbers.',
            style: VyralTypography.inter(fontSize: 12, color: VyralColors.secondaryText),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _submitting ? null : _submit,
            style: FilledButton.styleFrom(
              backgroundColor: VyralColors.primaryRose,
              minimumSize: const Size.fromHeight(48),
            ),
            child: _submitting
                ? const SizedBox(
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Update password'),
          ),
        ],
      ),
    );
  }
}

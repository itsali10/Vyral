import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_input_field.dart';
import '../widgets/vyral_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _bioController = TextEditingController();
  bool _saving = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile =
          AuthService.instance.user ?? await UsersApiService.instance.getMe();
      _fullNameController.text = profile.fullName;
      _usernameController.text = profile.username;
      _bioController.text = profile.bio ?? '';
      if (mounted) setState(() => _loaded = true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not load profile: $e')),
        );
      }
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  bool get _usernameValid {
    final u = _usernameController.text.trim();
    return u.length >= 3 &&
        u.length <= 20 &&
        RegExp(r'^[a-zA-Z0-9_.]+$').hasMatch(u);
  }

  bool get _canSave =>
      _loaded &&
      !_saving &&
      _fullNameController.text.trim().isNotEmpty &&
      _usernameValid;

  Future<void> _save() async {
    if (!_canSave) return;
    setState(() => _saving = true);
    try {
      await UsersApiService.instance.updateMe({
        'fullName': _fullNameController.text.trim(),
        'username': _usernameController.text.trim(),
        'bio': _bioController.text.trim(),
      });
      await AuthService.instance.refreshProfile();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated')),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update profile: $e')),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;

    return VyralScaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? VyralColors.surface : VyralColors.cardBackground,
        elevation: 0,
        title: Text(
          'Edit profile',
          style: VyralTypography.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: heading,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          TextButton(
            onPressed: _canSave ? _save : null,
            child: _saving
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    'Save',
                    style: VyralTypography.inter(
                      fontWeight: FontWeight.w600,
                      color: heading,
                    ),
                  ),
          ),
        ],
      ),
      body: !_loaded
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  VyralInputField(
                    label: 'Full name',
                    hint: 'Full name',
                    controller: _fullNameController,
                  ),
                  const SizedBox(height: 16),
                  VyralInputField(
                    label: 'Username',
                    hint: 'username',
                    controller: _usernameController,
                  ),
                  if (!_usernameValid &&
                      _usernameController.text.trim().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        '3–20 characters: letters, numbers, . and _',
                        style: VyralTypography.inter(
                          fontSize: 12,
                          color: VyralColors.error,
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _bioController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      labelText: 'Bio',
                      hintText: 'Tell people about you',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

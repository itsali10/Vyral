import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_universal_actions.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final _fullNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  late final TapGestureRecognizer _termsTap;
  late final TapGestureRecognizer _privacyTap;

  bool _obscurePassword = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _termsTap = TapGestureRecognizer()..onTap = _openTerms;
    _privacyTap = TapGestureRecognizer()..onTap = _openPrivacy;
  }

  Future<void> _openTerms() async {
    final uri = Uri.parse('https://vyral.app/terms');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open terms')),
      );
    }
  }

  Future<void> _openPrivacy() async {
    final uri = Uri.parse('https://vyral.app/privacy');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open privacy policy')),
      );
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _termsTap.dispose();
    _privacyTap.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final v = _emailController.text.trim();
    final emailRegex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    return emailRegex.hasMatch(v);
  }

  int get _passwordStrengthLevel {
    final p = _passwordController.text;
    if (p.isEmpty) return 0;
    if (p.length < 8) return 1;
    final hasUpper = RegExp(r'[A-Z]').hasMatch(p);
    final hasDigit = RegExp(r'[0-9]').hasMatch(p);
    final hasSymbol = RegExp(r'[^A-Za-z0-9]').hasMatch(p);
    final points = [hasUpper, hasDigit, hasSymbol].where((v) => v).length;
    if (points == 0) return 2;
    if (points == 1) return 3;
    return 4;
  }

  bool get _canSubmit {
    return _fullNameController.text.trim().isNotEmpty &&
        _usernameController.text.trim().length >= 3 &&
        _emailValid &&
        _passwordController.text.length >= 8;
  }

  Future<void> _onCreateAccount() async {
    if (!_canSubmit) return;

    setState(() => _submitting = true);
    try {
      await AuthService.instance.register(
        fullName: _fullNameController.text.trim(),
        username: _usernameController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      if (!mounted) return;
      await Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(friendlyApiMessage(e, authContext: true)),
          duration: const Duration(seconds: 4),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Sign up failed. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final bodyText = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;
    final inputBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final inputText = isDark ? VyralColors.offWhite : VyralColors.primaryText;
    final divider = isDark ? VyralColors.blueGray.withValues(alpha: 0.35) : VyralColors.border;
    final buttonEnabledBg = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final buttonDisabledBg = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.4)
        : VyralColors.secondaryBackground;
    final buttonEnabledFg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final buttonDisabledFg = isDark ? VyralColors.mutedText : VyralColors.placeholder;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: MediaQuery.of(context).size.height
                  - MediaQuery.of(context).padding.top
                  - MediaQuery.of(context).padding.bottom,
            ),
            child: IntrinsicHeight(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      child: Row(
                        children: [
                          const Spacer(),
                          const VyralUniversalActions(),
                        ],
                      ),
                    ),
                    const Spacer(),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Center(
                            child: Text(
                              'vyral',
                              style: VyralTypography.display(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: heading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 28),
                          Text(
                            'Create account',
                            style: VyralTypography.display(
                              fontSize: 26,
                              fontWeight: FontWeight.bold,
                              color: heading,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Join the community',
                            style: VyralTypography.inter(
                              fontSize: 14,
                              color: bodyText,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 170),
                      child: Column(
                        children: [
                          _LabeledInput(
                            label: 'Full Name',
                            hint: 'Full Name',
                            controller: _fullNameController,
                            backgroundColor: inputBg,
                            textColor: inputText,
                            labelColor: bodyText,
                            placeholderColor: VyralColors.placeholder,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          _LabeledInput(
                            label: 'Username',
                            hint: '@username',
                            controller: _usernameController,
                            backgroundColor: inputBg,
                            textColor: inputText,
                            labelColor: bodyText,
                            placeholderColor: VyralColors.placeholder,
                            onChanged: (_) => setState(() {}),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 250),
                      child: Column(
                        children: [
                          _LabeledInput(
                            label: 'Email',
                            hint: 'email@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            backgroundColor: inputBg,
                            hasError: _emailController.text.isNotEmpty && !_emailValid,
                            textColor: inputText,
                            labelColor: bodyText,
                            placeholderColor: VyralColors.placeholder,
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          _LabeledInput(
                            label: 'Password',
                            hint: 'min. 8 characters',
                            controller: _passwordController,
                            obscureText: _obscurePassword,
                            backgroundColor: inputBg,
                            textColor: inputText,
                            labelColor: bodyText,
                            placeholderColor: VyralColors.placeholder,
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: bodyText,
                                size: 22,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 12),
                          _StrengthBar(
                            activeLevel: _passwordStrengthLevel,
                            activeColor: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                            inactiveColor: divider,
                            textColor: isDark ? VyralColors.softPink : VyralColors.primaryDark,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 330),
                      child: AnimatedPressable(
                        enabled: !_submitting,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submitting || !_canSubmit ? null : _onCreateAccount,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _canSubmit ? buttonEnabledBg : buttonDisabledBg,
                              foregroundColor: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                              disabledBackgroundColor: buttonDisabledBg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(26),
                              ),
                            ),
                            child: _submitting
                                ? SizedBox(
                                    width: 22,
                                    height: 22,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Continue',
                                        style: VyralTypography.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w700,
                                          color: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                                        ),
                                      ),
                                      const SizedBox(width: 10),
                                      Icon(
                                        Icons.arrow_forward,
                                        size: 16,
                                        color: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const Spacer(),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 400),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: VyralTypography.inter(
                              fontSize: 14,
                              color: bodyText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                            child: Text(
                              'Log in',
                              style: VyralTypography.inter(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: heading,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

OutlineInputBorder _fieldBorder(bool hasError) {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(14),
    borderSide: hasError
        ? const BorderSide(color: VyralColors.error)
        : BorderSide.none,
  );
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.backgroundColor,
    required this.textColor,
    required this.labelColor,
    required this.placeholderColor,
    this.keyboardType,
    this.obscureText = false,
    this.hasError = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Color backgroundColor;
  final bool hasError;
  final Color textColor;
  final Color labelColor;
  final Color placeholderColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: VyralTypography.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: labelColor,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: obscureText,
          onChanged: onChanged,
          style: VyralTypography.inter(
            fontSize: 15,
            color: textColor,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: VyralTypography.inter(fontSize: 15, color: placeholderColor),
            filled: true,
            fillColor: backgroundColor,
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            suffixIcon: suffixIcon,
            border: _fieldBorder(hasError),
            enabledBorder: _fieldBorder(hasError),
            focusedBorder: _fieldBorder(hasError),
            errorBorder: _fieldBorder(true),
            focusedErrorBorder: _fieldBorder(true),
          ),
        ),
      ],
    );
  }
}

class _StrengthBar extends StatelessWidget {
  const _StrengthBar({
    required this.activeLevel,
    required this.activeColor,
    required this.inactiveColor,
    required this.textColor,
  });

  final int activeLevel;
  final Color activeColor;
  final Color inactiveColor;
  final Color textColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            4,
            (index) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: index < 3 ? 8 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: index < activeLevel ? activeColor : inactiveColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 6),
        if (activeLevel >= 3)
          Text(
            'Strong password',
            style: VyralTypography.inter(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: textColor,
            ),
          ),
      ],
    );
  }
}

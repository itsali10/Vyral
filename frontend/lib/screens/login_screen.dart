import 'package:flutter/material.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/google_sign_in_flow.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_universal_actions.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _attemptedSubmit = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool get _emailValid {
    final email = _emailController.text.trim();
    final regex = RegExp(r'^[\w-.]+@([\w-]+\.)+[\w-]{2,}$');
    return regex.hasMatch(email);
  }

  bool get _canSubmit => _emailValid && _passwordController.text.isNotEmpty;

  bool _submitting = false;
  bool _googleSubmitting = false;

  Future<void> _onGoogle() async {
    setState(() => _googleSubmitting = true);
    try {
      await GoogleSignInFlow.run(
        context,
        onSuccess: () {
          if (!mounted) return;
          Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
        },
      );
    } finally {
      if (mounted) setState(() => _googleSubmitting = false);
    }
  }

  Future<void> _onLogIn() async {
    setState(() => _attemptedSubmit = true);
    if (!_canSubmit) return;

    setState(() => _submitting = true);
    try {
      await AuthService.instance.login(
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
        const SnackBar(content: Text('Login failed. Check your connection.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final panelBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final bodyText = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;
    final inputBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final inputBorder = isDark ? VyralColors.blueGray : VyralColors.border;
    final inputText = isDark ? VyralColors.offWhite : VyralColors.primaryText;
    final watermark = isDark
        ? VyralColors.white.withValues(alpha: 0.04)
        : VyralColors.primaryText.withValues(alpha: 0.04);
    final divider = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.35)
        : VyralColors.border;
    final buttonEnabledBg = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final buttonDisabledBg = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.4)
        : VyralColors.secondaryBackground;
    final buttonEnabledFg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final buttonDisabledFg = isDark ? VyralColors.mutedText : VyralColors.placeholder;
    final emailError = _attemptedSubmit && _emailController.text.isNotEmpty && !_emailValid;

    return Scaffold(
      backgroundColor: pageBg,
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: IgnorePointer(
                child: Center(
                  child: Text(
                    'V',
                    style: VyralTypography.display(
                      fontSize: 210,
                      fontWeight: FontWeight.bold,
                      color: watermark,
                    ),
                  ),
                ),
              ),
            ),
            SingleChildScrollView(
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
                    const SizedBox(height: 10),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 80),
                      child: Column(
                        children: [
                          Center(
                            child: Text(
                              'v.',
                              style: VyralTypography.display(
                                fontSize: 44 / 2,
                                fontWeight: FontWeight.w700,
                                color: heading,
                              ),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Text(
                            'Welcome back to vyral',
                            textAlign: TextAlign.center,
                            style: VyralTypography.inter(
                              fontSize: 17,
                              fontWeight: FontWeight.w700,
                              color: heading,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 36),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 160),
                      child: _RoundedInput(
                        controller: _emailController,
                        hintText: 'hello@vyral',
                        keyboardType: TextInputType.emailAddress,
                        borderColor: emailError ? VyralColors.error : inputBorder,
                        backgroundColor: inputBg,
                        textColor: inputText,
                        placeholderColor: VyralColors.placeholder,
                        onChanged: (_) => setState(() {}),
                      ),
                    ),
                    if (emailError)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
                        child: Text(
                          'Please enter a valid email address',
                          style: VyralTypography.inter(
                            fontSize: 12,
                            color: VyralColors.error,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const SizedBox(height: 12),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 230),
                      child: Column(
                        children: [
                          _RoundedInput(
                            controller: _passwordController,
                            hintText: 'password123',
                            obscureText: _obscurePassword,
                            borderColor: inputBorder,
                            backgroundColor: inputBg,
                            textColor: inputText,
                            placeholderColor: VyralColors.placeholder,
                            suffix: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                color: bodyText,
                              ),
                            ),
                            onChanged: (_) => setState(() {}),
                          ),
                          const SizedBox(height: 8),
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/forgot-password'),
                              child: Text(
                                'Forgot password?',
                                style: VyralTypography.inter(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: bodyText,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 310),
                      child: AnimatedPressable(
                        enabled: !_submitting,
                        child: SizedBox(
                          height: 52,
                          child: ElevatedButton(
                            onPressed: _submitting ? null : _onLogIn,
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: _canSubmit ? buttonEnabledBg : buttonDisabledBg,
                              foregroundColor: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(28),
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
                                : Text(
                                    'Log in',
                                    style: VyralTypography.inter(
                                      fontSize: 31 / 2,
                                      fontWeight: FontWeight.w700,
                                      color: _canSubmit ? buttonEnabledFg : buttonDisabledFg,
                                    ),
                                  ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 390),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              Expanded(child: Divider(color: divider, thickness: 1)),
                              Padding(
                                padding: const EdgeInsets.symmetric(horizontal: 10),
                                child: Text(
                                  'or',
                                  style: VyralTypography.inter(
                                    fontSize: 12,
                                    color: bodyText,
                                  ),
                                ),
                              ),
                              Expanded(child: Divider(color: divider, thickness: 1)),
                            ],
                          ),
                          const SizedBox(height: 18),
                          AnimatedPressable(
                            enabled: !_googleSubmitting,
                            child: SizedBox(
                              height: 52,
                              child: OutlinedButton(
                                onPressed: _googleSubmitting ? null : _onGoogle,
                                style: OutlinedButton.styleFrom(
                                  foregroundColor: heading,
                                  side: BorderSide(color: inputBorder),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(28),
                                  ),
                                  backgroundColor: isDark ? panelBg : VyralColors.cardBackground,
                                ),
                                child: _googleSubmitting
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(strokeWidth: 2),
                                      )
                                    : Text(
                                        'G   Continue with Google',
                                        style: VyralTypography.inter(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w600,
                                          color: heading,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 54),
                    FadeSlideIn(
                      delay: const Duration(milliseconds: 460),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            "Don't have an account?",
                            style: VyralTypography.inter(
                              fontSize: 14,
                              color: bodyText,
                            ),
                          ),
                          TextButton(
                            onPressed: () => Navigator.pushReplacementNamed(context, '/signup'),
                            child: Text(
                              'Sign up',
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
                    const SizedBox(height: 10),
                    Center(
                      child: Container(
                        width: 120,
                        height: 4,
                        decoration: BoxDecoration(
                          color: divider,
                          borderRadius: BorderRadius.circular(99),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoundedInput extends StatelessWidget {
  const _RoundedInput({
    required this.controller,
    required this.hintText,
    required this.borderColor,
    required this.backgroundColor,
    required this.textColor,
    required this.placeholderColor,
    this.keyboardType,
    this.obscureText = false,
    this.suffix,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hintText;
  final Color borderColor;
  final Color backgroundColor;
  final Color textColor;
  final Color placeholderColor;
  final TextInputType? keyboardType;
  final bool obscureText;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      onChanged: onChanged,
      style: VyralTypography.inter(
        fontSize: 15,
        color: textColor,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: VyralTypography.inter(
          fontSize: 15,
          color: placeholderColor,
        ),
        filled: true,
        fillColor: backgroundColor,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        suffixIcon: suffix,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: borderColor, width: 1.2),
        ),
      ),
    );
  }
}

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/vyral_navigation_drawer.dart';
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
    _termsTap = TapGestureRecognizer()..onTap = () => _showStub('Terms');
    _privacyTap = TapGestureRecognizer()..onTap = () => _showStub('Privacy Policy');
  }

  void _showStub(String title) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$title — link placeholder')),
    );
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
      final credential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
      );
      await credential.user?.updateDisplayName(_fullNameController.text.trim());
      if (!mounted) return;
      await Navigator.of(context).pushNamedAndRemoveUntil('/home', (route) => false);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message ?? 'Could not create account')),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Sign up failed: $e')),
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
    final divider = isDark ? VyralColors.blueGray.withValues(alpha: 0.35) : VyralColors.border;
    final buttonEnabledBg = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final buttonDisabledBg = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.4)
        : VyralColors.secondaryBackground;
    final buttonEnabledFg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final buttonDisabledFg = isDark ? VyralColors.mutedText : VyralColors.placeholder;

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Container(
              color: panelBg,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      VyralOpenNavMenuButton(color: heading),
                      const Spacer(),
                      VyralUniversalActions(
                        trailing: [
                          IconButton(
                            tooltip: 'Skip to home',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.of(context).pushNamed('/home'),
                            icon: Icon(
                              Icons.home_outlined,
                              color: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 24),
                  _AvatarPrompt(
                    textColor: bodyText,
                    borderColor: inputBorder,
                    accentColor: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                    bgColor: inputBg,
                  ),
                  const SizedBox(height: 18),
                  _LabeledInput(
                    label: 'Full Name',
                    hint: 'Full Name',
                    controller: _fullNameController,
                    backgroundColor: inputBg,
                    borderColor: inputBorder,
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
                    borderColor: inputBorder,
                    textColor: inputText,
                    labelColor: bodyText,
                    placeholderColor: VyralColors.placeholder,
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  _LabeledInput(
                    label: 'Email',
                    hint: 'email@example.com',
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    backgroundColor: inputBg,
                    borderColor: _emailController.text.isEmpty || _emailValid
                        ? inputBorder
                        : VyralColors.error,
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
                    borderColor: inputBorder,
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
                  const SizedBox(height: 14),
                  SizedBox(
                    height: 52,
                    child: ElevatedButton(
                      onPressed: _submitting ? null : _onCreateAccount,
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
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: Divider(color: divider, thickness: 1)),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
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
                  const SizedBox(height: 16),
                  SizedBox(
                    height: 52,
                    child: OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        foregroundColor: heading,
                        side: BorderSide(color: inputBorder),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(26),
                        ),
                        backgroundColor: isDark ? panelBg : VyralColors.cardBackground,
                      ),
                      child: Text(
                        'G   Continue with Google',
                        style: VyralTypography.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: heading,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text.rich(
                    textAlign: TextAlign.center,
                    TextSpan(
                      children: [
                        TextSpan(
                          text: 'By signing up, you agree to our ',
                          style: VyralTypography.inter(
                            fontSize: 12,
                            color: bodyText,
                            height: 1.4,
                          ),
                        ),
                        TextSpan(
                          text: 'Terms',
                          style: VyralTypography.inter(
                            fontSize: 12,
                            color: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _termsTap,
                        ),
                        TextSpan(
                          text: ' & ',
                          style: VyralTypography.inter(
                            fontSize: 12,
                            color: bodyText,
                            height: 1.4,
                          ),
                        ),
                        TextSpan(
                          text: 'Privacy Policy',
                          style: VyralTypography.inter(
                            fontSize: 12,
                            color: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                          recognizer: _privacyTap,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
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
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _AvatarPrompt extends StatelessWidget {
  const _AvatarPrompt({
    required this.textColor,
    required this.borderColor,
    required this.accentColor,
    required this.bgColor,
  });

  final Color textColor;
  final Color borderColor;
  final Color accentColor;
  final Color bgColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: bgColor,
                border: Border.all(color: borderColor),
              ),
            ),
            Positioned(
              right: -2,
              bottom: -2,
              child: Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.add, color: Colors.white, size: 15),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Text(
          'Add profile photo',
          style: VyralTypography.inter(color: textColor, fontSize: 14),
        ),
      ],
    );
  }
}

class _LabeledInput extends StatelessWidget {
  const _LabeledInput({
    required this.label,
    required this.hint,
    required this.controller,
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.labelColor,
    required this.placeholderColor,
    this.keyboardType,
    this.obscureText = false,
    this.suffixIcon,
    this.onChanged,
  });

  final String label;
  final String hint;
  final TextEditingController controller;
  final Color backgroundColor;
  final Color borderColor;
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
            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            suffixIcon: suffixIcon,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: borderColor, width: 1.2),
            ),
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

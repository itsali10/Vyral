import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_universal_actions.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoCtrl;
  late final Animation<double> _logoScale;

  @override
  void initState() {
    super.initState();
    _logoCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3600),
    )..repeat(reverse: true);
    _logoScale = Tween(begin: 1.0, end: 1.04).animate(
      CurvedAnimation(parent: _logoCtrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _logoCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeScope.of(context).themeMode == ThemeMode.dark;

    final screenBg =
        isDark ? VyralColors.background : VyralColors.mainBackground;
    final logoColor = isDark ? VyralColors.white : VyralColors.primaryText;
    final sparkleColor =
        isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final sloganColor =
        isDark ? VyralColors.offWhite : VyralColors.primaryText;
    final copyColor =
        isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final dividerColor = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.45)
        : VyralColors.border;

    return Scaffold(
      backgroundColor: screenBg,
      body: SafeArea(
        child: Column(
              children: [
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 0),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Row(
                      children: [
                        const Spacer(),
                        const VyralUniversalActions(),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: AnimatedBuilder(
                    animation: _logoScale,
                    builder: (_, child) => Transform.scale(
                      scale: _logoScale.value,
                      child: child,
                    ),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        Container(
                          width: 184,
                          height: 184,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: (isDark
                                    ? VyralColors.blueGray
                                    : VyralColors.secondaryBackground)
                                .withValues(alpha: isDark ? 0.34 : 0.82),
                          ),
                        ),
                        Positioned(
                          top: 72,
                          left: 0,
                          right: 0,
                          child: Text(
                            'vyral',
                            textAlign: TextAlign.center,
                            style: VyralTypography.display(
                              fontSize: 72,
                              height: 0.9,
                              fontWeight: FontWeight.bold,
                              color: logoColor,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 38,
                          top: 56,
                          child: PulseAnimation(
                            duration: const Duration(milliseconds: 1800),
                            child: Icon(
                              Icons.auto_awesome,
                              size: 14,
                              color: sparkleColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 34),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 220),
                  child: Text(
                    'POST IT. PIN IT. OWN IT.',
                    style: VyralTypography.inter(
                      fontSize: 27 / 2,
                      letterSpacing: 1.4,
                      fontWeight: FontWeight.w700,
                      color: sloganColor,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 52),
                    child:
                        Divider(color: dividerColor, height: 1, thickness: 1),
                  ),
                ),
                const SizedBox(height: 40),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 380),
                  child: Text(
                    'The space to curate your world, share\nyour vision, and own your influence.',
                    textAlign: TextAlign.center,
                    style: VyralTypography.inter(
                      fontSize: 29 / 2,
                      height: 1.45,
                      color: copyColor,
                    ),
                  ),
                ),
                const Spacer(),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: AnimatedPressable(
                      child: SizedBox(
                        height: 56,
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () =>
                              Navigator.pushNamed(context, '/signup'),
                          style: ElevatedButton.styleFrom(
                            elevation: 0,
                            backgroundColor: isDark
                                ? VyralColors.softPink
                                : VyralColors.primaryRose,
                            foregroundColor: isDark
                                ? VyralColors.deepBlack
                                : VyralColors.cardBackground,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: Text(
                            'Create Account',
                            style: VyralTypography.inter(
                              fontSize: 28 / 2,
                              fontWeight: FontWeight.w700,
                              color: isDark
                                  ? VyralColors.deepBlack
                                  : VyralColors.cardBackground,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 580),
                  child: AnimatedPressable(
                    child: TextButton(
                      onPressed: () => Navigator.pushNamed(context, '/login'),
                      child: Text(
                        'Log In',
                        style: VyralTypography.inter(
                          fontSize: 26 / 2,
                          fontWeight: FontWeight.w700,
                          color:
                              isDark ? VyralColors.white : VyralColors.primaryText,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        );
  }
}

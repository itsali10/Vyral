import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = ThemeScope.of(context).themeMode == ThemeMode.dark;

    final screenBg = isDark ? const Color(0xFF1F2126) : VyralColors.mainBackground;
    final panelBg = isDark ? const Color(0xFF3C3F4A) : VyralColors.mainBackground;
    final logoColor = isDark ? VyralColors.white : VyralColors.primaryText;
    final sparkleColor = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final sloganColor = isDark ? VyralColors.offWhite : VyralColors.primaryText;
    final copyColor = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final dividerColor = isDark
        ? VyralColors.blueGray.withValues(alpha: 0.45)
        : VyralColors.border;

    return Scaffold(
      backgroundColor: screenBg,
      drawer: const VyralNavigationDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 12, 18, 12),
          child: Container(
            color: panelBg,
            child: Column(
              children: [
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Row(
                    children: [
                      VyralOpenNavMenuButton(color: logoColor),
                      const Spacer(),
                      VyralUniversalActions(
                        trailing: [
                          IconButton(
                            tooltip: 'Skip to home',
                            visualDensity: VisualDensity.compact,
                            onPressed: () => Navigator.pushNamed(context, '/home'),
                            icon: Icon(
                              Icons.double_arrow_rounded,
                              color: isDark ? VyralColors.white : VyralColors.primaryText,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const Spacer(),
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 184,
                      height: 184,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: (isDark ? VyralColors.blueGray : VyralColors.secondaryBackground)
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
                      child: Icon(Icons.auto_awesome, size: 14, color: sparkleColor),
                    ),
                  ],
                ),
                const SizedBox(height: 34),
                Text(
                  'POST IT. PIN IT. OWN IT.',
                  style: VyralTypography.inter(
                    fontSize: 27 / 2,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                    color: sloganColor,
                  ),
                ),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 52),
                  child: Divider(color: dividerColor, height: 1, thickness: 1),
                ),
                const SizedBox(height: 40),
                Text(
                  'The space to curate your world, share\nyour vision, and own your influence.',
                  textAlign: TextAlign.center,
                  style: VyralTypography.inter(
                    fontSize: 29 / 2,
                    height: 1.45,
                    color: copyColor,
                  ),
                ),
                const Spacer(),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SizedBox(
                    height: 56,
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pushNamed(context, '/signup'),
                      style: ElevatedButton.styleFrom(
                        elevation: 0,
                        backgroundColor: isDark ? VyralColors.softPink : VyralColors.primaryRose,
                        foregroundColor: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Create account',
                        style: VyralTypography.inter(
                          fontSize: 28 / 2,
                          fontWeight: FontWeight.w700,
                          color: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                TextButton(
                  onPressed: () => Navigator.pushNamed(context, '/login'),
                  child: Text(
                    'Log in',
                    style: VyralTypography.inter(
                      fontSize: 26 / 2,
                      fontWeight: FontWeight.w700,
                      color: isDark ? VyralColors.white : VyralColors.primaryText,
                    ),
                  ),
                ),
                const SizedBox(height: 22),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

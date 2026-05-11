import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

/// Brand accents for settings rows (warm, iOS-adjacent).
abstract final class SettingsPalette {
  static const Color pink = Color(0xFFD4537E);
  static const Color pinkLight = Color(0xFFFBEAF0);
  static const Color pinkMid = Color(0xFFF4C0D1);
  static const Color teal = Color(0xFF1D9E75);
  static const Color coral = Color(0xFFD85A30);
  static const Color purple = Color(0xFF7F77DD);
  static const Color amber = Color(0xFFBA7517);
  static const Color amberLight = Color(0xFFFAEEDA);
  static const Color blue = Color(0xFF378ADD);
  static const Color badgeSoonText = Color(0xFF854F0B);
  static const Color badgeNewText = Color(0xFF993556);
}

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _showLikesPublicly = true;
  bool _notifLikes = true;
  bool _notifComments = true;
  bool _notifFollowers = true;
  bool _notifTrending = false;
  bool _dataSaver = false;
  bool _haptics = true;

  Future<void> _openPrivacy() async {
    final uri = Uri.parse('https://vyral.app/privacy');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
  }

  void _logToggle(String label, bool value) {
    debugPrint('Settings toggle "$label": $value');
  }

  Future<void> _confirmLogOut() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to sign back in."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: VyralColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      debugPrint('Settings: log out confirmed');
    }
  }

  Future<void> _confirmDelete() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete account?'),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: VyralColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (go == true && mounted) {
      debugPrint('Settings: delete account confirmed');
    }
  }

  void _openEditProfile() {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (context) => const _EditProfileScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final cardBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final border = isDark ? VyralColors.blueGray : VyralColors.border;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final appBarBg = isDark ? VyralColors.surface : VyralColors.cardBackground;

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: appBarBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        shadowColor: Colors.transparent,
        surfaceTintColor: Colors.transparent,
        foregroundColor: heading,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded, size: 28),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: Text(
          'Settings',
          style: VyralTypography.inter(
            fontSize: 17,
            fontWeight: FontWeight.w500,
            color: heading,
          ),
        ),
        actions: [
          VyralOpenNavMenuButton(color: heading, size: 22),
          const VyralUniversalActions(compact: true),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 48),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SettingsSection(
              label: 'Account',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: _avatarGradient(),
                  label: 'Alex Rivera',
                  subtitle: '@alexrivera',
                  onPress: _openEditProfile,
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.lock_outline_rounded, size: 22, color: SettingsPalette.purple),
                  label: 'Password & security',
                  onPress: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Password & security — coming soon')),
                  ),
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.link_rounded, size: 22, color: SettingsPalette.blue),
                  label: 'Linked accounts',
                  subtitle: 'Connect Instagram, Pinterest',
                  badgeText: 'Soon',
                  badgeVariant: SettingsBadgeVariant.soon,
                  onPress: () => ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Linked accounts — coming soon')),
                  ),
                  right: SettingsRight.badge,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'Privacy',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: Icon(Icons.visibility_outlined, size: 22, color: SettingsPalette.teal),
                  label: 'Profile visibility',
                  subtitle: 'Public',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.person_off_outlined, size: 22, color: SettingsPalette.coral),
                  label: 'Blocked accounts',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.volume_off_outlined, size: 22, color: SettingsPalette.amber),
                  label: 'Muted words',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.favorite_border_rounded, size: 22, color: SettingsPalette.pink),
                  label: 'Show likes publicly',
                  toggleValue: _showLikesPublicly,
                  onToggle: (v) {
                    setState(() => _showLikesPublicly = v);
                    _logToggle('Show likes publicly', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'Appearance',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
                  child: Row(
                    children: [
                      Icon(Icons.light_mode_outlined, size: 22, color: heading.withValues(alpha: 0.85)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Theme',
                          style: VyralTypography.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w400,
                            color: heading,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                  child: _ThemeSegmentedControl(
                    themeMode: ThemeScope.of(context).themeMode,
                    onChanged: ThemeScope.of(context).onThemeModeChanged,
                  ),
                ),
                SettingsRow(
                  icon: Icon(Icons.palette_outlined, size: 22, color: SettingsPalette.purple),
                  label: 'Accent color',
                  subtitle: 'Dusty rose · default',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.grid_view_rounded, size: 22, color: SettingsPalette.teal),
                  label: 'Explore grid density',
                  subtitle: 'Comfortable',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'Notifications',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: Icon(Icons.favorite_border_rounded, size: 22, color: SettingsPalette.pink),
                  label: 'Likes',
                  toggleValue: _notifLikes,
                  onToggle: (v) {
                    setState(() => _notifLikes = v);
                    _logToggle('Likes', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 22, color: SettingsPalette.blue),
                  label: 'Comments',
                  toggleValue: _notifComments,
                  onToggle: (v) {
                    setState(() => _notifComments = v);
                    _logToggle('Comments', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.person_add_alt_1_outlined, size: 22, color: SettingsPalette.teal),
                  label: 'New followers',
                  toggleValue: _notifFollowers,
                  onToggle: (v) {
                    setState(() => _notifFollowers = v);
                    _logToggle('New followers', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.trending_up_rounded, size: 22, color: SettingsPalette.amber),
                  label: 'Your post is trending',
                  toggleValue: _notifTrending,
                  onToggle: (v) {
                    setState(() => _notifTrending = v);
                    _logToggle('Trending', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'Content',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: Icon(Icons.tune_rounded, size: 22, color: SettingsPalette.purple),
                  label: 'Feed preferences',
                  subtitle: 'Tune what you see',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.language_rounded, size: 22, color: SettingsPalette.teal),
                  label: 'Language',
                  subtitle: 'English',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.accessibility_new_rounded, size: 22, color: SettingsPalette.blue),
                  label: 'Accessibility',
                  subtitle: 'Text size, contrast, motion',
                  badgeText: 'New',
                  badgeVariant: SettingsBadgeVariant.newBadge,
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'App',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: Icon(Icons.wifi_off_rounded, size: 22, color: SettingsPalette.amber),
                  label: 'Data saver',
                  subtitle: 'Load lower-res images',
                  toggleValue: _dataSaver,
                  onToggle: (v) {
                    setState(() => _dataSaver = v);
                    _logToggle('Data saver', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.vibration_rounded, size: 22, color: SettingsPalette.coral),
                  label: 'Haptic feedback',
                  toggleValue: _haptics,
                  onToggle: (v) {
                    setState(() => _haptics = v);
                    _logToggle('Haptic feedback', v);
                  },
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.shield_outlined, size: 22, color: SettingsPalette.teal),
                  label: 'Privacy policy',
                  onPress: _openPrivacy,
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.info_outline_rounded, size: 22, color: muted),
                  label: 'About Vyral',
                  subtitle: 'v1.0.0',
                  onPress: () {},
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
            SettingsSection(
              label: 'Danger zone',
              cardBg: cardBg,
              borderColor: border,
              muted: muted,
              heading: heading,
              children: [
                SettingsRow(
                  icon: Icon(Icons.logout_rounded, size: 22, color: SettingsPalette.coral),
                  label: 'Log out',
                  danger: true,
                  onPress: _confirmLogOut,
                  right: SettingsRight.none,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.delete_outline_rounded, size: 22, color: SettingsPalette.coral),
                  label: 'Delete account',
                  danger: true,
                  onPress: _confirmDelete,
                  right: SettingsRight.none,
                  heading: heading,
                  muted: muted,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarGradient() {
    return Container(
      width: 36,
      height: 36,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            SettingsPalette.pink,
            SettingsPalette.pinkMid,
          ],
        ),
      ),
      child: Text(
        'AR',
        style: VyralTypography.inter(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: VyralColors.white,
        ),
      ),
    );
  }
}

enum SettingsRight { chevron, toggle, badge, none }

enum SettingsBadgeVariant { soon, newBadge }

class SettingsSection extends StatelessWidget {
  const SettingsSection({
    super.key,
    required this.label,
    required this.children,
    required this.cardBg,
    required this.borderColor,
    required this.muted,
    required this.heading,
  });

  final String label;
  final List<Widget> children;
  final Color cardBg;
  final Color borderColor;
  final Color muted;
  final Color heading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 4, bottom: 8),
            child: Text(
              label.toUpperCase(),
              style: VyralTypography.inter(
                fontSize: 11,
                fontWeight: FontWeight.w500,
                letterSpacing: 0.77,
                color: muted,
              ),
            ),
          ),
          DecoratedBox(
            decoration: BoxDecoration(
              color: cardBg,
              borderRadius: BorderRadius.circular(12),
              border: Border(
                top: BorderSide(color: borderColor, width: 0.5),
                bottom: BorderSide(color: borderColor, width: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: heading.withValues(alpha: 0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _withSeparators(children, borderColor),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _withSeparators(List<Widget> rows, Color sep) {
    final out = <Widget>[];
    for (var i = 0; i < rows.length; i++) {
      out.add(rows[i]);
      if (i < rows.length - 1) {
        out.add(Divider(height: 0.5, thickness: 0.5, color: sep.withValues(alpha: 0.65)));
      }
    }
    return out;
  }
}

class SettingsRow extends StatelessWidget {
  const SettingsRow({
    super.key,
    required this.icon,
    required this.label,
    required this.heading,
    required this.muted,
    this.subtitle,
    this.onPress,
    this.right = SettingsRight.none,
    this.toggleValue,
    this.onToggle,
    this.badgeText,
    this.badgeVariant,
    this.danger = false,
  });

  final Widget icon;
  final String label;
  final String? subtitle;
  final VoidCallback? onPress;
  final SettingsRight right;
  final bool? toggleValue;
  final ValueChanged<bool>? onToggle;
  final String? badgeText;
  final SettingsBadgeVariant? badgeVariant;
  final bool danger;
  final Color heading;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final labelStyle = VyralTypography.inter(
      fontSize: 15,
      fontWeight: FontWeight.w400,
      color: danger ? SettingsPalette.coral : heading,
    );
    final subtitleStyle = VyralTypography.inter(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      color: muted,
    );

    Widget trailing() {
      switch (right) {
        case SettingsRight.chevron:
          if (badgeText != null) {
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _SettingsBadge(text: badgeText!, variant: badgeVariant ?? SettingsBadgeVariant.newBadge),
                const SizedBox(width: 6),
                Icon(Icons.chevron_right_rounded, color: muted, size: 22),
              ],
            );
          }
          return Icon(Icons.chevron_right_rounded, color: muted, size: 22);
        case SettingsRight.toggle:
          return Switch(
            value: toggleValue ?? false,
            onChanged: onToggle,
            activeThumbColor: SettingsPalette.pink,
            activeTrackColor: SettingsPalette.pink.withValues(alpha: 0.45),
            inactiveThumbColor: muted,
            inactiveTrackColor: muted.withValues(alpha: 0.25),
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
          );
        case SettingsRight.badge:
          return _SettingsBadge(text: badgeText ?? '', variant: badgeVariant ?? SettingsBadgeVariant.soon);
        case SettingsRight.none:
          return const SizedBox.shrink();
      }
    }

    final tappable = onPress != null && right != SettingsRight.toggle;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: tappable ? () => onPress!() : null,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 50),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(width: 28, child: Center(child: icon)),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: labelStyle),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(subtitle!, style: subtitleStyle),
                      ],
                    ],
                  ),
                ),
                trailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SettingsBadge extends StatelessWidget {
  const _SettingsBadge({required this.text, required this.variant});

  final String text;
  final SettingsBadgeVariant variant;

  @override
  Widget build(BuildContext context) {
    final bg = variant == SettingsBadgeVariant.soon
        ? SettingsPalette.amberLight
        : SettingsPalette.pinkLight;
    final fg = variant == SettingsBadgeVariant.soon
        ? SettingsPalette.badgeSoonText
        : SettingsPalette.badgeNewText;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: VyralTypography.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: fg,
        ),
      ),
    );
  }
}

class _ThemeSegmentedControl extends StatelessWidget {
  const _ThemeSegmentedControl({
    required this.themeMode,
    required this.onChanged,
  });

  final ThemeMode themeMode;
  final ValueChanged<ThemeMode> onChanged;

  int get _index {
    switch (themeMode) {
      case ThemeMode.light:
        return 0;
      case ThemeMode.dark:
        return 1;
      case ThemeMode.system:
        return 2;
    }
  }

  @override
  Widget build(BuildContext context) {
    const labels = ['Light', 'Dark', 'Auto'];
    const modes = [ThemeMode.light, ThemeMode.dark, ThemeMode.system];

    return Row(
      children: List.generate(3, (i) {
        final selected = _index == i;
        return Expanded(
          child: Padding(
            padding: EdgeInsets.only(left: i == 0 ? 0 : 6),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => onChanged(modes[i]),
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: selected ? SettingsPalette.pinkLight : Colors.transparent,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: selected ? SettingsPalette.pinkMid : Colors.transparent,
                      width: 1,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    labels[i],
                    style: VyralTypography.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: selected ? SettingsPalette.badgeNewText : const Color(0xFF6E6E6E),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _EditProfileScreen extends StatelessWidget {
  const _EditProfileScreen();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    return Scaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: isDark ? VyralColors.surface : VyralColors.cardBackground,
        elevation: 0,
        title: Text(
          'Edit profile',
          style: VyralTypography.inter(fontSize: 17, fontWeight: FontWeight.w500, color: heading),
        ),
        leading: IconButton(
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Text(
          'Edit your profile here.',
          style: VyralTypography.inter(fontSize: 15, color: isDark ? VyralColors.mutedText : VyralColors.secondaryText),
        ),
      ),
    );
  }
}

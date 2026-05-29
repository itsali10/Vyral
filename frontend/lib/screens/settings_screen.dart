import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/settings_preferences.dart';
import '../services/settings_api_service.dart';
import '../services/users_api_service.dart';
import '../utils/api_error_messages.dart';
import 'blocked_accounts_screen.dart';
import 'edit_profile_screen.dart';
import 'muted_words_screen.dart';
import 'linked_accounts_screen.dart';
import 'password_security_screen.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_scaffold.dart';
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
  bool _loading = true;
  int _blockedCount = 0;

  @override
  void initState() {
    super.initState();
    SettingsPreferences.instance.addListener(_onPrefsChanged);
    _loadPrefs();
  }

  @override
  void dispose() {
    SettingsPreferences.instance.removeListener(_onPrefsChanged);
    super.dispose();
  }

  void _onPrefsChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadPrefs() async {
    await SettingsPreferences.instance.loadFromApi();
    await _loadBlockedCount();
    if (!mounted) return;
    setState(() => _loading = false);
  }

  Future<void> _loadBlockedCount() async {
    try {
      final items = await SettingsApiService.instance.getBlockedUsers();
      if (!mounted) return;
      setState(() => _blockedCount = items.length);
    } catch (_) {
      // Keep previous count if the request fails.
    }
  }

  Future<void> _persistToggle(String apiKey, bool value) async {
    try {
      await SettingsPreferences.instance.update({apiKey: value});
    } on ApiException catch (e) {
      if (!mounted) return;
      _showSnack(friendlyApiMessage(e));
    }
  }

  String _blockedAccountsSubtitle() {
    if (_blockedCount == 0) {
      return 'Search users to block';
    }
    if (_blockedCount == 1) {
      return '1 blocked account';
    }
    return '$_blockedCount blocked accounts';
  }

  Future<void> _openBlockAccounts() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => const BlockedAccountsScreen(autofocusSearch: true),
      ),
    );
    await _loadBlockedCount();
  }

  Future<void> _openPrivacy() async {
    final uri = Uri.parse('https://vyral.app/privacy');
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication) && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open link')),
      );
    }
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
      await AuthService.instance.logout();
      if (!mounted) return;
      await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
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
      try {
        await AuthService.instance.deleteAccount();
        if (!mounted) return;
        await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
      } on ApiException catch (e) {
        if (!mounted) return;
        _showSnack(friendlyApiMessage(e, authContext: true));
      } catch (e) {
        if (!mounted) return;
        _showSnack('Could not delete account: $e');
      }
    }
  }

  Future<void> _openEditProfile() async {
    final updated = await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(builder: (context) => const EditProfileScreen()),
    );
    if (updated == true && mounted) setState(() {});
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _toggleProfileVisibility() async {
    final current = AuthService.instance.user;
    if (current == null) return;
    final nextPrivate = !current.isPrivate;
    try {
      await UsersApiService.instance.updateMe({'isPrivate': nextPrivate});
      await AuthService.instance.refreshProfile();
      if (!mounted) return;
      setState(() {});
      _showSnack(nextPrivate ? 'Profile is private' : 'Profile is public');
    } on ApiException catch (e) {
      _showSnack(friendlyApiMessage(e));
    } catch (e) {
      _showSnack('Could not update visibility: $e');
    }
  }

  void _showAboutDialog() {
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('About Vyral'),
        content: const Text(
          'Vyral is a social feed app built with Flutter and NestJS.\n\n'
          'Version 1.0.0',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _openLanguage() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Language'),
        content: const Text('English (US) is the only language available in this build.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _openAccessibility() async {
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Accessibility'),
        content: const Text(
          'Use your device system settings for text size and display scaling. '
          'Vyral respects the platform accessibility settings.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('OK')),
        ],
      ),
    );
  }

  Future<void> _toggleGridDensity() async {
    final compact = !SettingsPreferences.instance.exploreGridCompact;
    try {
      await SettingsPreferences.instance.update({'exploreGridCompact': compact});
      _showSnack(compact ? 'Explore grid: compact' : 'Explore grid: comfortable');
    } on ApiException catch (e) {
      _showSnack(friendlyApiMessage(e));
    }
  }

  Future<void> _openLinkedAccounts() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(builder: (_) => const LinkedAccountsScreen()),
    );
    if (mounted) setState(() {});
  }

  String _userInitials() {
    final name = AuthService.instance.user?.fullName.trim() ?? '';
    if (name.isEmpty) return 'VY';
    final parts = name.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }
    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
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

    return VyralScaffold(
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
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
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
                  icon: _avatarGradient(_userInitials()),
                  label: AuthService.instance.user?.fullName ?? 'Your profile',
                  subtitle: AuthService.instance.user?.displayUsername ?? '@username',
                  onPress: _openEditProfile,
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.lock_outline_rounded, size: 22, color: SettingsPalette.purple),
                  label: 'Password & security',
                  onPress: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(
                      builder: (context) => const PasswordSecurityScreen(),
                    ),
                  ),
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.link_rounded, size: 22, color: SettingsPalette.blue),
                  label: 'Linked accounts',
                  subtitle: AuthService.instance.user?.email ?? 'Email sign-in',
                  onPress: _openLinkedAccounts,
                  right: SettingsRight.chevron,
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
                  subtitle: AuthService.instance.user?.isPrivate == true
                      ? 'Private'
                      : 'Public',
                  onPress: _toggleProfileVisibility,
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.block_rounded, size: 22, color: SettingsPalette.coral),
                  label: 'Block account',
                  subtitle: _blockedAccountsSubtitle(),
                  onPress: _openBlockAccounts,
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.volume_off_outlined, size: 22, color: SettingsPalette.amber),
                  label: 'Muted words',
                  subtitle: SettingsPreferences.instance.settings.mutedWords.isEmpty
                      ? 'None configured'
                      : '${SettingsPreferences.instance.settings.mutedWords.length} word(s)',
                  onPress: () => Navigator.of(context).push<void>(
                    MaterialPageRoute<void>(builder: (_) => const MutedWordsScreen()),
                  ),
                  right: SettingsRight.chevron,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.favorite_border_rounded, size: 22, color: SettingsPalette.pink),
                  label: 'Show likes publicly',
                  toggleValue: SettingsPreferences.instance.settings.showLikesPublicly,
                  onToggle: (v) => _persistToggle('showLikesPublicly', v),
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
                  icon: Icon(Icons.grid_view_rounded, size: 22, color: SettingsPalette.teal),
                  label: 'Explore grid density',
                  subtitle: SettingsPreferences.instance.exploreGridCompact
                      ? 'Compact'
                      : 'Comfortable',
                  onPress: _toggleGridDensity,
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
                  toggleValue: SettingsPreferences.instance.settings.notifLikes,
                  onToggle: (v) => _persistToggle('notifLikes', v),
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.chat_bubble_outline_rounded, size: 22, color: SettingsPalette.blue),
                  label: 'Comments',
                  toggleValue: SettingsPreferences.instance.settings.notifComments,
                  onToggle: (v) => _persistToggle('notifComments', v),
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.person_add_alt_1_outlined, size: 22, color: SettingsPalette.teal),
                  label: 'New followers',
                  toggleValue: SettingsPreferences.instance.settings.notifFollowers,
                  onToggle: (v) => _persistToggle('notifFollowers', v),
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
                  icon: Icon(Icons.language_rounded, size: 22, color: SettingsPalette.teal),
                  label: 'Language',
                  subtitle: 'English',
                  onPress: _openLanguage,
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
                  onPress: _openAccessibility,
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
                  toggleValue: SettingsPreferences.instance.dataSaver,
                  onToggle: (v) => _persistToggle('dataSaver', v),
                  right: SettingsRight.toggle,
                  heading: heading,
                  muted: muted,
                ),
                SettingsRow(
                  icon: Icon(Icons.vibration_rounded, size: 22, color: SettingsPalette.coral),
                  label: 'Haptic feedback',
                  toggleValue: SettingsPreferences.instance.hapticsEnabled,
                  onToggle: (v) => _persistToggle('hapticsEnabled', v),
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
                  onPress: _showAboutDialog,
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

  Widget _avatarGradient(String initials) {
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
        initials,
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


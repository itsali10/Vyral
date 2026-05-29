import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import '../theme/vyral_theme.dart';
import 'auth_guard.dart';
import '../theme/vyral_typography.dart';

/// Opens the [Scaffold.drawer] from a child of that scaffold.
class VyralOpenNavMenuButton extends StatelessWidget {
  const VyralOpenNavMenuButton({
    super.key,
    this.color,
    this.size = 24,
  });

  final Color? color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'All screens',
      visualDensity: VisualDensity.compact,
      icon: Icon(Icons.menu_rounded, size: size, color: color),
      onPressed: () => Scaffold.of(context).openDrawer(),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.route,
    required this.title,
    required this.subtitle,
    required this.icon,
    this.push = false,
  });

  final String route;
  final String title;
  final String? subtitle;
  final IconData icon;
  final bool push;
}

/// One-tap navigation to every named route in the app.
class VyralNavigationDrawer extends StatelessWidget {
  const VyralNavigationDrawer({super.key});

  static const _main = <_NavItem>[
    _NavItem(route: '/home', title: 'Home', subtitle: 'Your feed', icon: Icons.home_outlined),
    _NavItem(route: '/explore', title: 'Explore', subtitle: 'Discover posts', icon: Icons.grid_view_outlined),
    _NavItem(route: '/create', title: 'Create', subtitle: 'New post', icon: Icons.add_circle_outline, push: true),
    _NavItem(route: '/saved', title: 'Saved', subtitle: 'Collections', icon: Icons.bookmark_outline),
    _NavItem(route: '/profile', title: 'Profile', subtitle: 'Your posts', icon: Icons.person_outline),
    _NavItem(route: '/settings', title: 'Settings', subtitle: 'Theme & privacy', icon: Icons.settings_outlined),
  ];

  static const _guestAccount = <_NavItem>[
    _NavItem(route: '/', title: 'Welcome', subtitle: 'Start screen', icon: Icons.waving_hand_outlined),
    _NavItem(route: '/login', title: 'Log in', subtitle: null, icon: Icons.login_rounded),
    _NavItem(route: '/signup', title: 'Sign up', subtitle: null, icon: Icons.person_add_alt_1_outlined),
  ];

  void _go(BuildContext context, _NavItem item) {
    if (vyralRouteRequiresAuth(item.route) && !AuthService.instance.isLoggedIn) {
      Navigator.of(context).pop();
      Navigator.of(context).pushReplacementNamed('/');
      return;
    }
    final nav = Navigator.of(context);
    final current = ModalRoute.of(context)?.settings.name;
    nav.pop();
    if (current == item.route) return;
    if (item.push) {
      nav.pushNamed(item.route);
    } else {
      nav.pushReplacementNamed(item.route);
    }
  }

  Future<void> _confirmLogout(BuildContext context) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Log out?'),
        content: const Text("You'll need to sign back in."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: VyralColors.error),
            child: const Text('Log out'),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    Navigator.of(context).pop();
    await AuthService.instance.logout();
    if (!context.mounted) return;
    await Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AuthService.instance,
      builder: (context, _) {
        final loggedIn = AuthService.instance.isLoggedIn;
        final isDark = Theme.of(context).brightness == Brightness.dark;
        final bg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
        final heading = isDark ? VyralColors.white : VyralColors.primaryText;
        final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
        final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
        final current = ModalRoute.of(context)?.settings.name;

        Widget sectionTitle(String text) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              text.toUpperCase(),
              style: VyralTypography.inter(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.7,
                color: muted,
              ),
            ),
          );
        }

        Widget tile(_NavItem item) {
          final selected = current == item.route;
          return Material(
            color: selected
                ? accent.withValues(alpha: isDark ? 0.12 : 0.14)
                : Colors.transparent,
            child: ListTile(
              leading: Icon(item.icon, color: selected ? accent : muted, size: 22),
              title: Text(
                item.title,
                style: VyralTypography.inter(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                  color: heading,
                ),
              ),
              subtitle: item.subtitle != null
                  ? Text(
                      item.subtitle!,
                      style: VyralTypography.inter(fontSize: 12, color: muted),
                    )
                  : null,
              onTap: () => _go(context, item),
            ),
          );
        }

        return Drawer(
          backgroundColor: bg,
          child: SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(bottom: 8),
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                        child: Row(
                          children: [
                            Text(
                              'vyral',
                              style: VyralTypography.display(
                                fontSize: 26,
                                fontWeight: FontWeight.w600,
                                color: heading,
                              ),
                            ),
                            const Spacer(),
                            Icon(Icons.auto_awesome, size: 18, color: accent),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
                        child: Text(
                          'Go anywhere',
                          style: VyralTypography.inter(fontSize: 13, color: muted),
                        ),
                      ),
                      if (loggedIn) ...[
                        sectionTitle('App'),
                        ..._main.map(tile),
                      ] else ...[
                        const Divider(height: 1),
                        sectionTitle('Account'),
                        ..._guestAccount.map(tile),
                      ],
                    ],
                  ),
                ),
                if (loggedIn)
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
                    child: Material(
                      color: VyralColors.error.withValues(alpha: isDark ? 0.12 : 0.08),
                      borderRadius: BorderRadius.circular(12),
                      child: ListTile(
                        leading: Icon(
                          Icons.logout_rounded,
                          color: VyralColors.error,
                          size: 22,
                        ),
                        title: Text(
                          'Log out',
                          style: VyralTypography.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: VyralColors.error,
                          ),
                        ),
                        subtitle: AuthService.instance.user != null
                            ? Text(
                                AuthService.instance.user!.displayUsername,
                                style: VyralTypography.inter(
                                  fontSize: 12,
                                  color: muted,
                                ),
                              )
                            : null,
                        onTap: () => _confirmLogout(context),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

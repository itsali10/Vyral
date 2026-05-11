import 'package:flutter/material.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';

/// Ordered routes for left/right arrows on auth flows.
const _authRoutes = ['/', '/login', '/signup'];

/// Main shell + settings (Create stays push-only from drawer / bottom nav).
const _mainShellRoutes = ['/home', '/explore', '/saved', '/profile', '/settings'];

const _collectionDetailName = '/collection-detail';

int _mod(int i, int n) => ((i % n) + n) % n;

/// Screen-to-screen navigation used by [VyralUniversalActions] chevrons.
abstract final class VyralShellNav {
  VyralShellNav._();

  static void goPrev(BuildContext context) => _go(context, -1);

  static void goNext(BuildContext context) => _go(context, 1);

  static void _go(BuildContext context, int delta) {
    final name = ModalRoute.of(context)?.settings.name;
    final nav = Navigator.of(context);

    if (name != null && _authRoutes.contains(name)) {
      final i = _authRoutes.indexOf(name);
      final next = _authRoutes[_mod(i + delta, _authRoutes.length)];
      nav.pushReplacementNamed(next);
      return;
    }

    if (name != null && _mainShellRoutes.contains(name)) {
      final i = _mainShellRoutes.indexOf(name);
      final next = _mainShellRoutes[_mod(i + delta, _mainShellRoutes.length)];
      nav.pushReplacementNamed(next);
      return;
    }

    if (name == '/create') {
      if (delta < 0) {
        if (nav.canPop()) {
          nav.pop();
        } else {
          nav.pushReplacementNamed('/explore');
        }
      } else {
        nav.pushReplacementNamed('/saved');
      }
      return;
    }

    if (name == _collectionDetailName) {
      if (delta < 0) {
        nav.pop();
      } else {
        nav.pushReplacementNamed('/home');
      }
      return;
    }

    if (delta < 0 && nav.canPop()) {
      nav.pop();
    } else {
      nav.pushReplacementNamed('/home');
    }
  }
}

/// Theme toggle + previous/next screen controls on every page.
///
/// [trailing] is drawn after the next chevron (e.g. skip-to-home on welcome).
class VyralUniversalActions extends StatelessWidget {
  const VyralUniversalActions({
    super.key,
    this.trailing = const <Widget>[],
    this.compact = false,
  });

  final List<Widget> trailing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final iconColor = isDark ? VyralColors.white : VyralColors.primaryText;
    final size = compact ? 22.0 : 24.0;
    final minSide = compact ? 36.0 : 40.0;

    Widget iconButton({
      required IconData icon,
      required String tooltip,
      required VoidCallback onPressed,
    }) {
      return IconButton(
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
        constraints: BoxConstraints(minWidth: minSide, minHeight: minSide),
        padding: EdgeInsets.zero,
        onPressed: onPressed,
        icon: Icon(icon, size: size, color: iconColor),
      );
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        iconButton(
          icon: Icons.chevron_left_rounded,
          tooltip: 'Previous screen',
          onPressed: () => VyralShellNav.goPrev(context),
        ),
        iconButton(
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          tooltip: 'Toggle light / dark mode',
          onPressed: () => ThemeScope.of(context).toggleTheme(),
        ),
        iconButton(
          icon: Icons.chevron_right_rounded,
          tooltip: 'Next screen',
          onPressed: () => VyralShellNav.goNext(context),
        ),
        ...trailing,
      ],
    );
  }
}

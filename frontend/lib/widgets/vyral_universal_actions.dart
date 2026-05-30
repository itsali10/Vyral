import 'package:flutter/material.dart';

import '../theme/theme_scope.dart';
import '../theme/vyral_theme.dart';

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
          icon: isDark ? Icons.light_mode_outlined : Icons.dark_mode_outlined,
          tooltip: 'Toggle light / dark mode',
          onPressed: () => ThemeScope.of(context).toggleTheme(),
        ),
        ...trailing,
      ],
    );
  }
}

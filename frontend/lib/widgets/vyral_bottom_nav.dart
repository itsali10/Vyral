import 'package:flutter/material.dart';

import '../theme/vyral_theme.dart';

/// Fixed bottom bar with optional [currentIndex] and [onDestinationSelected].
class VyralBottomNav extends StatelessWidget {
  const VyralBottomNav({
    super.key,
    required this.currentIndex,
    required this.onDestinationSelected,
  });

  final int currentIndex;
  final ValueChanged<int> onDestinationSelected;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final border = isDark ? VyralColors.surface : VyralColors.border;
    final selected = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final unselected = isDark ? VyralColors.navUnselected : VyralColors.secondaryText;

    return Material(
      elevation: 12,
      color: bg,
      child: DecoratedBox(
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: border, width: 1),
          ),
        ),
        child: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: bg,
          elevation: 0,
          currentIndex: currentIndex.clamp(0, 4),
          selectedItemColor: selected,
          unselectedItemColor: unselected,
          selectedFontSize: 12,
          unselectedFontSize: 11,
          iconSize: 24,
          onTap: onDestinationSelected,
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.home_outlined),
              activeIcon: Icon(Icons.home),
              label: 'Home',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.grid_view_outlined),
              activeIcon: Icon(Icons.grid_view),
              label: 'Explore',
            ),
            BottomNavigationBarItem(
              icon: const Icon(Icons.auto_awesome, size: 26),
              activeIcon: const Icon(Icons.auto_awesome, size: 26),
              label: 'Create',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.bookmark_border),
              activeIcon: Icon(Icons.bookmark),
              label: 'Saved',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.person_outline),
              activeIcon: Icon(Icons.person),
              label: 'Profile',
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../models/saved_collection.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class CollectionDetailScreen extends StatelessWidget {
  const CollectionDetailScreen({super.key, required this.collection});

  final SavedCollection collection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        foregroundColor: heading,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          color: heading,
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          collection.name,
          style: VyralTypography.display(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: heading,
          ),
        ),
        actions: [
          VyralOpenNavMenuButton(color: heading, size: 22),
          const VyralUniversalActions(compact: true),
        ],
      ),
      body: Center(
        child: Text(
          '${collection.postCount} saved posts',
          style: VyralTypography.inter(
            fontSize: 14,
            color: muted,
          ),
        ),
      ),
    );
  }
}

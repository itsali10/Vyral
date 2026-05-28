import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';

/// Returns collection id, or null for default "All saved".
Future<String?> showSaveCollectionPicker(BuildContext context) async {
  List<SavedCollectionModel> collections;
  try {
    collections = await UsersApiService.instance.getCollections();
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load collections: $e')),
      );
    }
    return null;
  }
  if (!context.mounted) return null;

  return showModalBottomSheet<String?>(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
    ),
    builder: (ctx) {
      final isDark = Theme.of(ctx).brightness == Brightness.dark;
      final heading = isDark ? VyralColors.white : VyralColors.primaryText;
      final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
      return SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
              child: Text(
                'Save to collection',
                style: VyralTypography.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: heading,
                ),
              ),
            ),
            ...collections.map(
              (c) => ListTile(
                leading: const Icon(Icons.bookmark_outline),
                title: Text(
                  c.name,
                  style: VyralTypography.inter(fontSize: 15, color: heading),
                ),
                subtitle: Text(
                  '${c.postCount} saved',
                  style: VyralTypography.inter(fontSize: 12, color: muted),
                ),
                onTap: () => Navigator.pop(ctx, c.id),
              ),
            ),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.bookmark),
              title: Text(
                'All saved (default)',
                style: VyralTypography.inter(fontSize: 15, color: heading),
              ),
              onTap: () => Navigator.pop(ctx, null),
            ),
            const SizedBox(height: 8),
          ],
        ),
      );
    },
  );
}

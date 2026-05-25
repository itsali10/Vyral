import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../models/saved_collection.dart';
import '../theme/vyral_theme.dart';
import '../screens/collection_detail_screen.dart';

class CollectionCard extends StatelessWidget {
  const CollectionCard({super.key, required this.collection});

  final SavedCollection collection;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? VyralColors.card : VyralColors.cardBackground;
    final shadow = isDark
        ? VyralColors.deepBlack.withValues(alpha: 0.2)
        : VyralColors.primaryText.withValues(alpha: 0.06);
    final gradStart = isDark ? VyralColors.surface : VyralColors.secondaryBackground;
    final gradEnd = isDark ? VyralColors.blueGray : VyralColors.border;
    final title = isDark ? VyralColors.white : VyralColors.primaryText;
    final subtitle = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;
    final arrow = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    return GestureDetector(
      onTap: () {
        Navigator.of(context).push<void>(
          MaterialPageRoute<void>(
            settings: const RouteSettings(name: '/collection-detail'),
            builder: (context) => CollectionDetailScreen(collection: collection),
          ),
        );
      },
      child: Container(
        height: 96,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: card,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: shadow,
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: Row(
                children: List.generate(
                  4,
                  (i) => Expanded(
                    child: Container(
                      color: Color.lerp(
                        gradStart,
                        gradEnd,
                        i * 0.25,
                      ),
                      height: 96,
                    ),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [
                      card.withValues(alpha: 0),
                      card,
                    ],
                    stops: const [0.55, 1.0],
                  ),
                ),
              ),
            ),
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    collection.name,
                    style: VyralTypography.inter(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                      color: title,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${collection.postCount} posts',
                    style: VyralTypography.inter(
                      fontSize: 12,
                      color: subtitle,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Icon(
                    Icons.arrow_forward,
                    color: arrow,
                    size: 16,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

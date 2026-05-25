import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';

class ExploreGridItem {
  const ExploreGridItem({
    required this.height,
    required this.label,
    required this.username,
    required this.imageColor,
  });

  final double height;
  final String label;
  final String username;
  final Color imageColor;
}

class GridPostCard extends StatelessWidget {
  const GridPostCard({super.key, required this.item});

  final ExploreGridItem item;

  @override
  Widget build(BuildContext context) {
    final imageH = item.height - 36;
    return SizedBox(
      height: item.height,
      child: Container(
        decoration: BoxDecoration(
          color: VyralColors.card,
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: imageH,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: item.imageColor,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                ),
              ),
            ),
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Padding(
                padding: const EdgeInsets.all(8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      item.label,
                      style: VyralTypography.inter(
                        fontSize: 13,
                        color: VyralColors.caption,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      item.username,
                      style: VyralTypography.inter(
                        fontSize: 10,
                        color: VyralColors.dustyRose,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

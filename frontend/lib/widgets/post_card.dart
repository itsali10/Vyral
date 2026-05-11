import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';

class Post {
  const Post({
    required this.username,
    required this.timeAgo,
    required this.hasImage,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
  });

  final String username;
  final String timeAgo;
  final bool hasImage;
  final String caption;
  final String likesCount;
  final String commentsCount;
}

class PostCard extends StatefulWidget {
  const PostCard({super.key, required this.post});

  final Post post;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  bool _liked = false;

  @override
  Widget build(BuildContext context) {
    final p = widget.post;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final card = isDark ? VyralColors.card : VyralColors.cardBackground;
    final shadow = isDark
        ? VyralColors.deepBlack.withValues(alpha: 0.25)
        : VyralColors.primaryText.withValues(alpha: 0.07);
    final avatar = isDark ? VyralColors.blueGray : VyralColors.secondaryBackground;
    final title = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final caption = isDark ? VyralColors.caption : VyralColors.primaryText;
    final like = isDark ? VyralColors.softPink : VyralColors.likeHighlight;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
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
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 17,
                  backgroundColor: avatar,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.username,
                        style: VyralTypography.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: title,
                        ),
                      ),
                      Text(
                        p.timeAgo,
                        style: VyralTypography.inter(
                          fontSize: 11,
                          color: muted,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.more_horiz, color: muted, size: 18),
              ],
            ),
            if (p.hasImage) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  width: double.infinity,
                  height: 120,
                  color: avatar,
                ),
              ),
            ],
            const SizedBox(height: 8),
            Text(
              p.caption,
              style: VyralTypography.inter(
                fontSize: 13,
                color: caption,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionChip(
                  icon: _liked ? Icons.favorite : Icons.favorite_border,
                  label: p.likesCount,
                  activeColor: like,
                  toggleable: true,
                  isActive: _liked,
                  onToggle: (v) => setState(() => _liked = v),
                ),
                const SizedBox(width: 16),
                _ActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: p.commentsCount,
                  activeColor: muted,
                  toggleable: false,
                  isActive: false,
                ),
                const SizedBox(width: 16),
                const _ActionChip(
                  icon: Icons.bookmark_border,
                  label: 'Save',
                  activeColor: VyralColors.mutedText,
                  toggleable: false,
                  isActive: false,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionChip extends StatelessWidget {
  const _ActionChip({
    required this.icon,
    required this.label,
    required this.activeColor,
    required this.toggleable,
    required this.isActive,
    this.onToggle,
  });

  final IconData icon;
  final String label;
  final Color activeColor;
  final bool toggleable;
  final bool isActive;
  final ValueChanged<bool>? onToggle;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? VyralColors.mutedText
        : VyralColors.secondaryText;
    final color = (toggleable && isActive) ? activeColor : base;
    return InkWell(
      onTap: toggleable && onToggle != null ? () => onToggle!(!isActive) : null,
      borderRadius: BorderRadius.circular(8),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: VyralTypography.inter(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

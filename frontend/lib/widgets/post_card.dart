import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../theme/vyral_typography.dart';

import '../services/auth_service.dart';
import '../services/posts_api_service.dart';
import '../services/settings_preferences.dart';
import '../theme/vyral_theme.dart';
import 'post_comments_sheet.dart';
import 'save_collection_sheet.dart';

class PostCard extends StatefulWidget {
  const PostCard({
    super.key,
    required this.post,
    this.onLike,
    this.onSave,
    this.onPostUpdated,
    this.onPostDeleted,
  });

  final FeedPost post;
  final Future<FeedPost> Function(FeedPost post, bool liked)? onLike;
  final Future<FeedPost> Function(
    FeedPost post,
    bool saved, {
    String? collectionId,
  })? onSave;
  final ValueChanged<FeedPost>? onPostUpdated;
  final ValueChanged<String>? onPostDeleted;

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  late FeedPost _post;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  @override
  void didUpdateWidget(PostCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.post.id != widget.post.id ||
        oldWidget.post.authorId != widget.post.authorId ||
        oldWidget.post.likesCount != widget.post.likesCount ||
        oldWidget.post.commentsCount != widget.post.commentsCount ||
        oldWidget.post.isLiked != widget.post.isLiked ||
        oldWidget.post.isSaved != widget.post.isSaved) {
      _post = widget.post;
    }
  }

  bool get _isOwner {
    final myId = AuthService.instance.user?.id;
    return myId != null &&
        _post.authorIdSafe.isNotEmpty &&
        myId == _post.authorIdSafe;
  }

  Future<void> _handleLike() async {
    if (_busy || widget.onLike == null) return;
    final targetLiked = !_post.isLiked;
    setState(() => _busy = true);
    try {
      final updated = await widget.onLike!(_post, targetLiked);
      if (!mounted) return;
      setState(() {
        _post = updated;
        _busy = false;
      });
      widget.onPostUpdated?.call(updated);
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update like: $e')),
      );
    }
  }

  Future<void> _handleSave() async {
    if (_busy || widget.onSave == null) return;
    final targetSaved = !_post.isSaved;
    String? collectionId;
    if (targetSaved) {
      collectionId = await showSaveCollectionPicker(context);
    }
    setState(() => _busy = true);
    try {
      final updated = await widget.onSave!(
        _post,
        targetSaved,
        collectionId: collectionId,
      );
      if (!mounted) return;
      setState(() {
        _post = updated;
        _busy = false;
      });
      widget.onPostUpdated?.call(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(targetSaved ? 'Post saved' : 'Removed from saved'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not save post: $e')),
      );
    }
  }

  void _openAuthorProfile() {
    if (_post.authorIdSafe.isEmpty) return;
    final myId = AuthService.instance.user?.id;
    if (_post.authorIdSafe == myId) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    Navigator.of(context).pushNamed('/user', arguments: _post.authorIdSafe);
  }

  Future<void> _openComments() async {
    final updated = await showPostCommentsSheet(context, post: _post);
    if (updated != null && mounted) {
      setState(() => _post = updated);
      widget.onPostUpdated?.call(updated);
    }
  }

  Future<void> _editPost() async {
    final controller = TextEditingController(text: _post.caption ?? '');
    final saved = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Edit caption'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: const InputDecoration(hintText: 'Caption'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (saved != true || !mounted) {
      controller.dispose();
      return;
    }
    setState(() => _busy = true);
    try {
      final updated = await PostsApiService.instance.updatePost(
        _post.id,
        caption: controller.text.trim(),
      );
      if (!mounted) return;
      setState(() {
        _post = updated;
        _busy = false;
      });
      widget.onPostUpdated?.call(updated);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post updated')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update post: $e')),
      );
    } finally {
      controller.dispose();
    }
  }

  Future<void> _deletePost() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete post?'),
        content: const Text("This can't be undone."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: VyralColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    setState(() => _busy = true);
    try {
      await PostsApiService.instance.deletePost(_post.id);
      if (!mounted) return;
      widget.onPostDeleted?.call(_post.id);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Post deleted')),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _busy = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not delete post: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = _post;
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
    final imageUrl = p.mediaUrls.isNotEmpty ? p.mediaUrls.first : null;

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
                InkWell(
                  onTap: _post.authorIdSafe.isEmpty ? null : _openAuthorProfile,
                  borderRadius: BorderRadius.circular(20),
                  child: CircleAvatar(
                    radius: 17,
                    backgroundColor: avatar,
                    backgroundImage: p.authorAvatarUrl != null
                        ? CachedNetworkImageProvider(p.authorAvatarUrl!)
                        : null,
                    child: p.authorAvatarUrl == null
                        ? Text(
                            p.username.replaceAll('@', '').isNotEmpty
                                ? p.username.replaceAll('@', '')[0].toUpperCase()
                                : '?',
                            style: VyralTypography.inter(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: title,
                            ),
                          )
                        : null,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _post.authorIdSafe.isEmpty ? null : _openAuthorProfile,
                    borderRadius: BorderRadius.circular(8),
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
                ),
                if (_isOwner)
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: muted, size: 18),
                    onSelected: (value) {
                      switch (value) {
                        case 'edit':
                          _editPost();
                          break;
                        case 'delete':
                          _deletePost();
                          break;
                      }
                    },
                    itemBuilder: (ctx) => [
                      const PopupMenuItem(
                        value: 'edit',
                        child: Text('Edit caption'),
                      ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Text('Delete post'),
                      ),
                    ],
                  )
                else
                  Icon(Icons.more_horiz, color: muted, size: 18),
              ],
            ),
            if (p.hasImage && imageUrl != null) ...[
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: CachedNetworkImage(
                  imageUrl: imageUrl,
                  memCacheWidth:
                      SettingsPreferences.instance.dataSaver ? 720 : null,
                  width: double.infinity,
                  height: 120,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(
                    height: 120,
                    color: avatar,
                  ),
                  errorWidget: (_, __, ___) => Container(
                    height: 120,
                    color: avatar,
                  ),
                ),
              ),
            ] else if (p.hasImage) ...[
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
            if (p.caption != null && p.caption!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                p.caption!,
                style: VyralTypography.inter(
                  fontSize: 13,
                  color: caption,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                _ActionChip(
                  icon: p.isLiked ? Icons.favorite : Icons.favorite_border,
                  label: p.likesLabel,
                  activeColor: like,
                  isActive: p.isLiked,
                  onTap: _busy ? null : _handleLike,
                ),
                const SizedBox(width: 16),
                _ActionChip(
                  icon: Icons.chat_bubble_outline,
                  label: p.commentsLabel,
                  activeColor: muted,
                  isActive: false,
                  onTap: _busy ? null : _openComments,
                ),
                const SizedBox(width: 16),
                _ActionChip(
                  icon: p.isSaved ? Icons.bookmark : Icons.bookmark_border,
                  label: p.isSaved ? 'Saved' : 'Save',
                  activeColor: like,
                  isActive: p.isSaved,
                  onTap: _busy ? null : _handleSave,
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
    required this.isActive,
    this.onTap,
  });

  final IconData icon;
  final String label;
  final Color activeColor;
  final bool isActive;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final base = Theme.of(context).brightness == Brightness.dark
        ? VyralColors.mutedText
        : VyralColors.secondaryText;
    final color = isActive ? activeColor : base;
    return InkWell(
      onTap: onTap,
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

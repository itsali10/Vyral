import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../services/api_client.dart';
import '../services/posts_api_service.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';

Future<FeedPost?> showPostCommentsSheet(
  BuildContext context, {
  required FeedPost post,
}) async {
  return showModalBottomSheet<FeedPost>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PostCommentsSheet(initialPost: post),
  );
}

class _PostCommentsSheet extends StatefulWidget {
  const _PostCommentsSheet({required this.initialPost});

  final FeedPost initialPost;

  @override
  State<_PostCommentsSheet> createState() => _PostCommentsSheetState();
}

class _PostCommentsSheetState extends State<_PostCommentsSheet> {
  late FeedPost _post;
  final _controller = TextEditingController();
  List<PostComment> _comments = [];
  bool _loading = true;
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final comments = await PostsApiService.instance.getComments(_post.id);
      if (!mounted) return;
      setState(() {
        _comments = comments;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load comments: $e')),
      );
    }
  }

  Future<void> _submit() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() => _submitting = true);
    try {
      final updated = await PostsApiService.instance.addComment(_post, text);
      _controller.clear();
      if (!mounted) return;
      setState(() {
        _post = updated;
        _submitting = false;
      });
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() => _submitting = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not post comment: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 8, 8),
              child: Row(
                children: [
                  Text(
                    'Comments (${_post.commentsCount})',
                    style: VyralTypography.inter(
                      fontSize: 17,
                      fontWeight: FontWeight.w600,
                      color: heading,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.pop(context, _post),
                    icon: Icon(Icons.close, color: muted),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.all(24),
                child: CircularProgressIndicator(),
              )
            else if (_comments.isEmpty)
              Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  'No comments yet. Be the first!',
                  style: VyralTypography.inter(fontSize: 14, color: muted),
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: _comments.length,
                  itemBuilder: (context, index) {
                    final c = _comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isDark
                                ? VyralColors.blueGray
                                : VyralColors.secondaryBackground,
                            child: Text(
                              c.username.replaceAll('@', '').isNotEmpty
                                  ? c.username.replaceAll('@', '')[0].toUpperCase()
                                  : '?',
                              style: VyralTypography.inter(
                                fontSize: 12,
                                color: heading,
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  c.username,
                                  style: VyralTypography.inter(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: heading,
                                  ),
                                ),
                                Text(
                                  c.text,
                                  style: VyralTypography.inter(
                                    fontSize: 14,
                                    color: heading,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Add a comment...',
                        hintStyle: VyralTypography.inter(color: muted),
                        filled: true,
                        fillColor: isDark
                            ? VyralColors.surface
                            : VyralColors.inputBackground,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 10,
                        ),
                      ),
                      style: VyralTypography.inter(color: heading),
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _submit(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton.filled(
                    onPressed: _submitting ? null : _submit,
                    style: IconButton.styleFrom(backgroundColor: accent),
                    icon: _submitting
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Icon(Icons.send_rounded, size: 20),
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

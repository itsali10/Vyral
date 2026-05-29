import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../services/auth_service.dart';
import '../services/posts_api_service.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_scaffold.dart';

class PostDetailScreen extends StatefulWidget {
  const PostDetailScreen({
    super.key,
    required this.postId,
    this.initialPost,
    this.manageAsOwner = false,
  });

  final String postId;
  final FeedPost? initialPost;

  /// Passed through when opening from your profile so owner menu stays available.
  final bool manageAsOwner;

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  FeedPost? _post;
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _post = widget.initialPost;
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await PostsApiService.instance.getPost(widget.postId);
      if (!mounted) return;
      setState(() {
        _post = post;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _error = e.toString();
        _loading = false;
      });
    }
  }

  void _onPostUpdated(FeedPost updated) {
    setState(() => _post = updated);
  }

  void _onPostDeleted(String id) {
    Navigator.of(context).pop(id);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;

    return VyralScaffold(
      backgroundColor: bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Post',
          style: VyralTypography.display(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: heading,
          ),
        ),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading && _post == null) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null && _post == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(onPressed: _load, child: const Text('Retry')),
            ],
          ),
        ),
      );
    }
    final post = _post;
    if (post == null) {
      return const Center(child: Text('Post not found'));
    }
    final myId = AuthService.instance.user?.id;
    final manageAsOwner = widget.manageAsOwner ||
        (myId != null &&
            post.authorIdSafe.isNotEmpty &&
            myId == post.authorIdSafe);
    return ListView(
      children: [
        PostCard(
          post: post,
          manageAsOwner: manageAsOwner,
          onLike: (p, liked) async {
            final updated =
                await PostsApiService.instance.setLike(p, liked: liked);
            _onPostUpdated(updated);
            return updated;
          },
          onSave: (p, saved, {collectionId}) async {
            final updated = await PostsApiService.instance.setSaved(
              p,
              saved: saved,
              collectionId: collectionId,
            );
            _onPostUpdated(updated);
            return updated;
          },
          onPostUpdated: _onPostUpdated,
          onPostDeleted: _onPostDeleted,
        ),
      ],
    );
  }
}

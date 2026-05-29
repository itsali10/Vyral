import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import '../models/saved_collection.dart';
import '../services/posts_api_service.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_refresh_scroll.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';

class CollectionDetailScreen extends StatefulWidget {
  const CollectionDetailScreen({super.key, required this.collection});

  final SavedCollection collection;

  @override
  State<CollectionDetailScreen> createState() => _CollectionDetailScreenState();
}

class _CollectionDetailScreenState extends State<CollectionDetailScreen> {
  List<FeedPost> _posts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final posts = await UsersApiService.instance.getCollectionPosts(
        widget.collection.id,
      );
      if (!mounted) return;
      setState(() {
        _posts = posts;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load saved posts: $e')),
      );
    }
  }

  Future<FeedPost> _onLike(FeedPost post, bool liked) async {
    final updated = await PostsApiService.instance.setLike(post, liked: liked);
    setState(() {
      _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
    });
    return updated;
  }

  Future<FeedPost> _onSave(
    FeedPost post,
    bool saved, {
    String? collectionId,
  }) async {
    final updated = await PostsApiService.instance.setSaved(
      post,
      saved: saved,
      collectionId: collectionId,
    );
    if (!saved) {
      setState(() {
        _posts = _posts.where((p) => p.id != updated.id).toList();
      });
    } else {
      setState(() {
        _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
      });
    }
    return updated;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;

    return VyralScaffold(
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
          widget.collection.name,
          style: VyralTypography.display(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: heading,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            color: heading,
            onPressed: _load,
          ),
          VyralOpenNavMenuButton(color: heading, size: 22),
          const VyralUniversalActions(compact: true),
        ],
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : VyralRefreshScrollView(
              onRefresh: _load,
              child: _posts.isEmpty
                  ? Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Text(
                          'No saved posts in this collection yet.\n'
                          'Tap Save on a post in your feed.',
                          textAlign: TextAlign.center,
                          style: VyralTypography.inter(
                            fontSize: 14,
                            color: muted,
                          ),
                        ),
                      ),
                    )
                  : ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      padding: const EdgeInsets.only(bottom: 24, top: 8),
                      itemCount: _posts.length,
                      itemBuilder: (context, index) => PostCard(
                        post: _posts[index],
                        onLike: _onLike,
                        onSave: _onSave,
                        onPostDeleted: (_) => _load(),
                      ),
                    ),
            ),
    );
  }
}

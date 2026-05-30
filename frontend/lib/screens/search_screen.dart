import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../models/feed_post.dart';
import '../models/user_search_result.dart';
import '../services/posts_api_service.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_theme.dart';
import '../theme/vyral_typography.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_scaffold.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  final _searchController = TextEditingController();
  final _focusNode = FocusNode();
  Timer? _debounce;

  String _query = '';
  bool _loadingPosts = false;
  bool _loadingPeople = false;
  List<FeedPost> _posts = [];
  List<UserSearchResult> _people = [];
  String? _postsError;
  String? _peopleError;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    _searchController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (!_tabController.indexIsChanging && _query.isNotEmpty) {
      _runSearch(_query);
    }
  }

  void _onQueryChanged(String value) {
    setState(() => _query = value);
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      setState(() {
        _posts = [];
        _people = [];
        _postsError = null;
        _peopleError = null;
      });
      return;
    }
    _debounce = Timer(const Duration(milliseconds: 420), () => _runSearch(value));
  }

  Future<void> _runSearch(String q) async {
    final trimmed = q.trim();
    if (trimmed.isEmpty) return;
    if (_tabController.index == 0) {
      await _searchPosts(trimmed);
    } else {
      await _searchPeople(trimmed);
    }
  }

  Future<void> _searchPosts(String q) async {
    setState(() {
      _loadingPosts = true;
      _postsError = null;
    });
    try {
      final results = await PostsApiService.instance.explore(q: q);
      if (!mounted) return;
      setState(() => _posts = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _postsError = 'Could not load posts. Try again.');
    } finally {
      if (mounted) setState(() => _loadingPosts = false);
    }
  }

  Future<void> _searchPeople(String q) async {
    if (q.trim().length < 2) {
      setState(() {
        _people = [];
        _peopleError = null;
      });
      return;
    }
    setState(() {
      _loadingPeople = true;
      _peopleError = null;
    });
    try {
      final results = await UsersApiService.instance.searchUsers(q.trim());
      if (!mounted) return;
      setState(() => _people = results);
    } catch (e) {
      if (!mounted) return;
      setState(() => _peopleError = 'Could not load people. Try again.');
    } finally {
      if (mounted) setState(() => _loadingPeople = false);
    }
  }

  void _onLikePost(FeedPost updated) {
    setState(() {
      _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final searchBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final border = isDark ? VyralColors.blueGray : VyralColors.border;
    final tabBg = isDark ? VyralColors.surface : VyralColors.secondaryBackground;
    final indicator = isDark ? VyralColors.softPink : VyralColors.primaryRose;

    return VyralScaffold(
      backgroundColor: bg,
      body: Column(
        children: [
          // ── Search bar ──────────────────────────────────────────────────
          FadeSlideIn(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: searchBg,
                        borderRadius: BorderRadius.circular(23),
                        border: Border.all(color: border, width: 0.7),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 14),
                          Icon(Icons.search, color: muted, size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              focusNode: _focusNode,
                              onChanged: _onQueryChanged,
                              style: VyralTypography.inter(
                                fontSize: 15,
                                color: heading,
                              ),
                              decoration: InputDecoration(
                                hintText: 'Search posts, people…',
                                hintStyle: VyralTypography.inter(
                                  fontSize: 15,
                                  color: muted,
                                ),
                                filled: false,
                                border: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                isCollapsed: true,
                                contentPadding: EdgeInsets.zero,
                              ),
                            ),
                          ),
                          if (_query.isNotEmpty)
                            IconButton(
                              iconSize: 18,
                              onPressed: () {
                                _searchController.clear();
                                _onQueryChanged('');
                              },
                              icon: Icon(Icons.cancel, color: muted),
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: Text(
                      'Cancel',
                      style: VyralTypography.inter(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: indicator,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          // ── Tabs ────────────────────────────────────────────────────────
          FadeSlideIn(
            delay: const Duration(milliseconds: 80),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: tabBg,
                borderRadius: BorderRadius.circular(24),
              ),
              child: TabBar(
                controller: _tabController,
                indicator: BoxDecoration(
                  color: indicator,
                  borderRadius: BorderRadius.circular(24),
                ),
                indicatorSize: TabBarIndicatorSize.tab,
                dividerColor: Colors.transparent,
                labelColor: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                unselectedLabelColor: muted,
                labelStyle: VyralTypography.inter(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
                tabs: const [Tab(text: 'Posts'), Tab(text: 'People')],
              ),
            ),
          ),
          const SizedBox(height: 8),
          // ── Results ─────────────────────────────────────────────────────
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _PostsTab(
                  query: _query,
                  loading: _loadingPosts,
                  posts: _posts,
                  error: _postsError,
                  onRetry: () => _searchPosts(_query),
                  onLike: (post, liked) async {
                    final updated = await PostsApiService.instance
                        .setLike(post, liked: liked);
                    _onLikePost(updated);
                    return updated;
                  },
                  onSave: (post, saved, {collectionId}) async {
                    final updated = await PostsApiService.instance.setSaved(
                      post,
                      saved: saved,
                      collectionId: collectionId,
                    );
                    _onLikePost(updated);
                    return updated;
                  },
                  onPostUpdated: _onLikePost,
                  onPostDeleted: (id) {
                    setState(() => _posts.removeWhere((p) => p.id == id));
                  },
                ),
                _PeopleTab(
                  query: _query,
                  loading: _loadingPeople,
                  people: _people,
                  error: _peopleError,
                  onRetry: () => _searchPeople(_query),
                  isDark: isDark,
                  heading: heading,
                  muted: muted,
                  indicator: indicator,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Posts tab ────────────────────────────────────────────────────────────────

class _PostsTab extends StatelessWidget {
  const _PostsTab({
    required this.query,
    required this.loading,
    required this.posts,
    required this.error,
    required this.onRetry,
    required this.onLike,
    required this.onSave,
    required this.onPostUpdated,
    required this.onPostDeleted,
  });

  final String query;
  final bool loading;
  final List<FeedPost> posts;
  final String? error;
  final VoidCallback onRetry;
  final Future<FeedPost> Function(FeedPost, bool) onLike;
  final Future<FeedPost> Function(FeedPost, bool, {String? collectionId}) onSave;
  final ValueChanged<FeedPost> onPostUpdated;
  final ValueChanged<String> onPostDeleted;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return _Hint(
        icon: Icons.article_outlined,
        text: 'Type to search posts',
      );
    }
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _ErrorState(message: error!, onRetry: onRetry);
    }
    if (posts.isEmpty) {
      return _EmptyState(query: query, noun: 'posts');
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: posts.length,
      itemBuilder: (context, index) {
        final post = posts[index];
        return FadeSlideIn(
          delay: VyralAnimations.staggerDelay(index),
          child: PostCard(
            key: ValueKey(post.id),
            post: post,
            onLike: onLike,
            onSave: onSave,
            onPostUpdated: onPostUpdated,
            onPostDeleted: onPostDeleted,
          ),
        );
      },
    );
  }
}

// ── People tab ───────────────────────────────────────────────────────────────

class _PeopleTab extends StatelessWidget {
  const _PeopleTab({
    required this.query,
    required this.loading,
    required this.people,
    required this.error,
    required this.onRetry,
    required this.isDark,
    required this.heading,
    required this.muted,
    required this.indicator,
  });

  final String query;
  final bool loading;
  final List<UserSearchResult> people;
  final String? error;
  final VoidCallback onRetry;
  final bool isDark;
  final Color heading;
  final Color muted;
  final Color indicator;

  @override
  Widget build(BuildContext context) {
    if (query.trim().isEmpty) {
      return _Hint(icon: Icons.person_search_outlined, text: 'Type to search people');
    }
    if (query.trim().length < 2) {
      return _Hint(icon: Icons.person_search_outlined, text: 'Enter at least 2 characters');
    }
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (error != null) {
      return _ErrorState(message: error!, onRetry: onRetry);
    }
    if (people.isEmpty) {
      return _EmptyState(query: query, noun: 'people');
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: people.length,
      itemBuilder: (context, index) {
        final user = people[index];
        return FadeSlideIn(
          delay: VyralAnimations.staggerDelay(index),
          child: _UserTile(
            user: user,
            isDark: isDark,
            heading: heading,
            muted: muted,
            indicator: indicator,
          ),
        );
      },
    );
  }
}

class _UserTile extends StatelessWidget {
  const _UserTile({
    required this.user,
    required this.isDark,
    required this.heading,
    required this.muted,
    required this.indicator,
  });

  final UserSearchResult user;
  final bool isDark;
  final Color heading;
  final Color muted;
  final Color indicator;

  @override
  Widget build(BuildContext context) {
    final avatarBg = isDark ? VyralColors.blueGray : VyralColors.secondaryBackground;
    final initial = user.fullName.isNotEmpty
        ? user.fullName[0].toUpperCase()
        : (user.username.isNotEmpty ? user.username[0].toUpperCase() : '?');

    return AnimatedPressable(
      child: InkWell(
        onTap: () => Navigator.of(context).pushNamed(
          '/user',
          arguments: user.id,
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Row(
            children: [
              CircleAvatar(
                radius: 22,
                backgroundColor: avatarBg,
                backgroundImage: user.avatarUrl != null
                    ? CachedNetworkImageProvider(user.avatarUrl!)
                    : null,
                child: user.avatarUrl == null
                    ? Text(
                        initial,
                        style: VyralTypography.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: heading,
                        ),
                      )
                    : null,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.fullName.isNotEmpty ? user.fullName : user.username,
                      style: VyralTypography.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: heading,
                      ),
                    ),
                    Text(
                      user.displayUsername.isNotEmpty
                          ? user.displayUsername
                          : '@${user.username}',
                      style: VyralTypography.inter(
                        fontSize: 12,
                        color: muted,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.chevron_right, color: muted, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Shared states ─────────────────────────────────────────────────────────────

class _Hint extends StatelessWidget {
  const _Hint({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 40, color: muted.withValues(alpha: 0.4)),
          const SizedBox(height: 12),
          Text(
            text,
            style: VyralTypography.inter(fontSize: 14, color: muted),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.query, required this.noun});
  final String query;
  final String noun;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 44,
              color: muted.withValues(alpha: 0.4),
            ),
            const SizedBox(height: 14),
            Text(
              'No $noun found',
              style: VyralTypography.inter(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: heading,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'No results for "$query"',
              textAlign: TextAlign.center,
              style: VyralTypography.inter(fontSize: 13, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});
  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

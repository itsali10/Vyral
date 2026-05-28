import 'package:flutter/material.dart';
import '../main.dart';
import '../models/feed_post.dart';
import '../services/posts_api_service.dart';
import '../services/settings_preferences.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_refresh_scroll.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  int _bottomIndex = 0;
  late TabController _tabController;

  List<FeedPost> _forYou = [];
  List<FeedPost> _following = [];
  List<FeedPost> _trending = [];
  bool _loading = true;
  bool _followingLoading = false;
  String? _error;

  static const _followingTabIndex = 1;

  int get _defaultTabIndex {
    switch (SettingsPreferences.instance.defaultFeedTab) {
      case 'following':
        return 1;
      case 'trending':
        return 2;
      default:
        return 0;
    }
  }

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: _defaultTabIndex,
    );
    _tabController.addListener(_onTabChanged);
    SettingsPreferences.instance.addListener(_onSettingsTabChanged);
    _loadFeeds();
  }

  void _onSettingsTabChanged() {
    final idx = _defaultTabIndex;
    if (_tabController.index != idx && mounted) {
      _tabController.animateTo(idx);
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (route is PageRoute<void>) {
      vyralRouteObserver.subscribe(this, route);
    }
  }

  @override
  void dispose() {
    vyralRouteObserver.unsubscribe(this);
    SettingsPreferences.instance.removeListener(_onSettingsTabChanged);
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _loadFeeds();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    if (_tabController.index == _followingTabIndex) {
      _loadFollowingFeed();
    }
  }

  Future<void> _loadFeeds() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final results = await Future.wait([
        PostsApiService.instance.getFeed(tab: 'for_you'),
        PostsApiService.instance.getFeed(tab: 'following'),
        PostsApiService.instance.getFeed(tab: 'trending'),
      ]);
      if (!mounted) return;
      setState(() {
        _forYou = results[0];
        _following = results[1];
        _trending = results[2];
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

  Future<void> _loadFollowingFeed() async {
    if (_followingLoading) return;
    setState(() => _followingLoading = true);
    try {
      final posts =
          await PostsApiService.instance.getFeedTab('following');
      if (!mounted) return;
      setState(() {
        _following = posts;
        _followingLoading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _followingLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not refresh Following: $e')),
      );
    }
  }

  void _onBottomNav(int index) {
    if (index == 1) {
      Navigator.of(context).pushNamed('/explore');
      return;
    }
    if (index == 2) {
      Navigator.of(context).pushNamed('/create');
      return;
    }
    if (index == 3) {
      Navigator.of(context).pushNamed('/saved');
      return;
    }
    if (index == 4) {
      Navigator.of(context).pushNamed('/profile');
      return;
    }
    setState(() => _bottomIndex = index);
  }

  void _replacePost(FeedPost updated) {
    setState(() {
      _forYou = _mapReplace(_forYou, updated);
      _following = _mapReplace(_following, updated);
      _trending = _mapReplace(_trending, updated);
    });
  }

  List<FeedPost> _mapReplace(List<FeedPost> list, FeedPost updated) {
    return list.map((p) => p.id == updated.id ? updated : p).toList();
  }

  Future<FeedPost> _onLike(FeedPost post, bool liked) async {
    final updated = await PostsApiService.instance.setLike(post, liked: liked);
    _replacePost(updated);
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
    _replacePost(updated);
    return updated;
  }

  void _removePost(String postId) {
    setState(() {
      _forYou = _forYou.where((p) => p.id != postId).toList();
      _following = _following.where((p) => p.id != postId).toList();
      _trending = _trending.where((p) => p.id != postId).toList();
    });
  }

  Widget _tabList(
    List<FeedPost> posts, {
    required String emptyMessage,
    bool tabLoading = false,
  }) {
    if (_loading || tabLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: _loadFeeds,
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }
    Future<void> onRefresh() async {
      if (_tabController.index == _followingTabIndex) {
        await _loadFollowingFeed();
      } else {
        await _loadFeeds();
      }
    }

    if (posts.isEmpty) {
      return VyralRefreshScrollView(
        onRefresh: onRefresh,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(emptyMessage, textAlign: TextAlign.center),
          ),
        ),
      );
    }
    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView.builder(
        physics: vyralRefreshScrollPhysics,
        padding: const EdgeInsets.only(bottom: 8, top: 4),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return PostCard(
            key: ValueKey(post.id),
            post: post,
            onLike: _onLike,
            onSave: _onSave,
            onPostUpdated: _replacePost,
            onPostDeleted: _removePost,
          );
        },
      ),
    );
  }

  Widget _buildFeed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerText = isDark ? VyralColors.white : VyralColors.primaryText;
    final tabBg = isDark ? VyralColors.surface : VyralColors.secondaryBackground;
    final indicator = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final unselected = isDark ? VyralColors.mutedText : VyralColors.secondaryText;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          child: Row(
            children: [
              VyralOpenNavMenuButton(color: headerText),
              const SizedBox(width: 8),
              Text(
                'vyral',
                style: VyralTypography.display(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: headerText,
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'Refresh feed',
                onPressed: _loadFeeds,
                icon: Icon(Icons.refresh, size: 22, color: headerText),
              ),
              const VyralUniversalActions(),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Container(
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
            labelColor:
                isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
            unselectedLabelColor: unselected,
            labelStyle: VyralTypography.inter(
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            tabs: const [
              Tab(text: 'For You'),
              Tab(text: 'Following'),
              Tab(text: 'Trending'),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              _tabList(
                _forYou,
                emptyMessage: 'No posts yet. Create one!',
              ),
              _tabList(
                _following,
                emptyMessage:
                    'Posts from people you follow appear here.\n'
                    'Follow someone, then make sure they have posted.',
                tabLoading: _followingLoading,
              ),
              _tabList(
                _trending,
                emptyMessage: 'No trending posts yet.',
              ),
            ],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return VyralScaffold(
      backgroundColor:
          isDark ? VyralColors.background : VyralColors.mainBackground,
      drawer: const VyralNavigationDrawer(),
      body: Column(
        children: [
          Expanded(child: _buildFeed()),
          VyralBottomNav(
            currentIndex: _bottomIndex,
            onDestinationSelected: _onBottomNav,
          ),
        ],
      ),
    );
  }
}

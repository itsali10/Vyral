import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import 'edit_profile_screen.dart';
import '../services/api_client.dart';
import '../services/auth_service.dart';
import '../services/settings_api_service.dart';
import '../services/users_api_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';
import '../services/posts_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with TickerProviderStateMixin {
  UserProfile? _profile;
  List<FeedPost> _posts = [];
  List<FeedPost> _likedPosts = [];
  List<FeedPost> _savedPosts = [];

  bool _loading = true;
  bool _likesLoading = false;
  bool _savedLoading = false;
  bool _likesLoaded = false;
  bool _savedLoaded = false;

  bool _followBusy = false;
  bool _blockBusy = false;
  bool _isBlocked = false;

  late TabController _tabController;
  int _tabCount = 1;

  bool get _isOwnProfile {
    final id = widget.userId;
    if (id == null) return true;
    return id == AuthService.instance.user?.id;
  }

  String? get _targetUserId => _isOwnProfile ? null : widget.userId;

  int _computeTabCount() {
    if (_isOwnProfile) return 3;
    final profile = _profile;
    if (profile == null) return 1;
    return profile.showLikesPublicly ? 2 : 1;
  }

  @override
  void initState() {
    super.initState();
    _tabCount = _isOwnProfile ? 3 : 1;
    _tabController = TabController(length: _tabCount, vsync: this)
      ..addListener(_onTabChanged);
    _load();
  }

  @override
  void didUpdateWidget(ProfileScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.userId != widget.userId) {
      _profile = null;
      _posts = [];
      _likedPosts = [];
      _savedPosts = [];
      _likesLoaded = false;
      _savedLoaded = false;
      _resetTabs();
      _load();
    }
  }

  @override
  void dispose() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    super.dispose();
  }

  void _resetTabs() {
    _tabController
      ..removeListener(_onTabChanged)
      ..dispose();
    _tabCount = _isOwnProfile ? 3 : 1;
    _tabController = TabController(length: _tabCount, vsync: this)
      ..addListener(_onTabChanged);
  }

  void _updateTabCount() {
    final newCount = _computeTabCount();
    if (newCount == _tabCount) return;
    setState(() {
      _tabController
        ..removeListener(_onTabChanged)
        ..dispose();
      _tabCount = newCount;
      _tabController = TabController(length: _tabCount, vsync: this)
        ..addListener(_onTabChanged);
    });
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    final idx = _tabController.index;
    if (_tabCount >= 2 && idx == 1 && !_likesLoaded) _loadLikes();
    if (_isOwnProfile && idx == 2 && !_savedLoaded) _loadSaved();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      if (!_isOwnProfile) {
        _profile = null;
        _posts = [];
      }
    });
    try {
      final UserProfile profile;
      final List<FeedPost> posts;

      if (_isOwnProfile) {
        profile = await UsersApiService.instance.getMe();
        posts = await UsersApiService.instance.getMyPosts();
        await AuthService.instance.refreshProfile();
      } else {
        final userId = _targetUserId!;
        profile = await UsersApiService.instance.getUser(userId);
        posts = await UsersApiService.instance.getUserPosts(userId);
      }

      var isBlocked = false;
      if (!_isOwnProfile && _targetUserId != null) {
        final blocked = await SettingsApiService.instance.getBlockedUsers();
        isBlocked = blocked.any((u) => u.id == _targetUserId);
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = posts;
        _isBlocked = isBlocked;
        _loading = false;
      });
      _updateTabCount();
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $e')),
      );
    }
  }

  Future<void> _loadLikes() async {
    if (_likesLoading) return;
    setState(() => _likesLoading = true);
    try {
      final posts = _isOwnProfile
          ? await UsersApiService.instance.getMyLikedPosts()
          : await UsersApiService.instance.getUserLikedPosts(_targetUserId!);
      if (!mounted) return;
      setState(() {
        _likedPosts = posts;
        _likesLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _likesLoaded = true);
    } finally {
      if (mounted) setState(() => _likesLoading = false);
    }
  }

  Future<void> _loadSaved() async {
    if (_savedLoading || !_isOwnProfile) return;
    setState(() => _savedLoading = true);
    try {
      final posts = await UsersApiService.instance.getMySavedPosts();
      if (!mounted) return;
      setState(() {
        _savedPosts = posts;
        _savedLoaded = true;
      });
    } catch (_) {
      if (mounted) setState(() => _savedLoaded = true);
    } finally {
      if (mounted) setState(() => _savedLoading = false);
    }
  }

  Future<void> _toggleFollow() async {
    final profile = _profile;
    if (profile == null || _isOwnProfile || _followBusy) return;
    setState(() => _followBusy = true);
    final wasFollowing = profile.isFollowing;
    try {
      if (wasFollowing) {
        await UsersApiService.instance.unfollow(profile.id);
      } else {
        await UsersApiService.instance.follow(profile.id);
      }
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            wasFollowing
                ? 'Unfollowed ${profile.displayUsername}'
                : 'Now following ${profile.displayUsername}',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not update follow: $e')),
      );
    } finally {
      if (mounted) setState(() => _followBusy = false);
    }
  }

  Future<void> _confirmBlock() async {
    final profile = _profile;
    if (profile == null || _isOwnProfile || _blockBusy) return;
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Block account?'),
        content: Text(
          "${profile.displayUsername} won't be able to interact with you, "
          'and their posts will be hidden from your feed.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: TextButton.styleFrom(foregroundColor: VyralColors.error),
            child: const Text('Block'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    setState(() => _blockBusy = true);
    try {
      await SettingsApiService.instance.blockUser(profile.id);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Blocked ${profile.displayUsername}')),
      );
      Navigator.of(context).pop();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyApiMessage(e))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not block: $e')));
    } finally {
      if (mounted) setState(() => _blockBusy = false);
    }
  }

  Future<void> _unblockUser() async {
    final profile = _profile;
    if (profile == null || _isOwnProfile || _blockBusy) return;
    setState(() => _blockBusy = true);
    try {
      await SettingsApiService.instance.unblockUser(profile.id);
      if (!mounted) return;
      setState(() => _isBlocked = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Unblocked ${profile.displayUsername}')),
      );
      await _load();
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(friendlyApiMessage(e))));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not unblock: $e')));
    } finally {
      if (mounted) setState(() => _blockBusy = false);
    }
  }

  void _onBottomNav(int index) {
    switch (index) {
      case 0: Navigator.of(context).pushReplacementNamed('/home'); break;
      case 1: Navigator.of(context).pushReplacementNamed('/explore'); break;
      case 2: Navigator.of(context).pushNamed('/create'); break;
      case 3: Navigator.of(context).pushNamed('/saved'); break;
      case 4: break;
    }
  }

  void _replacePost(FeedPost updated) {
    setState(() {
      _posts = _posts.map((p) => p.id == updated.id ? updated : p).toList();
      _likedPosts = _likedPosts.map((p) => p.id == updated.id ? updated : p).toList();
      _savedPosts = _savedPosts.map((p) => p.id == updated.id ? updated : p).toList();
    });
  }

  Future<FeedPost> _onLike(FeedPost post, bool liked) async {
    final updated = await PostsApiService.instance.setLike(post, liked: liked);
    _replacePost(updated);
    return updated;
  }

  Future<FeedPost> _onSave(FeedPost post, bool saved, {String? collectionId}) async {
    final updated = await PostsApiService.instance.setSaved(
      post, saved: saved, collectionId: collectionId,
    );
    _replacePost(updated);
    return updated;
  }

  // ── Build helpers ────────────────────────────────────────────────────────

  Widget _buildPostList(List<FeedPost> posts, {bool isLoading = false, String emptyLabel = 'No posts yet', IconData emptyIcon = Icons.article_outlined}) {
    if (isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (posts.isEmpty) {
      return _EmptyTabState(icon: emptyIcon, label: emptyLabel);
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: 4, bottom: 16),
      itemCount: posts.length,
      itemBuilder: (ctx, i) {
        final post = posts[i];
        return FadeSlideIn(
          delay: VyralAnimations.staggerDelay(i),
          child: PostCard(
            key: ValueKey(post.id),
            post: post,
            manageAsOwner: _isOwnProfile,
            onLike: _onLike,
            onSave: _onSave,
            onPostUpdated: _replacePost,
            onPostDeleted: (_) => _load(),
          ),
        );
      },
    );
  }

  Widget _buildLikesTab() {
    if (!_likesLoaded && !_likesLoading) return const Center(child: CircularProgressIndicator());
    return _buildPostList(
      _likedPosts,
      isLoading: _likesLoading,
      emptyLabel: 'No liked posts yet',
      emptyIcon: Icons.favorite_border_rounded,
    );
  }

  Widget _buildSavedTab() {
    if (!_savedLoaded && !_savedLoading) return const Center(child: CircularProgressIndicator());
    return _buildPostList(
      _savedPosts,
      isLoading: _savedLoading,
      emptyLabel: 'Nothing saved yet',
      emptyIcon: Icons.bookmark_border_rounded,
    );
  }

  List<Widget> get _tabLabels {
    final tabs = <Widget>[
      _PillTab(label: 'Posts', icon: Icons.article_outlined),
    ];
    if (_tabCount >= 2) tabs.add(_PillTab(label: 'Likes', icon: Icons.favorite_border_rounded));
    if (_isOwnProfile && _tabCount == 3) tabs.add(_PillTab(label: 'Saved', icon: Icons.bookmark_border_rounded));
    return tabs;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final tabContainerBg = isDark ? VyralColors.surface : VyralColors.secondaryBackground;

    final UserProfile? profileOrNull = _isOwnProfile
        ? (_profile ?? AuthService.instance.user)
        : _profile;
    final showLoading = _loading || profileOrNull == null;

    if (showLoading) {
      return VyralScaffold(
        backgroundColor: pageBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final profile = profileOrNull;
    final displayName = profile.fullName.isNotEmpty ? profile.fullName : profile.username;
    final handle = profile.displayUsername;
    final bio = profile.bio;
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'V';

    // Pill-style tab bar matching home feed aesthetic
    final tabBar = _tabCount > 1
        ? Container(
            margin: const EdgeInsets.fromLTRB(16, 10, 16, 10),
            decoration: BoxDecoration(
              color: tabContainerBg,
              borderRadius: BorderRadius.circular(28),
            ),
            child: TabBar(
              controller: _tabController,
              tabs: _tabLabels,
              indicator: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(28),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              dividerColor: Colors.transparent,
              labelColor: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
              unselectedLabelColor: muted,
              labelStyle: VyralTypography.inter(fontSize: 13, fontWeight: FontWeight.w600),
              unselectedLabelStyle: VyralTypography.inter(fontSize: 13),
              padding: EdgeInsets.zero,
              labelPadding: EdgeInsets.zero,
            ),
          )
        : null;

    final tabBarHeight = tabBar != null ? 56.0 : 0.0;

    return VyralScaffold(
      backgroundColor: pageBg,
      drawer: _isOwnProfile ? const VyralNavigationDrawer() : null,
      body: Column(
        children: [
          Expanded(
            child: NestedScrollView(
              headerSliverBuilder: (context, _) => [
                SliverToBoxAdapter(
                  child: FadeSlideIn(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Cover ────────────────────────────────────────
                        _CoverSection(
                          isDark: isDark,
                          accent: accent,
                          heading: heading,
                          initial: initial,
                          avatarUrl: profile.avatarUrl,
                          isOwnProfile: _isOwnProfile,
                          isBlocked: _isBlocked,
                          blockBusy: _blockBusy,
                          onBack: () => Navigator.of(context).pop(),
                          canPop: Navigator.of(context).canPop(),
                          onSettings: () => Navigator.of(context).pushNamed('/settings'),
                          onBlock: _confirmBlock,
                          onUnblock: _unblockUser,
                        ),
                        // ── Identity ─────────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(24, 52, 24, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                displayName,
                                textAlign: TextAlign.center,
                                style: VyralTypography.display(
                                  fontSize: 24,
                                  fontWeight: FontWeight.w700,
                                  color: heading,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                handle,
                                style: VyralTypography.inter(
                                  fontSize: 13,
                                  color: muted,
                                  letterSpacing: 0.1,
                                ),
                              ),
                              if (bio != null && bio.isNotEmpty) ...[
                                const SizedBox(height: 10),
                                Text(
                                  bio,
                                  textAlign: TextAlign.center,
                                  style: VyralTypography.inter(
                                    fontSize: 13,
                                    color: isDark ? VyralColors.caption : VyralColors.primaryText,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                              const SizedBox(height: 20),
                              // ── Stats pill ───────────────────────────
                              _StatsPill(
                                profile: profile,
                                isDark: isDark,
                                accent: accent,
                                heading: heading,
                                muted: muted,
                              ),
                              const SizedBox(height: 16),
                              // ── Action button ────────────────────────
                              if (_isOwnProfile)
                                _ActionButton(
                                  label: 'Edit profile',
                                  icon: Icons.edit_outlined,
                                  filled: false,
                                  accent: accent,
                                  isDark: isDark,
                                  onTap: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute<void>(
                                        builder: (_) => const EditProfileScreen(),
                                      ),
                                    );
                                    if (mounted) _load();
                                  },
                                )
                              else
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    _ActionButton(
                                      label: profile.isFollowing ? 'Following' : 'Follow',
                                      icon: profile.isFollowing ? Icons.person_remove_outlined : Icons.person_add_alt_1_outlined,
                                      filled: !profile.isFollowing,
                                      accent: accent,
                                      isDark: isDark,
                                      busy: _followBusy,
                                      onTap: _toggleFollow,
                                    ),
                                  ],
                                ),
                              const SizedBox(height: 6),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (tabBar != null)
                  SliverPersistentHeader(
                    pinned: true,
                    delegate: _StickyTabBarDelegate(
                      child: tabBar,
                      height: tabBarHeight,
                      backgroundColor: pageBg,
                    ),
                  ),
              ],
              body: _tabCount == 1
                  ? _buildPostList(_posts)
                  : TabBarView(
                      controller: _tabController,
                      children: [
                        _buildPostList(_posts),
                        _buildLikesTab(),
                        if (_isOwnProfile) _buildSavedTab(),
                      ],
                    ),
            ),
          ),
          if (_isOwnProfile)
            VyralBottomNav(
              currentIndex: 4,
              onDestinationSelected: _onBottomNav,
            ),
        ],
      ),
    );
  }
}

// ── Cover section ─────────────────────────────────────────────────────────────

class _CoverSection extends StatelessWidget {
  const _CoverSection({
    required this.isDark,
    required this.accent,
    required this.heading,
    required this.initial,
    required this.avatarUrl,
    required this.isOwnProfile,
    required this.isBlocked,
    required this.blockBusy,
    required this.canPop,
    required this.onBack,
    required this.onSettings,
    required this.onBlock,
    required this.onUnblock,
  });

  final bool isDark;
  final Color accent;
  final Color heading;
  final String initial;
  final String? avatarUrl;
  final bool isOwnProfile;
  final bool isBlocked;
  final bool blockBusy;
  final bool canPop;
  final VoidCallback onBack;
  final VoidCallback onSettings;
  final VoidCallback onBlock;
  final VoidCallback onUnblock;

  @override
  Widget build(BuildContext context) {
    final coverTop = isDark ? const Color(0xFF1F2126) : const Color(0xFFF0E8E6);
    final coverBot = isDark ? const Color(0xFF2A1E2A) : const Color(0xFFE8D8D8);

    return SizedBox(
      height: 210,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Cover gradient
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [coverTop, coverBot],
                ),
              ),
            ),
          ),
          // Subtle watermark
          Positioned(
            bottom: 48,
            right: -16,
            child: Text(
              'v.',
              style: VyralTypography.display(
                fontSize: 120,
                fontWeight: FontWeight.bold,
                color: (isDark ? VyralColors.white : VyralColors.primaryText)
                    .withValues(alpha: 0.05),
              ),
            ),
          ),
          // Top navigation row
          Positioned(
            top: 8,
            left: 4,
            right: 8,
            child: Row(
              children: [
                if (!isOwnProfile || canPop)
                  IconButton(
                    icon: Icon(
                      isOwnProfile ? Icons.menu_rounded : Icons.arrow_back_ios_new_rounded,
                      size: 22,
                    ),
                    color: heading,
                    onPressed: isOwnProfile
                        ? () => Scaffold.of(context).openDrawer()
                        : onBack,
                  )
                else
                  IconButton(
                    icon: const Icon(Icons.menu_rounded, size: 22),
                    color: heading,
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                const Spacer(),
                if (isOwnProfile) ...[
                  const VyralUniversalActions(),
                  AnimatedPressable(
                    child: IconButton(
                      icon: const Icon(Icons.settings_outlined, size: 22),
                      color: heading,
                      tooltip: 'Settings',
                      onPressed: onSettings,
                    ),
                  ),
                ] else
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_horiz, color: heading),
                    enabled: !blockBusy,
                    onSelected: (v) {
                      if (v == 'block') onBlock();
                      if (v == 'unblock') onUnblock();
                    },
                    itemBuilder: (_) => [
                      if (isBlocked)
                        const PopupMenuItem(value: 'unblock', child: Text('Unblock account'))
                      else
                        const PopupMenuItem(value: 'block', child: Text('Block account')),
                    ],
                  ),
              ],
            ),
          ),
          // Avatar with accent ring
          Positioned(
            bottom: -46,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding: const EdgeInsets.all(3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: accent,
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.35),
                      blurRadius: 16,
                      spreadRadius: 0,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: CircleAvatar(
                  radius: 46,
                  backgroundColor: isDark ? VyralColors.blueGray : VyralColors.secondaryBackground,
                  backgroundImage: avatarUrl != null
                      ? CachedNetworkImageProvider(avatarUrl!)
                      : null,
                  child: avatarUrl == null
                      ? Text(
                          initial,
                          style: VyralTypography.display(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: isDark ? VyralColors.white : VyralColors.primaryText,
                          ),
                        )
                      : null,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Stats pill ────────────────────────────────────────────────────────────────

class _StatsPill extends StatelessWidget {
  const _StatsPill({
    required this.profile,
    required this.isDark,
    required this.accent,
    required this.heading,
    required this.muted,
  });

  final UserProfile profile;
  final bool isDark;
  final Color accent;
  final Color heading;
  final Color muted;

  @override
  Widget build(BuildContext context) {
    final bg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final dividerColor = isDark ? VyralColors.blueGray : VyralColors.border;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: dividerColor, width: 0.5),
      ),
      child: IntrinsicHeight(
        child: Row(
          children: [
            _stat(profile.postsLabel, 'Posts'),
            VerticalDivider(color: dividerColor, width: 1, thickness: 0.5),
            _stat(profile.followersLabel, 'Followers'),
            VerticalDivider(color: dividerColor, width: 1, thickness: 0.5),
            _stat(profile.followingLabel, 'Following'),
          ],
        ),
      ),
    );
  }

  Widget _stat(String value, String label) {
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 14),
        child: Column(
          children: [
            Text(
              value,
              style: VyralTypography.inter(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                color: heading,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: VyralTypography.inter(fontSize: 11, color: muted),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Action button ─────────────────────────────────────────────────────────────

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.accent,
    required this.isDark,
    required this.onTap,
    this.busy = false,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final Color accent;
  final bool isDark;
  final VoidCallback onTap;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final fg = filled
        ? (isDark ? VyralColors.deepBlack : VyralColors.cardBackground)
        : accent;
    final bg = filled ? accent : Colors.transparent;
    final borderColor = accent;

    return AnimatedPressable(
      enabled: !busy,
      child: GestureDetector(
        onTap: busy ? null : onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
          constraints: const BoxConstraints(minWidth: 140),
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: borderColor, width: 1.2),
          ),
          child: busy
              ? Center(
                  child: SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2, color: fg),
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 15, color: fg),
                    const SizedBox(width: 7),
                    Text(
                      label,
                      style: VyralTypography.inter(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: fg,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}

// ── Pill tab label ────────────────────────────────────────────────────────────

class _PillTab extends StatelessWidget {
  const _PillTab({required this.label, required this.icon});

  final String label;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Tab(
      height: 40,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14),
          const SizedBox(width: 5),
          Text(label),
        ],
      ),
    );
  }
}

// ── Empty state ───────────────────────────────────────────────────────────────

class _EmptyTabState extends StatelessWidget {
  const _EmptyTabState({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;

    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: (isDark ? VyralColors.surface : VyralColors.secondaryBackground),
            ),
            child: Icon(icon, size: 28, color: muted),
          ),
          const SizedBox(height: 14),
          Text(
            label,
            style: VyralTypography.inter(
              fontSize: 15,
              fontWeight: FontWeight.w500,
              color: heading,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Sticky tab bar delegate ───────────────────────────────────────────────────

class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
  const _StickyTabBarDelegate({
    required this.child,
    required this.height,
    required this.backgroundColor,
  });

  final Widget child;
  final double height;
  final Color backgroundColor;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(color: backgroundColor, child: child);
  }

  @override
  bool shouldRebuild(_StickyTabBarDelegate old) =>
      child != old.child ||
      height != old.height ||
      backgroundColor != old.backgroundColor;
}

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/feed_post.dart';
import 'edit_profile_screen.dart';
import '../services/auth_service.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';
import '../services/posts_api_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key, this.userId});

  /// When set, shows another user's profile (e.g. from feed avatar tap).
  final String? userId;

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  UserProfile? _profile;
  List<FeedPost> _posts = [];
  List<Map<String, dynamic>> _pins = [];
  bool _loading = true;
  bool _followBusy = false;

  bool get _isOwnProfile {
    final id = widget.userId;
    if (id == null) return true;
    return id == AuthService.instance.user?.id;
  }

  String? get _targetUserId =>
      _isOwnProfile ? null : widget.userId;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final UserProfile profile;
      final List<FeedPost> posts;
      final List<Map<String, dynamic>> pins;

      if (_isOwnProfile) {
        profile = await UsersApiService.instance.getMe();
        posts = await UsersApiService.instance.getMyPosts();
        pins = await UsersApiService.instance.getMyPins();
        await AuthService.instance.refreshProfile();
      } else {
        final userId = _targetUserId!;
        profile = await UsersApiService.instance.getUser(userId);
        posts = await UsersApiService.instance.getUserPosts(userId);
        pins = await UsersApiService.instance.getUserPins(userId);
      }

      if (!mounted) return;
      setState(() {
        _profile = profile;
        _posts = posts;
        _pins = pins;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load profile: $e')),
      );
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

  void _onBottomNav(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        Navigator.of(context).pushReplacementNamed('/explore');
        break;
      case 2:
        Navigator.of(context).pushNamed('/create');
        break;
      case 3:
        Navigator.of(context).pushNamed('/saved');
        break;
      case 4:
        break;
    }
  }

  Color _pinShade(int i) {
    return [
      VyralColors.blueGray,
      VyralColors.blueGrayDark,
      VyralColors.blueGrayLight,
      VyralColors.blueGray,
      VyralColors.blueGrayLight,
      VyralColors.blueGrayDark,
    ][i % 6];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final coverStart = isDark ? VyralColors.background : VyralColors.secondaryBackground;
    final coverEnd = isDark ? VyralColors.blueGray : VyralColors.inputBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final divider = isDark ? VyralColors.blueGray : VyralColors.border;
    final avatarBg = isDark ? VyralColors.blueGray : VyralColors.secondaryBackground;

    final profile = _profile ?? AuthService.instance.user;
    final username = profile?.displayUsername ?? '@yourusername';
    final bio = profile?.bio ?? 'creating in soft chaos ✦ collector of moments';
    final initial = (profile?.fullName.isNotEmpty == true)
        ? profile!.fullName[0].toUpperCase()
        : 'Y';

    return VyralScaffold(
      backgroundColor: pageBg,
      drawer: _isOwnProfile ? const VyralNavigationDrawer() : null,
      body: _loading && profile == null
            ? const Center(child: CircularProgressIndicator())
            : DefaultTabController(
                length: 2,
                child: Column(
                  children: [
                    Expanded(
                      child: NestedScrollView(
                        headerSliverBuilder: (context, innerBoxIsScrolled) {
                          return [
                            SliverToBoxAdapter(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      Container(
                                        width: double.infinity,
                                        height: 180,
                                        decoration: BoxDecoration(
                                          gradient: LinearGradient(
                                            begin: Alignment.topLeft,
                                            end: Alignment.bottomRight,
                                            colors: [coverStart, coverEnd],
                                          ),
                                        ),
                                      ),
                                      Positioned(
                                        top: 8,
                                        left: 4,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            if (_isOwnProfile)
                                              VyralOpenNavMenuButton(
                                                color: heading,
                                                size: 22,
                                              ),
                                            if (!_isOwnProfile ||
                                                Navigator.of(context).canPop())
                                              IconButton(
                                                icon: const Icon(Icons.arrow_back),
                                                color: heading,
                                                onPressed: () =>
                                                    Navigator.of(context).pop(),
                                              ),
                                          ],
                                        ),
                                      ),
                                      if (_isOwnProfile)
                                        Positioned(
                                          top: 8,
                                          right: 8,
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              const VyralUniversalActions(),
                                              IconButton(
                                                icon: const Icon(Icons.more_horiz),
                                                color: heading,
                                                tooltip: 'Settings',
                                                onPressed: () => Navigator.of(
                                                  context,
                                                ).pushNamed('/settings'),
                                              ),
                                            ],
                                          ),
                                        ),
                                      Positioned(
                                        bottom: -44,
                                        left: 0,
                                        right: 0,
                                        child: Center(
                                          child: CircleAvatar(
                                            radius: 44,
                                            backgroundColor: avatarBg,
                                            backgroundImage: profile?.avatarUrl != null
                                                ? CachedNetworkImageProvider(profile!.avatarUrl!)
                                                : null,
                                            child: profile?.avatarUrl == null
                                                ? Text(
                                                    initial,
                                                    style: VyralTypography.display(
                                                      fontSize: 30,
                                                      fontWeight: FontWeight.bold,
                                                      color: heading,
                                                    ),
                                                  )
                                                : null,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 56),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        username,
                                        textAlign: TextAlign.center,
                                        style: VyralTypography.display(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: heading,
                                        ),
                                      ),
                                      const SizedBox(height: 6),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 24),
                                        child: Text(
                                          bio,
                                          textAlign: TextAlign.center,
                                          style: VyralTypography.inter(
                                            fontSize: 13,
                                            color: muted,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 20),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                        children: [
                                          _StatColumn(
                                            value: profile?.postsLabel ?? '0',
                                            label: 'Posts',
                                          ),
                                          _StatColumn(
                                            value: profile?.followersLabel ?? '0',
                                            label: 'Followers',
                                          ),
                                          _StatColumn(
                                            value: profile?.followingLabel ?? '0',
                                            label: 'Following',
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 16),
                                      if (_isOwnProfile)
                                        Center(
                                          child: SizedBox(
                                            width: 160,
                                            height: 36,
                                            child: OutlinedButton(
                                              onPressed: () async {
                                                await Navigator.of(context).push(
                                                  MaterialPageRoute<void>(
                                                    builder: (_) =>
                                                        const EditProfileScreen(),
                                                  ),
                                                );
                                                if (mounted) _load();
                                              },
                                              style: OutlinedButton.styleFrom(
                                                side: BorderSide(
                                                  color: accent,
                                                  width: 1,
                                                ),
                                                foregroundColor: accent,
                                                backgroundColor: isDark
                                                    ? VyralColors.deepBlack
                                                    : VyralColors.cardBackground,
                                                shape: const StadiumBorder(),
                                              ),
                                              child: Text(
                                                'Edit Profile',
                                                style: VyralTypography.inter(
                                                  fontSize: 14,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                          ),
                                        )
                                      else
                                        Center(
                                          child: SizedBox(
                                            width: 160,
                                            height: 36,
                                            child: FilledButton(
                                              onPressed:
                                                  _followBusy ? null : _toggleFollow,
                                              style: FilledButton.styleFrom(
                                                backgroundColor: profile?.isFollowing ==
                                                        true
                                                    ? (isDark
                                                        ? VyralColors.blueGray
                                                        : VyralColors
                                                            .secondaryBackground)
                                                    : accent,
                                                foregroundColor: profile?.isFollowing ==
                                                        true
                                                    ? heading
                                                    : (isDark
                                                        ? VyralColors.deepBlack
                                                        : VyralColors.cardBackground),
                                                shape: const StadiumBorder(),
                                              ),
                                              child: _followBusy
                                                  ? const SizedBox(
                                                      width: 18,
                                                      height: 18,
                                                      child: CircularProgressIndicator(
                                                        strokeWidth: 2,
                                                      ),
                                                    )
                                                  : Text(
                                                      profile?.isFollowing == true
                                                          ? 'Following'
                                                          : 'Follow',
                                                      style: VyralTypography.inter(
                                                        fontSize: 14,
                                                        fontWeight: FontWeight.w600,
                                                      ),
                                                    ),
                                            ),
                                          ),
                                        ),
                                      const SizedBox(height: 16),
                                      TabBar(
                                        tabs: const [
                                          Tab(text: 'Pins'),
                                          Tab(text: 'Posts'),
                                        ],
                                        indicatorColor: accent,
                                        labelColor: heading,
                                        unselectedLabelColor: muted,
                                        dividerColor: divider,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ];
                        },
                        body: TabBarView(
                          children: [
                            GridView.builder(
                              padding: const EdgeInsets.all(16),
                              gridDelegate:
                                  const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 3,
                                crossAxisSpacing: 8,
                                mainAxisSpacing: 8,
                                childAspectRatio: 1.0,
                              ),
                              itemCount: _pins.isEmpty ? 6 : _pins.length,
                              itemBuilder: (ctx, i) {
                                final pin = i < _pins.length ? _pins[i] : null;
                                final url = pin?['mediaUrl'] as String?;
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: url != null
                                      ? CachedNetworkImage(
                                          imageUrl: url,
                                          fit: BoxFit.cover,
                                        )
                                      : Container(color: _pinShade(i)),
                                );
                              },
                            ),
                            _posts.isEmpty
                                ? const Center(child: Text('No posts yet'))
                                : ListView.builder(
                                    padding: const EdgeInsets.only(bottom: 8, top: 4),
                                    itemCount: _posts.length,
                                    itemBuilder: (ctx, i) {
                                      final post = _posts[i];
                                      return PostCard(
                                        key: ValueKey(post.id),
                                        post: post,
                                        onLike: (p, liked) async {
                                          final updated = await PostsApiService
                                              .instance
                                              .setLike(p, liked: liked);
                                          setState(() {
                                            _posts = _posts
                                                .map((x) =>
                                                    x.id == updated.id
                                                        ? updated
                                                        : x)
                                                .toList();
                                          });
                                          return updated;
                                        },
                                        onSave: (p, saved, {collectionId}) async {
                                          final updated = await PostsApiService
                                              .instance
                                              .setSaved(
                                            p,
                                            saved: saved,
                                            collectionId: collectionId,
                                          );
                                          setState(() {
                                            _posts = _posts
                                                .map((x) =>
                                                    x.id == updated.id
                                                        ? updated
                                                        : x)
                                                .toList();
                                          });
                                          return updated;
                                        },
                                        onPostUpdated: (updated) {
                                          setState(() {
                                            _posts = _posts
                                                .map((x) =>
                                                    x.id == updated.id
                                                        ? updated
                                                        : x)
                                                .toList();
                                          });
                                        },
                                        onPostDeleted: (id) {
                                          setState(() {
                                            _posts = _posts
                                                .where((x) => x.id != id)
                                                .toList();
                                          });
                                        },
                                      );
                                    },
                                  ),
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
              ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final muted = isDark ? VyralColors.dustyRose : VyralColors.secondaryText;
    return Column(
      children: [
        Text(
          value,
          style: VyralTypography.inter(
            fontSize: 18,
            fontWeight: FontWeight.w500,
            color: heading,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: VyralTypography.inter(fontSize: 11, color: muted),
        ),
      ],
    );
  }
}

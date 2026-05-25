import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  static final List<Post> _mockPosts = List.generate(
    8,
    (i) => Post(
      username: '@yourusername',
      timeAgo: '${i + 1}d ago',
      hasImage: i.isEven,
      caption:
          'Curating soft corners and quiet light — a moodboard for the week ahead.',
      likesCount: '${420 + i * 17}',
      commentsCount: '${24 + i}',
    ),
  );

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

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      body: SafeArea(
        child: DefaultTabController(
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
                                      colors: [
                                        coverStart,
                                        coverEnd,
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 8,
                                  left: 4,
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      VyralOpenNavMenuButton(color: heading, size: 22),
                                      IconButton(
                                        icon: const Icon(Icons.arrow_back),
                                        color: heading,
                                        onPressed: () => Navigator.of(context).pop(),
                                      ),
                                    ],
                                  ),
                                ),
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
                                        onPressed: () => Navigator.of(context).pushNamed('/settings'),
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  bottom: -44,
                                  left: 0,
                                  right: 0,
                                  child: Center(
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.center,
                                      children: [
                                        CircleAvatar(
                                          radius: 44,
                                          backgroundColor: accent,
                                        ),
                                        Positioned(
                                          top: 4,
                                          left: 4,
                                          child: CircleAvatar(
                                            radius: 40,
                                            backgroundColor: avatarBg,
                                            child: Text(
                                              'Y',
                                              style: VyralTypography.display(
                                                fontSize: 30,
                                                fontWeight: FontWeight.bold,
                                                color: heading,
                                              ),
                                            ),
                                          ),
                                        ),
                                        Positioned(
                                          top: 0,
                                          right: 0,
                                          child: Text(
                                            '✦',
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: accent,
                                            ),
                                          ),
                                        ),
                                      ],
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
                                  '@yourusername',
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
                                    'creating in soft chaos ✦ collector of moments',
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
                                    _StatColumn(value: '1.4k', label: 'Posts'),
                                    _StatColumn(value: '24.8k', label: 'Followers'),
                                    _StatColumn(value: '891', label: 'Following'),
                                  ],
                                ),
                                const SizedBox(height: 16),
                                Center(
                                  child: SizedBox(
                                    width: 160,
                                    height: 36,
                                    child: OutlinedButton(
                                      onPressed: () {},
                                      style: OutlinedButton.styleFrom(
                                        side: BorderSide(
                                          color: accent,
                                          width: 1,
                                        ),
                                        foregroundColor: accent,
                                        backgroundColor: isDark ? VyralColors.deepBlack : VyralColors.cardBackground,
                                        shape: const StadiumBorder(),
                                        minimumSize: const Size(160, 36),
                                        maximumSize: const Size(160, 36),
                                        padding: EdgeInsets.zero,
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
                                ),
                                const SizedBox(height: 16),
                                TabBar(
                                  tabs: const [
                                    Tab(text: 'Pins'),
                                    Tab(text: 'Posts'),
                                  ],
                                  indicatorColor: accent,
                                  indicatorWeight: 2,
                                  labelColor: heading,
                                  unselectedLabelColor: muted,
                                  labelStyle: VyralTypography.inter(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  unselectedLabelStyle: VyralTypography.inter(
                                    fontSize: 14,
                                  ),
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
                        itemCount: 12,
                        itemBuilder: (ctx, i) {
                          return ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              color: _pinShade(i),
                            ),
                          );
                        },
                      ),
                      ListView.builder(
                        padding: const EdgeInsets.only(bottom: 8, top: 4),
                        itemCount: _mockPosts.length,
                        itemBuilder: (ctx, i) =>
                            PostCard(post: _mockPosts[i]),
                      ),
                    ],
                  ),
                ),
              ),
              VyralBottomNav(
                currentIndex: 4,
                onDestinationSelected: _onBottomNav,
              ),
            ],
          ),
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
          style: VyralTypography.inter(
            fontSize: 11,
            color: muted,
          ),
        ),
      ],
    );
  }
}

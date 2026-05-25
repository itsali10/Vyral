import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/post_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class HomeFeedScreen extends StatefulWidget {
  const HomeFeedScreen({super.key});

  @override
  State<HomeFeedScreen> createState() => _HomeFeedScreenState();
}

class _HomeFeedScreenState extends State<HomeFeedScreen> {
  int _bottomIndex = 0;

  static final List<Post> _mockForYou = List.generate(
    10,
    (i) => Post(
      username: '@creator$i',
      timeAgo: '${i + 1}h ago',
      hasImage: i.isEven,
      caption:
          'Soft light, slow mornings, and the details that make a space feel like home. What are you curating this week?',
      likesCount: '${1_200 + i * 33}',
      commentsCount: '${48 + i}',
    ),
  );

  static final List<Post> _mockFollowing = List.generate(
    6,
    (i) => Post(
      username: '@friend$i',
      timeAgo: '${i * 2 + 1}d ago',
      hasImage: true,
      caption: 'Following feed — moments from people you care about.',
      likesCount: '${340 + i}',
      commentsCount: '${12 + i}',
    ),
  );

  static final List<Post> _mockTrending = List.generate(
    8,
    (i) => Post(
      username: '@trend$i',
      timeAgo: '${i + 3}h ago',
      hasImage: i.isOdd,
      caption: 'Trending on Vyral — ideas worth saving.',
      likesCount: '${4_000 + i * 100}',
      commentsCount: '${200 + i}',
    ),
  );

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

  Widget _tabList(List<Post> posts) {
    return ListView.builder(
      padding: const EdgeInsets.only(bottom: 8, top: 4),
      itemCount: posts.length,
      itemBuilder: (context, index) => PostCard(post: posts[index]),
    );
  }

  Widget _buildFeed() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final headerText = isDark ? VyralColors.white : VyralColors.primaryText;
    final tabBg = isDark ? VyralColors.surface : VyralColors.secondaryBackground;
    final indicator = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final unselected = isDark ? VyralColors.mutedText : VyralColors.secondaryText;

    return DefaultTabController(
      length: 3,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  VyralOpenNavMenuButton(color: headerText),
                  Text(
                    'vyral',
                    style: VyralTypography.display(
                      fontSize: 24,
                      fontWeight: FontWeight.w600,
                      color: headerText,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Notifications',
                    visualDensity: VisualDensity.compact,
                    onPressed: () {},
                    icon: Icon(Icons.notifications_outlined, size: 24, color: headerText),
                  ),
                  VyralUniversalActions(),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 40,
            child: ColoredBox(
              color: tabBg,
              child: TabBar(
                indicator: UnderlineTabIndicator(
                  borderSide: BorderSide(color: indicator, width: 2),
                ),
                indicatorSize: TabBarIndicatorSize.label,
                labelColor: headerText,
                unselectedLabelColor: unselected,
                labelStyle: VyralTypography.inter(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                unselectedLabelStyle: VyralTypography.inter(fontSize: 14),
                tabs: const [
                  Tab(text: 'For You'),
                  Tab(text: 'Following'),
                  Tab(text: 'Trending'),
                ],
              ),
            ),
          ),
          Expanded(
            child: TabBarView(
              children: [
                _tabList(_mockForYou),
                _tabList(_mockFollowing),
                _tabList(_mockTrending),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Text(
        title,
        style: VyralTypography.inter(
          color: isDark ? VyralColors.mutedText : VyralColors.secondaryText,
          fontSize: 16,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? VyralColors.background : VyralColors.mainBackground,
      drawer: const VyralNavigationDrawer(),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _bottomIndex,
              children: [
                _buildFeed(),
                _placeholder('Explore'),
                _placeholder('Create'),
                _placeholder('Saved'),
                _placeholder('Profile'),
              ],
            ),
          ),
          VyralBottomNav(
            currentIndex: _bottomIndex,
            onDestinationSelected: _onBottomNav,
          ),
        ],
      ),
    );
  }
}

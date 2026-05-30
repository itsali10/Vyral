import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../models/feed_post.dart';
import '../services/posts_api_service.dart';
import '../services/settings_preferences.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../screens/post_detail_screen.dart';
import '../widgets/grid_post_card.dart';
import '../widgets/vyral_animations.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_refresh_scroll.dart';
import '../widgets/vyral_responsive_body.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  static const _categories = [
    'All',
    'Fashion',
    'Design',
    'Quotes',
  ];

  final _searchController = TextEditingController();
  List<ExploreGridItem> _items = [];
  List<FeedPost> _explorePosts = [];
  String _selectedCategory = 'All';
  String _searchText = '';
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    SettingsPreferences.instance.addListener(_onSettingsChanged);
    _load();
  }

  void _onSettingsChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    SettingsPreferences.instance.removeListener(_onSettingsChanged);
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final posts = await PostsApiService.instance.explore(
        q: _searchText,
        category: _selectedCategory,
      );
      final rnd = Random(42);
      if (!mounted) return;
      setState(() {
        _explorePosts = posts;
        _items = posts.asMap().entries.map((entry) {
          final i = entry.key;
          final post = entry.value;
          final explore = ExploreItem.fromFeedPost(post);
          return ExploreGridItem(
            postId: post.id,
            height: 120 + rnd.nextInt(81).toDouble(),
            label: explore.label,
            username: explore.username,
            mediaUrl: explore.mediaUrl,
            imageColor: VyralColors.exploreMasonryShades[
                i % VyralColors.exploreMasonryShades.length],
          );
        }).toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
    }
  }

  void _showFilterSheet() {
    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Filter by category',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                ),
              ),
              ..._categories.map(
                (cat) => ListTile(
                  title: Text(cat),
                  trailing: _selectedCategory == cat
                      ? const Icon(Icons.check)
                      : null,
                  onTap: () {
                    setState(() => _selectedCategory = cat);
                    Navigator.pop(ctx);
                    _load();
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _openPost(int index) {
    final item = _items[index];
    FeedPost? initial;
    for (final p in _explorePosts) {
      if (p.id == item.postId) {
        initial = p;
        break;
      }
    }
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => PostDetailScreen(
          postId: item.postId,
          initialPost: initial,
        ),
      ),
    );
  }

  void _onBottomNav(int index) {
    switch (index) {
      case 0:
        Navigator.of(context).pushReplacementNamed('/home');
        break;
      case 1:
        break;
      case 2:
        Navigator.of(context).pushNamed('/create');
        break;
      case 3:
        Navigator.of(context).pushNamed('/saved');
        break;
      case 4:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  List<ExploreGridItem> get _filteredItems => _items;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.background : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final searchBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final border = isDark ? VyralColors.blueGray : VyralColors.border;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    final selectedChipText = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final chipBg = isDark ? VyralColors.surface : VyralColors.secondaryBackground;
    final items = _filteredItems;
    final isSearching = _searchText.trim().isNotEmpty;
    final hasEmptyResults = isSearching && items.isEmpty;

    return VyralScaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      body: VyralResponsiveBody(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
              child: Row(
                children: [
                  VyralOpenNavMenuButton(color: heading),
                  const SizedBox(width: 4),
                  Text(
                    'Explore',
                    style: VyralTypography.display(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: heading,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Filters',
                    visualDensity: VisualDensity.compact,
                    onPressed: _showFilterSheet,
                    icon: Icon(Icons.tune, size: 18, color: muted),
                  ),
                  VyralUniversalActions(),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                height: 46,
                decoration: BoxDecoration(
                  color: searchBg,
                  borderRadius: BorderRadius.circular(23),
                  border: Border.all(color: border, width: 0.7),
                ),
                child: Row(
                  children: [
                    Padding(
                      padding: EdgeInsets.only(left: 14),
                      child: Icon(Icons.search, color: muted, size: 20),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        onChanged: (v) {
                          setState(() => _searchText = v);
                          _load();
                        },
                        style: VyralTypography.inter(fontSize: 14, color: heading),
                        decoration: InputDecoration.collapsed(
                          hintText: 'Search posts, people, tags...',
                          hintStyle: VyralTypography.inter(
                            fontSize: 14,
                            color: muted,
                          ),
                        ),
                      ),
                    ),
                    if (_searchText.isNotEmpty)
                      IconButton(
                        iconSize: 18,
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _searchText = '');
                        },
                        icon: Icon(Icons.cancel, color: muted),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 40,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _categories.length,
                itemBuilder: (context, index) {
                  final cat = _categories[index];
                  final selected = _selectedCategory == cat;
                  return Padding(
                    padding: EdgeInsets.only(right: index < _categories.length - 1 ? 8 : 0),
                    child: AnimatedPressable(
                      child: GestureDetector(
                      onTap: () {
                        setState(() => _selectedCategory = cat);
                        _load();
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        curve: Curves.easeOut,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                        decoration: BoxDecoration(
                          color: selected ? accent : chipBg,
                          borderRadius: BorderRadius.circular(16),
                          border: selected
                              ? null
                              : Border.all(color: border, width: 1),
                        ),
                        alignment: Alignment.center,
                        child: Text(
                          cat,
                          style: VyralTypography.inter(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: selected ? selectedChipText : muted,
                          ),
                        ),
                      ),
                    ),
                  ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: _loading
                  ? const Center(child: CircularProgressIndicator())
                  : hasEmptyResults
                      ? VyralRefreshScrollView(
                          onRefresh: _load,
                          child: _EmptyResultsState(
                            muted: muted,
                            heading: heading,
                            onClear: () {
                              _searchController.clear();
                              setState(() => _searchText = '');
                              _load();
                            },
                            isDark: isDark,
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _load,
                          child: MasonryGridView.count(
                            physics: vyralRefreshScrollPhysics,
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100),
                            crossAxisCount:
                                SettingsPreferences.instance.exploreGridCompact
                                    ? 3
                                    : 2,
                            mainAxisSpacing: 12,
                            crossAxisSpacing: 12,
                            itemCount: items.length,
                            itemBuilder: (context, index) => FadeSlideIn(
                              delay: VyralAnimations.staggerDelay(index),
                              child: GridPostCard(
                                item: items[index],
                                onTap: () => _openPost(index),
                              ),
                            ),
                          ),
                        ),
            ),
            VyralBottomNav(
              currentIndex: 1,
              onDestinationSelected: _onBottomNav,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyResultsState extends StatelessWidget {
  const _EmptyResultsState({
    required this.muted,
    required this.heading,
    required this.onClear,
    required this.isDark,
  });

  final Color muted;
  final Color heading;
  final VoidCallback onClear;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 26),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 74,
              height: 74,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (isDark ? VyralColors.card : VyralColors.secondaryBackground),
              ),
              child: Icon(Icons.search, color: muted, size: 34),
            ),
            const SizedBox(height: 20),
            Text(
              'No results found',
              style: VyralTypography.inter(
                fontSize: 28 / 2,
                fontWeight: FontWeight.w700,
                color: heading,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              "We couldn't find anything for your search. Try adjusting your filters or searching for something else.",
              textAlign: TextAlign.center,
              style: VyralTypography.inter(
                fontSize: 14,
                height: 1.4,
                color: muted,
              ),
            ),
            const SizedBox(height: 18),
            OutlinedButton(
              onPressed: onClear,
              style: OutlinedButton.styleFrom(
                foregroundColor: heading,
                side: BorderSide(color: isDark ? VyralColors.blueGray : VyralColors.border),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              ),
              child: Text(
                'Clear search',
                style: VyralTypography.inter(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

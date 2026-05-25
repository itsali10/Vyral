import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/grid_post_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
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
  late final List<ExploreGridItem> _items;
  String _selectedCategory = 'All';
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    final rnd = Random(42);
    _items = List.generate(
      20,
      (i) => ExploreGridItem(
        height: 120 + rnd.nextInt(81).toDouble(),
        label: switch (i % 6) {
          0 => 'bloom',
          1 => 'night',
          2 => 'art',
          3 => 'vibes',
          4 => 'shots',
          _ => 'dream',
        },
        username: switch (i % 6) {
          0 => '@flora',
          1 => '@lunar',
          2 => '@studio',
          3 => '@aura',
          4 => '@lens',
          _ => '@star',
        },
        imageColor: VyralColors.exploreMasonryShades[i % VyralColors.exploreMasonryShades.length],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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

  List<ExploreGridItem> _filteredItems() {
    var list = _items;
    if (_selectedCategory != 'All') {
      final cat = _selectedCategory.toLowerCase();
      list = list
          .where(
            (e) =>
                e.label.toLowerCase().contains(cat) ||
                e.username.toLowerCase().contains(cat),
          )
          .toList();
    }
    final query = _searchText.trim().toLowerCase();
    if (query.isNotEmpty) {
      list = list
          .where(
            (e) =>
                e.label.toLowerCase().contains(query) ||
                e.username.toLowerCase().contains(query),
          )
          .toList();
    }
    return list;
  }

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
    final items = _filteredItems();
    final isSearching = _searchText.trim().isNotEmpty;
    final hasEmptyResults = isSearching && items.isEmpty;

    return Scaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      body: SafeArea(
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
                    onPressed: () {},
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
                        onChanged: (v) => setState(() => _searchText = v),
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
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedCategory = cat),
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
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: hasEmptyResults
                  ? _EmptyResultsState(
                      muted: muted,
                      heading: heading,
                      onClear: () {
                        _searchController.clear();
                        setState(() => _searchText = '');
                      },
                      isDark: isDark,
                    )
                  : Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (isSearching)
                            Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Text(
                                '${items.length} results found'.toUpperCase(),
                                style: VyralTypography.inter(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                  color: muted,
                                  letterSpacing: 0.6,
                                ),
                              ),
                            ),
                          Expanded(
                            child: MasonryGridView.count(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                              itemCount: items.length,
                              itemBuilder: (context, index) => GridPostCard(item: items[index]),
                            ),
                          ),
                        ],
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

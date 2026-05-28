import 'package:flutter/material.dart';
import '../main.dart';
import '../models/saved_collection.dart';
import '../services/users_api_service.dart';
import '../theme/vyral_typography.dart';

import '../theme/vyral_theme.dart';
import '../widgets/collection_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_refresh_scroll.dart';
import '../widgets/vyral_scaffold.dart';
import '../widgets/vyral_universal_actions.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> with RouteAware {
  List<SavedCollection> _collections = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
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
    super.dispose();
  }

  @override
  void didPopNext() {
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final list = await UsersApiService.instance.getCollections();
      if (!mounted) return;
      setState(() {
        _collections = list
            .map(
              (c) => SavedCollection(
                id: c.id,
                name: c.name,
                postCount: c.postCount,
              ),
            )
            .toList();
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not load collections: $e')),
      );
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
        break;
      case 4:
        Navigator.of(context).pushNamed('/profile');
        break;
    }
  }

  void _createCollection() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final sheetBg = isDark ? VyralColors.card : VyralColors.cardBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final text = isDark ? VyralColors.caption : VyralColors.primaryText;
    final muted = isDark ? VyralColors.mutedText : VyralColors.placeholder;
    final inputBg = isDark ? VyralColors.surface : VyralColors.inputBackground;
    final border = isDark ? VyralColors.blueGray : VyralColors.border;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final accentFg = isDark ? VyralColors.deepBlack : VyralColors.cardBackground;
    final nameController = TextEditingController();
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: sheetBg,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (sheetContext) {
        return Padding(
          padding: EdgeInsets.only(
            left: 24,
            right: 24,
            top: 24,
            bottom: 24 + MediaQuery.viewInsetsOf(sheetContext).bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'New collection',
                style: VyralTypography.display(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: heading,
                ),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: nameController,
                autofocus: true,
                style: VyralTypography.inter(fontSize: 16, color: text),
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: VyralTypography.inter(color: muted),
                  filled: true,
                  fillColor: inputBg,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: border),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: border),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: accent),
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: (_) =>
                    _submitNewCollection(nameController, sheetContext),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () =>
                    _submitNewCollection(nameController, sheetContext),
                style: FilledButton.styleFrom(
                  backgroundColor: accent,
                  foregroundColor: accentFg,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  'Create',
                  style: VyralTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    ).whenComplete(nameController.dispose);
  }

  Future<void> _submitNewCollection(
    TextEditingController controller,
    BuildContext sheetContext,
  ) async {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    try {
      await UsersApiService.instance.createCollection(name);
      if (!mounted) return;
      Navigator.of(sheetContext).pop();
      await _load();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not create collection: $e')),
      );
    }
  }

  Widget _bodyContent(bool isDark, Color muted) {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_collections.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Nothing saved yet.\nTap Save on a post, then pull down to refresh.',
            textAlign: TextAlign.center,
            style: VyralTypography.inter(fontSize: 14, color: muted),
          ),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
      itemCount: _collections.length,
      itemBuilder: (context, index) {
        return CollectionCard(collection: _collections[index]);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    return VyralScaffold(
      backgroundColor: pageBg,
      drawer: const VyralNavigationDrawer(),
      appBar: AppBar(
        backgroundColor: pageBg,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: VyralOpenNavMenuButton(color: heading),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Saved',
              style: VyralTypography.display(
                fontSize: 26,
                fontWeight: FontWeight.bold,
                color: heading,
              ),
            ),
            const SizedBox(width: 8),
            Text('✦', style: VyralTypography.inter(fontSize: 12, color: accent)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            color: heading,
            onPressed: _load,
          ),
          const VyralUniversalActions(),
          IconButton(
            icon: const Icon(Icons.add),
            color: accent,
            iconSize: 24,
            onPressed: _createCollection,
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Text(
              'Pull down to refresh · Tap a collection to view posts',
              style: VyralTypography.inter(fontSize: 13, color: muted),
            ),
          ),
          Expanded(
            child: VyralRefreshScrollView(
              onRefresh: _load,
              child: _bodyContent(isDark, muted),
            ),
          ),
          VyralBottomNav(
            currentIndex: 3,
            onDestinationSelected: _onBottomNav,
          ),
        ],
      ),
    );
  }
}

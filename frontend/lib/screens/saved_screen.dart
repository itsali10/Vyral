import 'package:flutter/material.dart';
import '../theme/vyral_typography.dart';

import '../models/saved_collection.dart';
import '../theme/vyral_theme.dart';
import '../widgets/collection_card.dart';
import '../widgets/vyral_bottom_nav.dart';
import '../widgets/vyral_navigation_drawer.dart';
import '../widgets/vyral_universal_actions.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late List<SavedCollection> _collections;

  @override
  void initState() {
    super.initState();
    _collections = const [
      SavedCollection(name: 'Soft mornings', postCount: '24'),
      SavedCollection(name: 'Wardrobe notes', postCount: '12'),
      SavedCollection(name: 'Travel pins', postCount: '48'),
      SavedCollection(name: 'Recipes to try', postCount: '9'),
    ];
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
                style: VyralTypography.inter(
                  fontSize: 16,
                  color: text,
                ),
                decoration: InputDecoration(
                  hintText: 'Collection name',
                  hintStyle: VyralTypography.inter(
                    color: muted,
                  ),
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
                onSubmitted: (_) => _submitNewCollection(nameController, sheetContext),
              ),
              const SizedBox(height: 20),
              FilledButton(
                onPressed: () => _submitNewCollection(nameController, sheetContext),
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

  void _submitNewCollection(TextEditingController controller, BuildContext sheetContext) {
    final name = controller.text.trim();
    if (name.isEmpty) return;
    setState(() {
      _collections = [
        ..._collections,
        SavedCollection(name: name, postCount: '0'),
      ];
    });
    Navigator.of(sheetContext).pop();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final pageBg = isDark ? VyralColors.surface : VyralColors.mainBackground;
    final heading = isDark ? VyralColors.white : VyralColors.primaryText;
    final accent = isDark ? VyralColors.softPink : VyralColors.primaryRose;
    final muted = isDark ? VyralColors.mutedText : VyralColors.secondaryText;
    return Scaffold(
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
            Text(
              '✦',
              style: VyralTypography.inter(
                fontSize: 12,
                color: accent,
              ),
            ),
          ],
        ),
        actions: [
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
              'Your collections',
              style: VyralTypography.inter(
                fontSize: 14,
                color: muted,
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 100),
              itemCount: _collections.length,
              itemBuilder: (context, index) {
                return CollectionCard(collection: _collections[index]);
              },
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

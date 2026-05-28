import 'package:flutter/material.dart';

import '../services/settings_preferences.dart';
import '../services/api_client.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_scaffold.dart';

class FeedPreferencesScreen extends StatefulWidget {
  const FeedPreferencesScreen({super.key});

  @override
  State<FeedPreferencesScreen> createState() => _FeedPreferencesScreenState();
}

class _FeedPreferencesScreenState extends State<FeedPreferencesScreen> {
  late String _tab;

  @override
  void initState() {
    super.initState();
    _tab = SettingsPreferences.instance.defaultFeedTab;
  }

  Future<void> _select(String tab, String label) async {
    try {
      await SettingsPreferences.instance.update({'defaultFeedTab': tab});
      if (!mounted) return;
      setState(() => _tab = tab);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Default feed: $label')),
      );
    } on ApiException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    const options = [
      ('for_you', 'For You'),
      ('following', 'Following'),
      ('trending', 'Trending'),
    ];

    return VyralScaffold(
      appBar: AppBar(
        title: Text('Feed preferences', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: ListView(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Choose which tab opens first on Home.',
              style: VyralTypography.inter(fontSize: 13),
            ),
          ),
          ...options.map(
            (o) => ListTile(
              title: Text(o.$2),
              trailing: _tab == o.$1
                  ? const Icon(Icons.check_rounded)
                  : null,
              onTap: () => _select(o.$1, o.$2),
            ),
          ),
        ],
      ),
    );
  }
}

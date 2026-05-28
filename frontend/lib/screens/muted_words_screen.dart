import 'package:flutter/material.dart';

import '../services/settings_preferences.dart';
import '../services/api_client.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../widgets/vyral_scaffold.dart';

class MutedWordsScreen extends StatefulWidget {
  const MutedWordsScreen({super.key});

  @override
  State<MutedWordsScreen> createState() => _MutedWordsScreenState();
}

class _MutedWordsScreenState extends State<MutedWordsScreen> {
  final _inputController = TextEditingController();
  late List<String> _words;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _words = List<String>.from(SettingsPreferences.instance.settings.mutedWords);
  }

  @override
  void dispose() {
    _inputController.dispose();
    super.dispose();
  }

  Future<void> _save(List<String> words) async {
    setState(() => _saving = true);
    try {
      await SettingsPreferences.instance.update({'mutedWords': words});
      if (!mounted) return;
      setState(() {
        _words = words;
        _saving = false;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(friendlyApiMessage(e))),
      );
    }
  }

  void _addWord() {
    final word = _inputController.text.trim().toLowerCase();
    if (word.isEmpty) return;
    if (_words.contains(word)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Word already muted')),
      );
      return;
    }
    final next = [..._words, word];
    _inputController.clear();
    _save(next);
  }

  void _remove(String word) {
    _save(_words.where((w) => w != word).toList());
  }

  @override
  Widget build(BuildContext context) {
    return VyralScaffold(
      appBar: AppBar(
        title: Text('Muted words', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Posts containing these words are hidden from your feed and explore.',
            style: VyralTypography.inter(fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _inputController,
                  decoration: InputDecoration(
                    hintText: 'Add a word or phrase',
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onSubmitted: (_) => _addWord(),
                ),
              ),
              const SizedBox(width: 8),
              FilledButton(
                onPressed: _saving ? null : _addWord,
                child: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (_words.isEmpty)
            const Text('No muted words yet')
          else
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _words
                  .map(
                    (w) => InputChip(
                      label: Text(w),
                      onDeleted: _saving ? null : () => _remove(w),
                    ),
                  )
                  .toList(),
            ),
        ],
      ),
    );
  }
}

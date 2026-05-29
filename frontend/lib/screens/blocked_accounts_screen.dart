import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/api_client.dart';
import '../services/settings_api_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_scaffold.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key, this.autofocusSearch = false});

  final bool autofocusSearch;

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final _searchFocus = FocusNode();
  final _searchController = TextEditingController();
  List<BlockedUserSummary> _blocked = [];
  List<BlockedUserSummary> _searchResults = [];
  bool _loading = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
    if (widget.autofocusSearch) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _searchFocus.requestFocus();
      });
    }
  }

  @override
  void dispose() {
    _searchFocus.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Set<String> get _blockedIds => _blocked.map((u) => u.id).toSet();

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final items = await SettingsApiService.instance.getBlockedUsers();
      if (!mounted) return;
      setState(() {
        _blocked = items;
        _loading = false;
      });
    } on ApiException catch (e) {
      _error(friendlyApiMessage(e));
    } catch (e) {
      _error('Could not load blocked accounts: $e');
    }
  }

  void _error(String msg) {
    if (!mounted) return;
    setState(() => _loading = false);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _search(String q) async {
    if (q.trim().length < 2) {
      setState(() => _searchResults = []);
      return;
    }
    setState(() => _searching = true);
    try {
      final items = await SettingsApiService.instance.searchUsers(q.trim());
      if (!mounted) return;
      setState(() {
        _searchResults =
            items.where((u) => !_blockedIds.contains(u.id)).toList();
        _searching = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _searching = false);
    }
  }

  Future<void> _block(String userId) async {
    try {
      await SettingsApiService.instance.blockUser(userId);
      _searchController.clear();
      setState(() => _searchResults = []);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User blocked')),
      );
    } on ApiException catch (e) {
      _error(friendlyApiMessage(e));
    }
  }

  Future<void> _unblock(String userId) async {
    try {
      await SettingsApiService.instance.unblockUser(userId);
      await _load();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User unblocked')),
      );
    } on ApiException catch (e) {
      _error(friendlyApiMessage(e));
    }
  }

  @override
  Widget build(BuildContext context) {
    return VyralScaffold(
      appBar: AppBar(
        title: Text('Blocked accounts', style: VyralTypography.inter(fontSize: 17)),
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Text(
                  'Block account',
                  style: VyralTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Search for a user to block. They will not appear in your feed.',
                  style: VyralTypography.inter(
                    fontSize: 13,
                    color: VyralColors.secondaryText,
                  ),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocus,
                  decoration: InputDecoration(
                    hintText: 'Search by username',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searching
                        ? const Padding(
                            padding: EdgeInsets.all(12),
                            child: SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          )
                        : null,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onChanged: _search,
                ),
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    'Search results',
                    style: VyralTypography.inter(fontWeight: FontWeight.w600),
                  ),
                  ..._searchResults.map(
                    (u) => ListTile(
                      title: Text(u.fullName),
                      subtitle: Text(u.displayUsername),
                      trailing: TextButton(
                        onPressed: () => _block(u.id),
                        child: const Text('Block'),
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 24),
                Text(
                  'Blocked accounts',
                  style: VyralTypography.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                if (_blocked.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: Text(
                      'No blocked accounts yet.',
                      style: VyralTypography.inter(
                        fontSize: 13,
                        color: VyralColors.secondaryText,
                      ),
                    ),
                  )
                else
                  ..._blocked.map(
                    (u) => ListTile(
                      title: Text(u.fullName),
                      subtitle: Text(u.displayUsername),
                      trailing: TextButton(
                        onPressed: () => _unblock(u.id),
                        child: const Text('Unblock'),
                      ),
                    ),
                  ),
              ],
            ),
    );
  }
}

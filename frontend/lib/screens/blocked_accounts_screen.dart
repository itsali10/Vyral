import 'package:flutter/material.dart';

import '../models/user_settings.dart';
import '../services/api_client.dart';
import '../services/settings_api_service.dart';
import '../utils/api_error_messages.dart';
import '../theme/vyral_typography.dart';
import '../theme/vyral_theme.dart';
import '../widgets/vyral_scaffold.dart';

class BlockedAccountsScreen extends StatefulWidget {
  const BlockedAccountsScreen({super.key});

  @override
  State<BlockedAccountsScreen> createState() => _BlockedAccountsScreenState();
}

class _BlockedAccountsScreenState extends State<BlockedAccountsScreen> {
  final _searchController = TextEditingController();
  List<BlockedUserSummary> _blocked = [];
  List<BlockedUserSummary> _searchResults = [];
  bool _loading = true;
  bool _searching = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

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
        _searchResults = items;
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
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by username to block',
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
                  Text('Results', style: VyralTypography.inter(fontWeight: FontWeight.w600)),
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
                const SizedBox(height: 20),
                Text(
                  _blocked.isEmpty ? 'No blocked accounts' : 'Blocked',
                  style: VyralTypography.inter(
                    fontWeight: FontWeight.w600,
                    color: VyralColors.secondaryText,
                  ),
                ),
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

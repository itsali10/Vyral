import '../models/user_settings.dart';
import 'api_client.dart';

class SettingsApiService {
  SettingsApiService._();
  static final SettingsApiService instance = SettingsApiService._();

  Future<UserSettings> getSettings() async {
    final data = await ApiClient.instance.get('/users/me/settings');
    return UserSettings.fromJson(data);
  }

  Future<UserSettings> updateSettings(Map<String, dynamic> patch) async {
    final data = await ApiClient.instance.patch('/users/me/settings', body: patch);
    return UserSettings.fromJson(data);
  }

  Future<List<BlockedUserSummary>> getBlockedUsers() async {
    final data = await ApiClient.instance.get('/users/me/blocks');
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => BlockedUserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<void> blockUser(String userId) async {
    await ApiClient.instance.post('/users/me/blocks/$userId');
  }

  Future<void> unblockUser(String userId) async {
    await ApiClient.instance.delete('/users/me/blocks/$userId');
  }

  Future<List<BlockedUserSummary>> searchUsers(String query) async {
    final data = await ApiClient.instance.get(
      '/users/search',
      query: {'q': query},
    );
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => BlockedUserSummary.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_settings.dart';
import 'settings_api_service.dart';

/// Local cache + sync with backend user settings.
class SettingsPreferences extends ChangeNotifier {
  SettingsPreferences._();
  static final SettingsPreferences instance = SettingsPreferences._();

  static const _prefix = 'vyral_settings_';

  UserSettings? _settings;
  UserSettings get settings => _settings ?? const UserSettings();

  bool get dataSaver => settings.dataSaver;
  bool get exploreGridCompact => settings.exploreGridCompact;
  bool get hapticsEnabled => settings.hapticsEnabled;
  String get defaultFeedTab => settings.defaultFeedTab;

  Future<bool> getBool(String key, {bool defaultValue = false}) async {
    return _readLocalBool(key, defaultValue: defaultValue);
  }

  Future<void> setBool(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('$_prefix$key', value);
  }

  Future<void> loadFromApi() async {
    try {
      final remote = await SettingsApiService.instance.getSettings();
      _settings = remote;
      await _persistLocal(remote);
      notifyListeners();
    } catch (_) {
      await _loadFromLocal();
    }
  }

  Future<void> applyFromProfile(Map<String, dynamic>? json) async {
    if (json == null) {
      await _loadFromLocal();
      return;
    }
    _settings = UserSettings.fromJson(json);
    await _persistLocal(_settings!);
    notifyListeners();
  }

  Future<UserSettings> update(Map<String, dynamic> patch) async {
    final updated = await SettingsApiService.instance.updateSettings(patch);
    _settings = updated;
    await _persistLocal(updated);
    notifyListeners();
    return updated;
  }

  Future<void> updateBoolSetting(String apiKey, bool value) async {
    await update({apiKey: value});
  }

  Future<void> _loadFromLocal() async {
    _settings = UserSettings(
      showLikesPublicly: await _readLocalBool('showLikesPublicly', defaultValue: true),
      notifLikes: await _readLocalBool('notifLikes', defaultValue: true),
      notifComments: await _readLocalBool('notifComments', defaultValue: true),
      notifFollowers: await _readLocalBool('notifFollowers', defaultValue: true),
      notifTrending: await _readLocalBool('notifTrending', defaultValue: false),
      dataSaver: await _readLocalBool('dataSaver', defaultValue: false),
      hapticsEnabled: await _readLocalBool('haptics', defaultValue: true),
      exploreGridCompact: await _readLocalBool('exploreGridCompact', defaultValue: false),
      accentColor: await _readLocalString('accentColor', defaultValue: 'rose'),
      defaultFeedTab: await _readLocalString('defaultFeedTab', defaultValue: 'for_you'),
    );
    notifyListeners();
  }

  Future<void> _persistLocal(UserSettings s) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('${_prefix}showLikesPublicly', s.showLikesPublicly);
    await prefs.setBool('${_prefix}notifLikes', s.notifLikes);
    await prefs.setBool('${_prefix}notifComments', s.notifComments);
    await prefs.setBool('${_prefix}notifFollowers', s.notifFollowers);
    await prefs.setBool('${_prefix}notifTrending', s.notifTrending);
    await prefs.setBool('${_prefix}dataSaver', s.dataSaver);
    await prefs.setBool('${_prefix}haptics', s.hapticsEnabled);
    await prefs.setBool('${_prefix}exploreGridCompact', s.exploreGridCompact);
    await prefs.setString('${_prefix}accentColor', s.accentColor);
    await prefs.setString('${_prefix}defaultFeedTab', s.defaultFeedTab);
  }

  Future<bool> _readLocalBool(String key, {required bool defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('$_prefix$key') ?? defaultValue;
  }

  Future<String> _readLocalString(String key, {required String defaultValue}) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('$_prefix$key') ?? defaultValue;
  }
}

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/feed_post.dart';
import 'api_client.dart';
import 'google_sign_in_helper.dart';
import 'settings_preferences.dart';

class AuthService extends ChangeNotifier {
  AuthService._();
  static final AuthService instance = AuthService._();

  static const _accessKey = 'vyral_access_token';
  static const _refreshKey = 'vyral_refresh_token';
  static const _userIdKey = 'vyral_user_id';

  String? _accessToken;
  String? _refreshToken;
  UserProfile? _user;

  String? get accessToken => _accessToken;
  bool get isLoggedIn => _accessToken != null;
  UserProfile? get user => _user;

  /// Fast: read saved tokens only (no network). Safe to await before [runApp].
  Future<void> loadFromDisk() async {
    final prefs = await SharedPreferences.getInstance();
    _accessToken = prefs.getString(_accessKey);
    _refreshToken = prefs.getString(_refreshKey);
    notifyListeners();
  }

  /// Slow: validate token with API. Run after the first frame on a background pass.
  Future<void> validateSession() async {
    if (_accessToken == null) return;
    try {
      final data = await ApiClient.instance.get('/users/me');
      _user = UserProfile.fromJson(data);
      await SettingsPreferences.instance.applyFromProfile(
        data['settings'] as Map<String, dynamic>?,
      );
      notifyListeners();
    } catch (_) {
      await clearSession();
    }
  }

  Future<void> init() async {
    await loadFromDisk();
    await validateSession();
  }

  Future<void> register({
    required String fullName,
    required String username,
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(
      '/auth/register',
      body: {
        'fullName': fullName,
        'username': username.replaceAll('@', ''),
        'email': email,
        'password': password,
      },
      auth: false,
    );
    await _persistSession(data);
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    await ApiClient.instance.post(
      '/auth/change-password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
  }

  Future<void> forgotPassword({required String email}) async {
    await ApiClient.instance.post(
      '/auth/forgot-password',
      body: {'email': email},
      auth: false,
    );
  }

  Future<void> loginWithGoogle() async {
    final idToken = await GoogleSignInHelper.signInAndGetIdToken();
    if (idToken == null) {
      throw ApiException('Google sign-in was cancelled', statusCode: 400);
    }
    await loginWithGoogleIdToken(idToken);
  }

  Future<void> loginWithGoogleIdToken(String idToken) async {
    final data = await ApiClient.instance.post(
      '/auth/google',
      body: {'idToken': idToken},
      auth: false,
    );
    await _persistSession(data);
  }

  Future<void> login({
    required String email,
    required String password,
  }) async {
    final data = await ApiClient.instance.post(
      '/auth/login',
      body: {'email': email, 'password': password},
      auth: false,
    );
    await _persistSession(data);
  }

  Future<void> logout() async {
    try {
      await ApiClient.instance.post('/auth/logout');
    } catch (_) {}
    await clearSession();
  }

  Future<void> deleteAccount() async {
    await ApiClient.instance.delete('/users/me');
    await clearSession();
  }

  Future<void> refreshProfile() async {
    final data = await ApiClient.instance.get('/users/me');
    _user = UserProfile.fromJson(data);
    await SettingsPreferences.instance.applyFromProfile(
      data['settings'] as Map<String, dynamic>?,
    );
    notifyListeners();
  }

  Future<void> _persistSession(Map<String, dynamic> data) async {
    final session = data['session'] as Map<String, dynamic>?;
    final userJson = data['user'] as Map<String, dynamic>?;
    if (session == null) throw ApiException('No session returned');

    _accessToken = session['accessToken'] as String?;
    _refreshToken = session['refreshToken'] as String?;
    if (userJson != null) {
      _user = UserProfile.fromJson({
        ...userJson,
        'displayUsername': '@${userJson['username']}',
        'postsCount': 0,
        'followersCount': 0,
        'followingCount': 0,
      });
    }

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_accessKey, _accessToken ?? '');
    await prefs.setString(_refreshKey, _refreshToken ?? '');
    if (_user != null) {
      await prefs.setString(_userIdKey, _user!.id);
    }
    await refreshProfile();
    notifyListeners();
  }

  Future<void> clearSession() async {
    _accessToken = null;
    _refreshToken = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_accessKey);
    await prefs.remove(_refreshKey);
    await prefs.remove(_userIdKey);
    notifyListeners();
  }
}

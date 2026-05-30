import '../models/feed_post.dart';
import '../models/user_search_result.dart';
import 'api_client.dart';

class UsersApiService {
  UsersApiService._();
  static final UsersApiService instance = UsersApiService._();

  Future<UserProfile> getMe() async {
    final data = await ApiClient.instance.get('/users/me');
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> getUser(String userId) async {
    final data = await ApiClient.instance.get('/users/$userId');
    return UserProfile.fromJson(data);
  }

  Future<UserProfile> updateMe(Map<String, dynamic> body) async {
    final data = await ApiClient.instance.patch('/users/me', body: body);
    return UserProfile.fromJson(data);
  }

  Future<void> follow(String userId) async {
    await ApiClient.instance.post('/users/$userId/follow');
  }

  Future<void> unfollow(String userId) async {
    await ApiClient.instance.delete('/users/$userId/follow');
  }

  Future<List<FeedPost>> getMyPosts({int page = 1}) async {
    return _parsePosts(
      await ApiClient.instance.get(
        '/users/me/posts',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  Future<List<FeedPost>> getUserPosts(String userId, {int page = 1}) async {
    return _parsePosts(
      await ApiClient.instance.get(
        '/users/$userId/posts',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  List<FeedPost> _parsePosts(Map<String, dynamic> data) {
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<Map<String, dynamic>>> getMyPins({int page = 1}) async {
    return _parsePins(
      await ApiClient.instance.get(
        '/users/me/pins',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  Future<List<Map<String, dynamic>>> getUserPins(String userId,
      {int page = 1}) async {
    return _parsePins(
      await ApiClient.instance.get(
        '/users/$userId/pins',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  List<Map<String, dynamic>> _parsePins(Map<String, dynamic> data) {
    final items = data['items'] as List<dynamic>? ?? [];
    return items.map((e) => Map<String, dynamic>.from(e as Map)).toList();
  }

  Future<List<SavedCollectionModel>> getCollections() async {
    final data = await ApiClient.instance.get('/users/me/saved/collections');
    final list = data['collections'] as List<dynamic>? ?? [];
    return list
        .map((e) => SavedCollectionModel.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeedPost>> getCollectionPosts(String collectionId) async {
    final data = await ApiClient.instance.get(
      '/users/me/saved/collections/$collectionId/posts',
    );
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SavedCollectionModel> createCollection(String name) async {
    final data = await ApiClient.instance.post(
      '/users/me/saved/collections',
      body: {'name': name},
    );
    return SavedCollectionModel.fromJson(data);
  }

  Future<List<FeedPost>> getMySavedPosts({int page = 1}) async {
    final data = await ApiClient.instance.get(
      '/users/me/saved',
      query: {'page': '$page', 'limit': '12'},
    );
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeedPost>> getMyLikedPosts({int page = 1}) async {
    return _parseLiked(
      await ApiClient.instance.get(
        '/users/me/liked',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  Future<List<FeedPost>> getUserLikedPosts(String userId, {int page = 1}) async {
    return _parseLiked(
      await ApiClient.instance.get(
        '/users/$userId/liked',
        query: {'page': '$page', 'limit': '12'},
      ),
    );
  }

  List<FeedPost> _parseLiked(Map<String, dynamic> data) {
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<UserSearchResult>> searchUsers(String q) async {
    final data = await ApiClient.instance.get(
      '/users/search',
      query: {'q': q},
    );
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => UserSearchResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

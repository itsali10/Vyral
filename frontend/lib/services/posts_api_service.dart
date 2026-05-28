import '../models/feed_post.dart';
import '../models/picked_media.dart';
import 'api_client.dart';

class PostsApiService {
  PostsApiService._();
  static final PostsApiService instance = PostsApiService._();

  Future<List<FeedPost>> getFeedTab(String tab, {int page = 1, int limit = 20}) {
    return getFeed(tab: tab, page: page, limit: limit);
  }

  Future<List<FeedPost>> getFeed({
    required String tab,
    int page = 1,
    int limit = 20,
  }) async {
    final data = await ApiClient.instance.get(
      '/posts/feed',
      query: {'tab': tab, 'page': '$page', 'limit': '$limit'},
    );
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<FeedPost>> explore({
    String? q,
    String? category,
    int page = 1,
  }) async {
    final query = <String, String>{
      'page': '$page',
      'limit': '20',
    };
    if (q != null && q.isNotEmpty) query['q'] = q;
    if (category != null && category.isNotEmpty && category != 'All') {
      query['category'] = category.toLowerCase();
    }
    final data = await ApiClient.instance.get('/explore/posts', query: query);
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => FeedPost.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FeedPost> createPost({
    required String caption,
    PickedMedia? image,
    List<String>? hashtags,
    String? location,
  }) async {
    String? mediaUrl;
    if (image != null) {
      mediaUrl = await ApiClient.instance.uploadMedia(image);
    }
    final type = mediaUrl != null
        ? 'IMAGE'
        : (caption.isNotEmpty ? 'TEXT' : 'IMAGE');
    final data = await ApiClient.instance.post(
      '/posts',
      body: {
        'type': type,
        if (caption.isNotEmpty) 'caption': caption,
        if (mediaUrl != null) 'mediaUrls': [mediaUrl],
        if (hashtags != null && hashtags.isNotEmpty) 'hashtags': hashtags,
        if (location != null) 'location': location,
      },
    );
    return FeedPost.fromJson(data);
  }

  FeedPost _parsePost(Map<String, dynamic> data, FeedPost fallback) {
    return FeedPost.fromJson(data).mergeWith(fallback);
  }

  /// [liked] is the desired state from the UI toggle (not stale post.isLiked).
  Future<FeedPost> setLike(FeedPost post, {required bool liked}) async {
    final Map<String, dynamic> data;
    if (liked) {
      data = await ApiClient.instance.post('/posts/${post.id}/like');
    } else {
      data = await ApiClient.instance.delete('/posts/${post.id}/like');
    }
    return _parsePost(data, post);
  }

  Future<List<PostComment>> getComments(String postId) async {
    final data = await ApiClient.instance.get('/posts/$postId/comments');
    final items = data['items'] as List<dynamic>? ?? [];
    return items
        .map((e) => PostComment.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<FeedPost> addComment(FeedPost post, String text) async {
    final data = await ApiClient.instance.post(
      '/posts/${post.id}/comments',
      body: {'text': text.trim()},
    );
    return _parsePost(data, post);
  }

  Future<FeedPost> getPost(String id) async {
    final data = await ApiClient.instance.get('/posts/$id');
    return FeedPost.fromJson(data);
  }

  Future<FeedPost> updatePost(
    String id, {
    String? caption,
    String? location,
    List<String>? hashtags,
  }) async {
    final body = <String, dynamic>{};
    if (caption != null) body['caption'] = caption;
    if (location != null) body['location'] = location;
    if (hashtags != null) body['hashtags'] = hashtags;
    final data = await ApiClient.instance.patch('/posts/$id', body: body);
    return FeedPost.fromJson(data);
  }

  Future<void> deletePost(String id) async {
    await ApiClient.instance.delete('/posts/$id');
  }

  Future<FeedPost> setSaved(
    FeedPost post, {
    required bool saved,
    String? collectionId,
  }) async {
    final Map<String, dynamic> data;
    if (saved) {
      data = await ApiClient.instance.post(
        '/posts/${post.id}/save',
        query: collectionId != null ? {'collectionId': collectionId} : null,
      );
    } else {
      data = await ApiClient.instance.delete('/posts/${post.id}/save');
    }
    return _parsePost(data, post);
  }
}

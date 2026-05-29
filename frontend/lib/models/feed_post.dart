import '../utils/media_url.dart';

class FeedPost {
  const FeedPost({
    required this.id,
    this.authorId,
    this.authorAvatarUrl,
    required this.username,
    required this.timeAgo,
    required this.hasImage,
    required this.caption,
    required this.likesCount,
    required this.commentsCount,
    required this.mediaUrls,
    required this.isLiked,
    required this.isSaved,
    this.showLikesCount = true,
    this.isPinned = false,
  });

  final String id;
  final String? authorId;
  final String? authorAvatarUrl;

  /// Non-null author id for navigation (API may omit on older responses).
  String get authorIdSafe => authorId ?? '';
  final String username;
  final String timeAgo;
  final bool hasImage;
  final String? caption;
  final int likesCount;
  final int commentsCount;
  final List<String> mediaUrls;
  final bool isLiked;
  final bool isSaved;
  final bool showLikesCount;
  final bool isPinned;

  FeedPost copyWith({
    String? authorId,
    String? authorAvatarUrl,
    String? username,
    String? timeAgo,
    bool? hasImage,
    String? caption,
    int? likesCount,
    int? commentsCount,
    List<String>? mediaUrls,
    bool? isLiked,
    bool? isSaved,
    bool? showLikesCount,
    bool? isPinned,
  }) {
    return FeedPost(
      id: id,
      authorId: authorId ?? this.authorId,
      authorAvatarUrl: authorAvatarUrl ?? this.authorAvatarUrl,
      username: username ?? this.username,
      timeAgo: timeAgo ?? this.timeAgo,
      hasImage: hasImage ?? this.hasImage,
      caption: caption ?? this.caption,
      likesCount: likesCount ?? this.likesCount,
      commentsCount: commentsCount ?? this.commentsCount,
      mediaUrls: mediaUrls ?? this.mediaUrls,
      isLiked: isLiked ?? this.isLiked,
      isSaved: isSaved ?? this.isSaved,
      showLikesCount: showLikesCount ?? this.showLikesCount,
      isPinned: isPinned ?? this.isPinned,
    );
  }

  factory FeedPost.fromJson(Map<String, dynamic> json) {
    return FeedPost(
      id: _string(json['id']),
      authorId: _optionalString(json['authorId']),
      authorAvatarUrl: resolveMediaUrl(_optionalString(json['authorAvatarUrl'])),
      username: _string(json['username'], fallback: '@unknown'),
      timeAgo: _string(json['timeAgo']),
      hasImage: json['hasImage'] as bool? ?? false,
      caption: _optionalString(json['caption']),
      likesCount: _nonNegativeInt(json['likesCount']),
      commentsCount: _nonNegativeInt(json['commentsCount']),
      mediaUrls: _parseMediaUrls(json['mediaUrls']),
      isLiked: json['isLiked'] as bool? ?? false,
      isSaved: json['isSaved'] as bool? ?? false,
      showLikesCount: json['showLikesCount'] as bool? ?? true,
      isPinned: json['isPinned'] as bool? ?? false,
    );
  }

  /// Keep author/display fields when like/save responses omit them.
  FeedPost mergeWith(FeedPost previous) {
    return copyWith(
      authorId: authorIdSafe.isNotEmpty ? authorIdSafe : previous.authorId,
      authorAvatarUrl: authorAvatarUrl ?? previous.authorAvatarUrl,
      username: username != '@unknown' ? username : previous.username,
      timeAgo: timeAgo.isNotEmpty ? timeAgo : previous.timeAgo,
      isPinned: isPinned,
    );
  }

  static String _string(dynamic value, {String fallback = ''}) {
    if (value == null) return fallback;
    if (value is String) return value;
    return value.toString();
  }

  static String? _optionalString(dynamic value) {
    if (value == null) return null;
    if (value is String) return value.isEmpty ? null : value;
    final s = value.toString();
    return s.isEmpty ? null : s;
  }

  static List<String> _parseMediaUrls(dynamic raw) {
    if (raw is! List) return [];
    final urls = <String>[];
    for (final e in raw) {
      if (e == null) continue;
      final resolved = resolveMediaUrl(e.toString());
      if (resolved != null && resolved.isNotEmpty) {
        urls.add(resolved);
      }
    }
    return urls;
  }

  String get likesLabel =>
      showLikesCount ? formatCount(likesCount) : '—';
  String get commentsLabel => formatCount(commentsCount);

  static int _nonNegativeInt(dynamic value) {
    final n = (value as num?)?.toInt() ?? 0;
    return n < 0 ? 0 : n;
  }

  static String formatCount(int n) {
    final safe = n < 0 ? 0 : n;
    if (safe >= 1000000) return '${(safe / 1000000).toStringAsFixed(1)}M';
    if (safe >= 1000) return '${(safe / 1000).toStringAsFixed(1)}k';
    return '$safe';
  }
}

class PostComment {
  const PostComment({
    required this.id,
    required this.text,
    required this.username,
    this.avatarUrl,
    this.createdAt,
  });

  final String id;
  final String text;
  final String username;
  final String? avatarUrl;
  final DateTime? createdAt;

  factory PostComment.fromJson(Map<String, dynamic> json) {
    final authorRaw = json['author'];
    final author = authorRaw is Map
        ? Map<String, dynamic>.from(authorRaw)
        : null;
    final rawUsername = author?['username'] ?? json['username'];
    return PostComment(
      id: json['id']?.toString() ?? '',
      text: json['text']?.toString() ?? '',
      username: rawUsername != null ? rawUsername.toString() : '@unknown',
      avatarUrl: author?['avatarUrl']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
}

class UserProfile {
  const UserProfile({
    required this.id,
    required this.username,
    required this.displayUsername,
    required this.fullName,
    this.bio,
    this.avatarUrl,
    required this.postsCount,
    required this.followersCount,
    required this.followingCount,
    this.isPrivate = false,
    this.isFollowing = false,
    this.email,
  });

  final String id;
  final String username;
  final String displayUsername;
  final String fullName;
  final String? bio;
  final String? avatarUrl;
  final int postsCount;
  final int followersCount;
  final int followingCount;
  final bool isPrivate;
  final bool isFollowing;
  final String? email;

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      id: FeedPost._string(json['id']),
      username: FeedPost._string(json['username'], fallback: 'unknown'),
      displayUsername: FeedPost._string(
        json['displayUsername'],
        fallback: '@${FeedPost._string(json['username'], fallback: 'unknown')}',
      ),
      fullName: FeedPost._string(json['fullName']),
      bio: FeedPost._optionalString(json['bio']),
      avatarUrl: resolveMediaUrl(
        FeedPost._optionalString(json['avatarUrl']),
      ),
      postsCount: (json['postsCount'] as num?)?.toInt() ?? 0,
      followersCount: (json['followersCount'] as num?)?.toInt() ?? 0,
      followingCount: (json['followingCount'] as num?)?.toInt() ?? 0,
      isPrivate: json['isPrivate'] as bool? ?? false,
      isFollowing: json['isFollowing'] as bool? ?? false,
      email: FeedPost._optionalString(json['email']),
    );
  }

  String get postsLabel => _formatCount(postsCount);
  String get followersLabel => _formatCount(followersCount);
  String get followingLabel => _formatCount(followingCount);

  static String _formatCount(int n) {
    if (n >= 1000000) return '${(n / 1000000).toStringAsFixed(1)}M';
    if (n >= 1000) return '${(n / 1000).toStringAsFixed(1)}k';
    return '$n';
  }
}

class SavedCollectionModel {
  const SavedCollectionModel({
    required this.id,
    required this.name,
    required this.postCount,
  });

  final String id;
  final String name;
  final String postCount;

  factory SavedCollectionModel.fromJson(Map<String, dynamic> json) {
    return SavedCollectionModel(
      id: json['id'] as String,
      name: json['name'] as String,
      postCount: json['postCount']?.toString() ?? '0',
    );
  }
}

class ExploreItem {
  const ExploreItem({
    required this.id,
    required this.label,
    required this.username,
    this.mediaUrl,
  });

  final String id;
  final String label;
  final String username;
  final String? mediaUrl;

  factory ExploreItem.fromFeedPost(FeedPost post) {
    String label = 'post';
    final caption = post.caption;
    if (caption != null) {
      final match = RegExp(r'#(\w+)').firstMatch(caption);
      if (match != null) label = match.group(1)!;
    }
    return ExploreItem(
      id: post.id,
      label: label,
      username: post.username,
      mediaUrl: post.mediaUrls.isNotEmpty ? post.mediaUrls.first : null,
    );
  }
}

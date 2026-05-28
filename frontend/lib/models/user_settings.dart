class UserSettings {
  const UserSettings({
    this.showLikesPublicly = true,
    this.notifLikes = true,
    this.notifComments = true,
    this.notifFollowers = true,
    this.notifTrending = false,
    this.dataSaver = false,
    this.hapticsEnabled = true,
    this.exploreGridCompact = false,
    this.accentColor = 'rose',
    this.defaultFeedTab = 'for_you',
    this.mutedWords = const [],
  });

  final bool showLikesPublicly;
  final bool notifLikes;
  final bool notifComments;
  final bool notifFollowers;
  final bool notifTrending;
  final bool dataSaver;
  final bool hapticsEnabled;
  final bool exploreGridCompact;
  final String accentColor;
  final String defaultFeedTab;
  final List<String> mutedWords;

  UserSettings copyWith({
    bool? showLikesPublicly,
    bool? notifLikes,
    bool? notifComments,
    bool? notifFollowers,
    bool? notifTrending,
    bool? dataSaver,
    bool? hapticsEnabled,
    bool? exploreGridCompact,
    String? accentColor,
    String? defaultFeedTab,
    List<String>? mutedWords,
  }) {
    return UserSettings(
      showLikesPublicly: showLikesPublicly ?? this.showLikesPublicly,
      notifLikes: notifLikes ?? this.notifLikes,
      notifComments: notifComments ?? this.notifComments,
      notifFollowers: notifFollowers ?? this.notifFollowers,
      notifTrending: notifTrending ?? this.notifTrending,
      dataSaver: dataSaver ?? this.dataSaver,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      exploreGridCompact: exploreGridCompact ?? this.exploreGridCompact,
      accentColor: accentColor ?? this.accentColor,
      defaultFeedTab: defaultFeedTab ?? this.defaultFeedTab,
      mutedWords: mutedWords ?? this.mutedWords,
    );
  }

  factory UserSettings.fromJson(Map<String, dynamic> json) {
    final words = json['mutedWords'];
    return UserSettings(
      showLikesPublicly: json['showLikesPublicly'] as bool? ?? true,
      notifLikes: json['notifLikes'] as bool? ?? true,
      notifComments: json['notifComments'] as bool? ?? true,
      notifFollowers: json['notifFollowers'] as bool? ?? true,
      notifTrending: json['notifTrending'] as bool? ?? false,
      dataSaver: json['dataSaver'] as bool? ?? false,
      hapticsEnabled: json['hapticsEnabled'] as bool? ?? true,
      exploreGridCompact: json['exploreGridCompact'] as bool? ?? false,
      accentColor: json['accentColor'] as String? ?? 'rose',
      defaultFeedTab: json['defaultFeedTab'] as String? ?? 'for_you',
      mutedWords: words is List
          ? words.map((e) => '$e'.trim().toLowerCase()).where((e) => e.isNotEmpty).toList()
          : const [],
    );
  }

  Map<String, dynamic> toPatchJson() => {
        'showLikesPublicly': showLikesPublicly,
        'notifLikes': notifLikes,
        'notifComments': notifComments,
        'notifFollowers': notifFollowers,
        'notifTrending': notifTrending,
        'dataSaver': dataSaver,
        'hapticsEnabled': hapticsEnabled,
        'exploreGridCompact': exploreGridCompact,
        'accentColor': accentColor,
        'defaultFeedTab': defaultFeedTab,
        'mutedWords': mutedWords,
      };
}

class BlockedUserSummary {
  const BlockedUserSummary({
    required this.id,
    required this.username,
    required this.displayUsername,
    required this.fullName,
    this.avatarUrl,
  });

  final String id;
  final String username;
  final String displayUsername;
  final String fullName;
  final String? avatarUrl;

  factory BlockedUserSummary.fromJson(Map<String, dynamic> json) {
    return BlockedUserSummary(
      id: '${json['id']}',
      username: '${json['username']}',
      displayUsername: json['displayUsername'] as String? ?? '@${json['username']}',
      fullName: '${json['fullName']}',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

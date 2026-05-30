class UserSearchResult {
  const UserSearchResult({
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

  factory UserSearchResult.fromJson(Map<String, dynamic> json) {
    return UserSearchResult(
      id: json['id'] as String,
      username: json['username'] as String? ?? '',
      displayUsername: json['displayUsername'] as String? ?? '',
      fullName: json['fullName'] as String? ?? '',
      avatarUrl: json['avatarUrl'] as String?,
    );
  }
}

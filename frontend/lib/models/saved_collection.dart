class SavedCollection {
  const SavedCollection({
    required this.name,
    required this.postCount,
  });

  final String name;
  /// Numeric portion shown before the word "posts" (e.g. "12").
  final String postCount;
}

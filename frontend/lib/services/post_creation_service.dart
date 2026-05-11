import 'dart:io';

/// Stub for future backend / storage integration.
class PostCreationService {
  PostCreationService._();
  static final PostCreationService instance = PostCreationService._();

  Future<void> submitPost({
    required String caption,
    File? image,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 300));
  }
}

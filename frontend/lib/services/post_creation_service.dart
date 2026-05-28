import '../models/picked_media.dart';
import 'posts_api_service.dart';

class PostCreationService {
  PostCreationService._();
  static final PostCreationService instance = PostCreationService._();

  Future<void> submitPost({
    required String caption,
    PickedMedia? image,
    List<String>? hashtags,
    String? location,
  }) async {
    await PostsApiService.instance.createPost(
      caption: caption,
      image: image,
      hashtags: hashtags,
      location: location,
    );
  }
}

import 'package:flutter/material.dart';

import '../models/picked_media.dart';
import 'picked_image_preview_io.dart'
    if (dart.library.html) 'picked_image_preview_web.dart' as preview;

class PickedImagePreview extends StatelessWidget {
  const PickedImagePreview({
    super.key,
    required this.media,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
  });

  final PickedMedia media;
  final BoxFit fit;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return preview.buildPickedImagePreview(
      media,
      fit: fit,
      width: width,
      height: height,
    );
  }
}

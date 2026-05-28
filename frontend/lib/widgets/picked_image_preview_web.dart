import 'package:flutter/material.dart';

import '../models/picked_media.dart';

Widget buildPickedImagePreview(
  PickedMedia media, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  final bytes = media.bytes;
  if (bytes == null) return const SizedBox.shrink();
  return Image.memory(
    bytes,
    fit: fit,
    width: width,
    height: height,
  );
}

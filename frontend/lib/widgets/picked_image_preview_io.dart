import 'dart:io';

import 'package:flutter/material.dart';

import '../models/picked_media.dart';

Widget buildPickedImagePreview(
  PickedMedia media, {
  BoxFit fit = BoxFit.cover,
  double? width,
  double? height,
}) {
  final path = media.path;
  if (path == null) return const SizedBox.shrink();
  return Image.file(
    File(path),
    fit: fit,
    width: width,
    height: height,
    cacheWidth: 1200,
    filterQuality: FilterQuality.medium,
  );
}

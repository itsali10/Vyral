import 'dart:typed_data';

/// Local image chosen for upload (path on IO platforms, bytes on web).
class PickedMedia {
  const PickedMedia({
    required this.name,
    this.path,
    this.bytes,
  }) : assert(path != null || bytes != null);

  final String name;
  final String? path;
  final Uint8List? bytes;
}

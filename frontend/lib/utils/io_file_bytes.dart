import 'dart:io';
import 'dart:typed_data';

/// Reads a local file path into bytes (IO platforms only).
Future<Uint8List> readPathBytes(String path) async {
  final file = File(path);
  if (!await file.exists()) {
    throw StateError(
      'Image file not found. Pick the photo again from the gallery.',
    );
  }
  final bytes = await file.readAsBytes();
  if (bytes.isEmpty) {
    throw StateError('Image file is empty. Try another photo.');
  }
  return bytes;
}

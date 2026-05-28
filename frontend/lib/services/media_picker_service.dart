import 'package:file_selector/file_selector.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

import '../models/picked_media.dart';

/// Picks images from the laptop/PC on Windows, macOS, Linux, and web.
/// On Android/iOS uses the device gallery.
class MediaPickerService {
  MediaPickerService._();
  static final MediaPickerService instance = MediaPickerService._();

  final _picker = ImagePicker();
  bool _pickerOpen = false;

  static const _imageTypes = XTypeGroup(
    label: 'Images',
    extensions: ['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'],
  );

  static bool get picksFromComputer =>
      kIsWeb ||
      defaultTargetPlatform == TargetPlatform.windows ||
      defaultTargetPlatform == TargetPlatform.linux ||
      defaultTargetPlatform == TargetPlatform.macOS;

  Future<PickedMedia?> pickImage() async {
    if (_pickerOpen) return null;
    _pickerOpen = true;
    try {
      if (picksFromComputer) {
        return await _pickFromComputer();
      }
      return await _pickFromGallery();
    } on PlatformException catch (e) {
      if (e.code == 'already_active') return null;
      rethrow;
    } finally {
      _pickerOpen = false;
    }
  }

  Future<PickedMedia?> _pickFromComputer() async {
    final xFile = await openFile(acceptedTypeGroups: [_imageTypes]);
    if (xFile == null) return null;

    final name = xFile.name.isNotEmpty ? xFile.name : 'image.jpg';
    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      return PickedMedia(name: name, bytes: bytes);
    }
    final path = xFile.path;
    if (path.isNotEmpty) {
      return PickedMedia(name: name, path: path);
    }
    final bytes = await xFile.readAsBytes();
    return PickedMedia(name: name, bytes: bytes);
  }

  Future<PickedMedia?> _pickFromGallery() async {
    final xFile = await _picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 1920,
      maxHeight: 1920,
      imageQuality: 85,
    );
    if (xFile == null) return null;

    final name = xFile.name.isNotEmpty ? xFile.name : 'image.jpg';
    if (kIsWeb) {
      final bytes = await xFile.readAsBytes();
      return PickedMedia(name: name, bytes: bytes);
    }
    final path = xFile.path;
    if (path.isNotEmpty) {
      return PickedMedia(name: name, path: path);
    }
    final bytes = await xFile.readAsBytes();
    return PickedMedia(name: name, bytes: bytes);
  }
}

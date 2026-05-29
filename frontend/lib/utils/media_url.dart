import 'package:flutter/foundation.dart';

/// Rewrites localhost media URLs for Android emulator; safe on web and desktop.
String? resolveMediaUrl(String? url) {
  if (url == null || url.isEmpty) return null;
  if (!kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      (url.contains('://localhost') || url.startsWith('http://127.0.0.1'))) {
    return url
        .replaceFirst('://localhost', '://10.0.2.2')
        .replaceFirst('://127.0.0.1', '://10.0.2.2');
  }
  return url;
}

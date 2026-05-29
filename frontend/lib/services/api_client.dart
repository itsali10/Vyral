import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../utils/io_file_bytes_stub.dart'
    if (dart.library.io) '../utils/io_file_bytes.dart' as io_file;

import '../config/api_config.dart';
import '../models/picked_media.dart';
import 'auth_service.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});
  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient._();
  static final ApiClient instance = ApiClient._();

  static const _requestTimeout = Duration(seconds: 12);
  static const _uploadTimeout = Duration(seconds: 90);

  String get _base => ApiConfig.baseUrl;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on TimeoutException {
      throw ApiException(
        'Connection timed out. Make sure the backend is running.',
      );
    } on http.ClientException catch (e) {
      throw ApiException(
        e.message.contains('Connection refused')
            ? 'Cannot connect to the server. Start the backend with npm run start:dev.'
            : 'Network error: ${e.message}',
      );
    }
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, String>? query,
    bool auth = true,
  }) async {
    return _guard(() async {
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      final res = await http
          .get(uri, headers: await _headers(auth))
          .timeout(_requestTimeout);
      return _decode(res);
    });
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? query,
    bool auth = true,
  }) async {
    return _guard(() async {
      final uri = Uri.parse('$_base$path').replace(queryParameters: query);
      final res = await http
          .post(
            uri,
            headers: await _headers(auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout);
      return _decode(res);
    });
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? body,
    bool auth = true,
  }) async {
    return _guard(() async {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .patch(
            uri,
            headers: await _headers(auth),
            body: body != null ? jsonEncode(body) : null,
          )
          .timeout(_requestTimeout);
      return _decode(res);
    });
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    bool auth = true,
  }) async {
    return _guard(() async {
      final uri = Uri.parse('$_base$path');
      final res = await http
          .delete(uri, headers: await _headers(auth))
          .timeout(_requestTimeout);
      return _decode(res);
    });
  }

  Future<String> uploadMedia(PickedMedia media) async {
    return _guard(() async {
      final uri = Uri.parse('$_base/upload');
      final request = http.MultipartRequest('POST', uri);
      final token = AuthService.instance.accessToken;
      if (token == null || token.isEmpty) {
        throw ApiException('Please log in again to upload photos.', statusCode: 401);
      }
      request.headers['Authorization'] = 'Bearer $token';

      final bytes = await _readMediaBytes(media);
      final filename = _safeUploadFilename(media.name);
      request.files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: filename,
        ),
      );

      final streamed = await request.send().timeout(_uploadTimeout);
      final res =
          await http.Response.fromStream(streamed).timeout(_uploadTimeout);
      final data = _decode(res);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw ApiException(
          'Upload failed. The server did not receive your image.',
          statusCode: res.statusCode,
        );
      }
      return url;
    });
  }

  Future<Uint8List> _readMediaBytes(PickedMedia media) async {
    if (media.bytes != null && media.bytes!.isNotEmpty) {
      return media.bytes!;
    }
    if (!kIsWeb && media.path != null && media.path!.isNotEmpty) {
      try {
        final bytes = await io_file.readPathBytes(media.path!);
        return Uint8List.fromList(bytes);
      } on StateError catch (e) {
        throw ApiException(e.message);
      } catch (e) {
        throw ApiException('Could not read image: $e');
      }
    }
    throw ApiException('No image data to upload');
  }

  String _safeUploadFilename(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'upload.jpg';
    if (trimmed.contains('.') && !trimmed.endsWith('.')) return trimmed;
    return '$trimmed.jpg';
  }

  Future<Map<String, String>> _headers(bool auth) async {
    final headers = <String, String>{'Content-Type': 'application/json'};
    if (auth) {
      final token = AuthService.instance.accessToken;
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }
    return headers;
  }

  Map<String, dynamic> _decode(http.Response res) {
    Map<String, dynamic>? body;
    if (res.body.isNotEmpty) {
      final decoded = jsonDecode(res.body);
      if (decoded is Map<String, dynamic>) body = decoded;
      if (decoded is Map) body = Map<String, dynamic>.from(decoded);
    }
    if (res.statusCode >= 200 && res.statusCode < 300) {
      return body ?? {};
    }
    final message = body?['message'];
    final msg = message is List
        ? message.join(', ')
        : (message?.toString() ?? 'Request failed (${res.statusCode})');
    throw ApiException(msg, statusCode: res.statusCode);
  }
}

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

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

  String get _base => ApiConfig.baseUrl;

  Future<T> _guard<T>(Future<T> Function() action) async {
    try {
      return await action();
    } on TimeoutException {
      throw ApiException(
        'Connection timed out. Make sure the backend is running.',
      );
    } on SocketException {
      throw ApiException(
        'Cannot connect to the server. Start the backend with npm run start:dev.',
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
      if (token != null) {
        request.headers['Authorization'] = 'Bearer $token';
      }
      if (media.bytes != null) {
        request.files.add(
          http.MultipartFile.fromBytes(
            'file',
            media.bytes!,
            filename: media.name,
          ),
        );
      } else if (media.path != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'file',
            media.path!,
            filename: media.name,
          ),
        );
      } else {
        throw ApiException('No file data to upload');
      }
      final streamed = await request.send().timeout(_requestTimeout);
      final res =
          await http.Response.fromStream(streamed).timeout(_requestTimeout);
      final data = _decode(res);
      final url = data['url'] as String?;
      if (url == null || url.isEmpty) {
        throw ApiException('Upload failed');
      }
      return url;
    });
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

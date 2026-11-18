import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'token_storage.dart';

class ApiException implements Exception {
  ApiException(this.message, {this.statusCode});

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

/// HTTP client dùng chung: tự gắn "Authorization: Bearer token ",
/// chuyển mọi lỗi thành [ApiException] có thông báo tiếng Việt.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();

  /// Được gọi khi server trả 401 trong lúc đã có token (token hết hạn).
  Future<void> Function()? onUnauthorized;
  bool _handlingUnauthorized = false;

  Future<dynamic> get(String path) => _send('GET', path);

  Future<dynamic> post(String path, Map<String, dynamic> body) =>
      _send('POST', path, body: body);

  Future<dynamic> put(String path, Map<String, dynamic> body) =>
      _send('PUT', path, body: body);

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('${AppConfig.baseUrl}$path');
    final token = await TokenStorage.read();
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
      if (token != null && token.isNotEmpty) 'Authorization': 'Bearer $token',
    };
    final payload = body == null ? null : jsonEncode(body);

    final http.Response res;
    try {
      final request = switch (method) {
        'POST' => _http.post(uri, headers: headers, body: payload),
        'PUT' => _http.put(uri, headers: headers, body: payload),
        'DELETE' => _http.delete(uri, headers: headers),
        _ => _http.get(uri, headers: headers),
      };
      res = await request.timeout(AppConfig.timeout);
    } on TimeoutException {
      throw ApiException(
        'Máy chủ phản hồi quá lâu (Render gói Free có thể đang khởi động). '
        'Hãy thử lại sau ít giây.',
      );
    } on http.ClientException {
      throw ApiException('Không kết nối được máy chủ. Kiểm tra mạng và thử lại.');
    }

    dynamic data;
    if (res.bodyBytes.isNotEmpty) {
      try {
        data = jsonDecode(utf8.decode(res.bodyBytes));
      } on FormatException {
        data = null;
      }
    }

    if (res.statusCode == 401 && token != null && token.isNotEmpty) {
      await _expireSession();
      throw ApiException('Phiên đăng nhập đã hết hạn.', statusCode: 401);
    }
    if (res.statusCode >= 400) {
      throw ApiException(
        _messageOf(data) ?? 'Lỗi máy chủ (${res.statusCode})',
        statusCode: res.statusCode,
      );
    }
    return data;
  }

  Future<void> _expireSession() async {
    if (_handlingUnauthorized) return;
    _handlingUnauthorized = true;
    try {
      await onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  String? _messageOf(dynamic data) {
    if (data is Map) {
      final m = data['message'] ?? data['error'];
      if (m != null) return m.toString();
    }
    return null;
  }
}

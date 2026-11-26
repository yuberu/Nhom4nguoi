
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

/// HTTP client dùng chung.
/// Tự động gửi JWT Token và xử lý lỗi bằng tiếng Việt.
class ApiClient {
  ApiClient._();

  static final ApiClient instance = ApiClient._();

  final http.Client _http = http.Client();

  /// Được gọi khi server trả 401 và người dùng đã có token.
  Future<void> Function()? onUnauthorized;

  bool _handlingUnauthorized = false;

  // =========================
  // CÁC PHƯƠNG THỨC HTTP
  // =========================

  Future<dynamic> get(String path) {
    return _send('GET', path);
  }

  Future<dynamic> post(
    String path,
    Map<String, dynamic> body,
  ) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(
    String path,
    Map<String, dynamic> body,
  ) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) {
    return _send('DELETE', path);
  }

  // =========================
  // XỬ LÝ REQUEST
  // =========================

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
      if (token != null && token.isNotEmpty)
        'Authorization': 'Bearer $token',
    };

    final payload = body == null ? null : jsonEncode(body);

    final http.Response response;

    try {
      final request = switch (method) {
        'POST' => _http.post(
            uri,
            headers: headers,
            body: payload,
          ),
        'PUT' => _http.put(
            uri,
            headers: headers,
            body: payload,
          ),
        'DELETE' => _http.delete(
            uri,
            headers: headers,
          ),
        _ => _http.get(
            uri,
            headers: headers,
          ),
      };

      response = await request.timeout(AppConfig.timeout);

    } on TimeoutException {
      throw ApiException(
        'Máy chủ phản hồi quá lâu. Vui lòng thử lại sau.',
      );

    } on http.ClientException {
      throw ApiException(
        'Không thể kết nối máy chủ. Hãy kiểm tra kết nối mạng.',
      );
    } catch (e) {
      if (e is ApiException) rethrow;

      throw ApiException(
        'Đã xảy ra lỗi khi kết nối máy chủ: $e',
      );
    }

    // =========================
    // ĐỌC DỮ LIỆU JSON
    // =========================

    dynamic data;

    if (response.bodyBytes.isNotEmpty) {
      try {
        data = jsonDecode(
          utf8.decode(response.bodyBytes),
        );
      } on FormatException {
        data = null;
      }
    }

    // =========================
    // XỬ LÝ LỖI ĐĂNG NHẬP
    // =========================

    if (response.statusCode == 401 &&
        token != null &&
        token.isNotEmpty) {
      await _expireSession();

      throw ApiException(
        _messageOf(data) ??
            'Phiên đăng nhập đã hết hạn. Vui lòng đăng nhập lại.',
        statusCode: 401,
      );
    }

    // =========================
    // XỬ LÝ CÁC MÃ LỖI HTTP
    // =========================

    if (response.statusCode >= 400) {
      throw ApiException(
        _messageOf(data) ??
            _defaultErrorMessage(response.statusCode),
        statusCode: response.statusCode,
      );
    }

    return data;
  }

  // =========================
  // XỬ LÝ PHIÊN ĐĂNG NHẬP
  // =========================

  Future<void> _expireSession() async {
    if (_handlingUnauthorized) return;

    _handlingUnauthorized = true;

    try {
      await onUnauthorized?.call();
    } finally {
      _handlingUnauthorized = false;
    }
  }

  // =========================
  // LẤY THÔNG BÁO TỪ BACKEND
  // =========================

  String? _messageOf(dynamic data) {
    if (data is Map) {
      final message = data['loi'] ??
          data['thong_bao'] ??
          data['message'] ??
          data['error'];

      if (message != null &&
          message.toString().trim().isNotEmpty) {
        return message.toString();
      }
    }

    return null;
  }

  // =========================
  // THÔNG BÁO LỖI MẶC ĐỊNH
  // =========================

  String _defaultErrorMessage(int statusCode) {
    switch (statusCode) {
      case 400:
        return 'Dữ liệu gửi lên không hợp lệ.';

      case 401:
        return 'Bạn chưa đăng nhập hoặc phiên đăng nhập đã hết hạn.';

      case 403:
        return 'Bạn không có quyền thực hiện thao tác này.';

      case 404:
        return 'Không tìm thấy dữ liệu hoặc đường dẫn yêu cầu.';

      case 409:
        return 'Dữ liệu bị trùng hoặc xảy ra xung đột.';

      case 422:
        return 'Thông tin gửi lên không thể xử lý.';

      case 429:
        return 'Bạn thao tác quá nhanh. Vui lòng thử lại sau.';

      case 500:
        return 'Máy chủ đang gặp lỗi. Vui lòng thử lại sau.';

      case 502:
      case 503:
      case 504:
        return 'Máy chủ tạm thời không khả dụng.';

      default:
        return 'Đã xảy ra lỗi ($statusCode). Vui lòng thử lại.';
    }
  }
}

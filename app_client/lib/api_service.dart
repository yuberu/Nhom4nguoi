import 'dart:convert';

import 'package:http/http.dart' as http;

import 'config.dart';
import 'models.dart';
import 'token_storage.dart';

/// Biến lỗi thành câu chữ dễ đọc để hiện cho người dùng.
String errorMessage(Object e) => e.toString().replaceFirst('Exception: ', '');

class ApiService {
  static const Duration _timeout = Duration(seconds: 15);
  static const Map<String, String> _jsonHeaders = {
    'Content-Type': 'application/json',
  };

  static Uri _uri(String path, [Map<String, String>? query]) {
    return Uri.parse('${AppConfig.baseUrl}$path').replace(queryParameters: query);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await TokenStorage.getToken();
    return {
      ..._jsonHeaders,
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  /// Kiểm tra mã trạng thái, ném lỗi nếu không thành công, trả về dữ liệu JSON.
  static dynamic _handle(http.Response res) {
    final dynamic data = res.body.isEmpty ? <String, dynamic>{} : jsonDecode(res.body);
    if (res.statusCode < 200 || res.statusCode >= 300) {
      final msg = (data is Map && data['message'] != null)
          ? data['message'].toString()
          : 'Lỗi máy chủ (${res.statusCode})';
      throw Exception(msg);
    }
    return data;
  }

  // ---------- Đăng nhập ----------
  static Future<void> login(String username, String password) async {
    final res = await http
        .post(
          _uri('/auth/login'),
          headers: _jsonHeaders,
          body: jsonEncode({
            'username': username,
            'password': password,
            'expiresInMins': 60,
          }),
        )
        .timeout(_timeout);
    final data = _handle(res) as Map<String, dynamic>;
    final name = '${data['firstName'] ?? ''} ${data['lastName'] ?? ''}'.trim();
    await TokenStorage.saveSession(
      token: data['accessToken'] as String,
      name: name.isEmpty ? username : name,
      image: (data['image'] ?? '') as String,
    );
  }

  static Future<void> logout() => TokenStorage.clear();

  static Future<AppUser> getMe() async {
    final res = await http
        .get(_uri('/auth/me'), headers: await _authHeaders())
        .timeout(_timeout);
    return AppUser.fromJson(_handle(res) as Map<String, dynamic>);
  }

  // ---------- Sản phẩm ----------
  static Future<List<Product>> fetchProducts() async {
    final res = await http
        .get(_uri('/products', {'limit': '30'}), headers: await _authHeaders())
        .timeout(_timeout);
    final data = _handle(res) as Map<String, dynamic>;
    final list = data['products'] as List<dynamic>;
    return list
        .map((e) => Product.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static Future<void> createProduct(Product p) async {
    final res = await http
        .post(
          _uri('/products/add'),
          headers: await _authHeaders(),
          body: jsonEncode(_productBody(p)),
        )
        .timeout(_timeout);
    _handle(res);
  }

  static Future<void> updateProduct(Product p) async {
    final res = await http
        .put(
          _uri('/products/${p.id}'),
          headers: await _authHeaders(),
          body: jsonEncode(_productBody(p)),
        )
        .timeout(_timeout);
    // Sản phẩm tự thêm ở máy (id lớn) không có trên server mẫu -> coi như OK.
    if (res.statusCode == 404) return;
    _handle(res);
  }

  static Future<void> deleteProduct(int id) async {
    final res = await http
        .delete(_uri('/products/$id'), headers: await _authHeaders())
        .timeout(_timeout);
    if (res.statusCode == 404) return;
    _handle(res);
  }

  static Map<String, dynamic> _productBody(Product p) => {
        'title': p.title,
        'description': p.description,
        'price': p.price,
        'category': p.category,
        'thumbnail': p.thumbnail,
      };

  // ---------- Người dùng ----------
  static Future<List<AppUser>> fetchUsers() async {
    final res = await http
        .get(_uri('/users', {'limit': '30'}), headers: await _authHeaders())
        .timeout(_timeout);
    final data = _handle(res) as Map<String, dynamic>;
    final list = data['users'] as List<dynamic>;
    return list
        .map((e) => AppUser.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

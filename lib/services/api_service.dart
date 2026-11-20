
import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Địa chỉ Backend
  static const String baseUrl = 'http://10.0.2.2:3000/api';

  // Hàm GET
  static Future<dynamic> get(String endpoint) async {
    try {
      final response = await http
          .get(Uri.parse('$baseUrl$endpoint'))
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối Backend: $e');
    }
  }

  // Hàm POST
  static Future<dynamic> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$endpoint'),
            headers: {
              'Content-Type': 'application/json',
            },
            body: jsonEncode(data),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode >= 200 &&
          response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Lỗi API: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Không thể kết nối Backend: $e');
    }
  }
}

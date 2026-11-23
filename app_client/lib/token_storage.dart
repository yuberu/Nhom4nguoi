import 'package:shared_preferences/shared_preferences.dart';

class TokenStorage {
  static const String _kToken = 'token';
  static const String _kName = 'name';
  static const String _kImage = 'image';

  static Future<void> saveSession({
    required String token,
    required String name,
    required String image,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_kToken, token);
    await prefs.setString(_kName, name);
    await prefs.setString(_kImage, image);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_kToken);
  }

  static Future<Map<String, String>> getProfile() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'name': prefs.getString(_kName) ?? '',
      'image': prefs.getString(_kImage) ?? '',
    };
  }

  static Future<void> clear() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_kToken);
    await prefs.remove(_kName);
    await prefs.remove(_kImage);
  }
}

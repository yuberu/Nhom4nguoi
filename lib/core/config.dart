
class AppConfig {
  AppConfig._();

  /// Địa chỉ Backend trên Android Emulator
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'http://10.0.2.2:3000/api',
  );

  /// Thời gian chờ kết nối
  static const Duration timeout = Duration(seconds: 60);
}

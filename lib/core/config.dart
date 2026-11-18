class AppConfig {
  AppConfig._();

  /// Đổi bằng: flutter run --dart-define=API_URL=https://ten-app.onrender.com/api
  static const String baseUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://your-app.onrender.com/api',
  );

  /// Render Free "ngủ" sau 15 phút, lần gọi đầu có thể mất ~30-50 giây.
  static const Duration timeout = Duration(seconds: 60);
}

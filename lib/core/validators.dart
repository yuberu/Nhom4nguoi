class Validators {
  Validators._();

  static String? notEmpty(String? value, String field) {
    if (value == null || value.trim().isEmpty) {
      return '$field không được để trống';
    }
    return null;
  }

  static String? email(String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) return 'Vui lòng nhập email';
    if (!RegExp(r'^[\w.+-]+@[\w-]+(\.[\w-]+)+$').hasMatch(s)) {
      return 'Email không hợp lệ';
    }
    return null;
  }

  static String? password(String? value) {
    if (value == null || value.isEmpty) return 'Vui lòng nhập mật khẩu';
    if (value.length < 6) return 'Mật khẩu tối thiểu 6 ký tự';
    return null;
  }

  static String? phone(String? value) {
    final s = value?.trim() ?? '';
    if (s.isEmpty) return 'Vui lòng nhập số điện thoại';
    if (!RegExp(r'^(0|\+84)\d{9}$').hasMatch(s)) {
      return 'Số điện thoại không hợp lệ (VD: 0912345678)';
    }
    return null;
  }

  /// Biển số VN: 29A-123.45, 59X1-123.45, 30E-12345, 51F-1234 ...
  static String? plate(String? value) {
    final s = (value ?? '').trim().toUpperCase();
    if (s.isEmpty) return 'Vui lòng nhập biển số';
    if (!RegExp(r'^\d{2}[A-Z]{1,2}\d?[- ]?(\d{3}\.\d{2}|\d{4,5})$')
        .hasMatch(s)) {
      return 'Biển số không hợp lệ (VD: 29A-123.45)';
    }
    return null;
  }

  static String? hours(String? value) {
    final n = int.tryParse((value ?? '').trim());
    if (n == null) return 'Nhập số giờ hợp lệ';
    if (n < 1 || n > 72) return 'Số giờ từ 1 đến 72';
    return null;
  }
}

/// 15000 -> "15.000đ"
String formatVnd(num value) {
  final digits = value.round().abs().toString();
  final buffer = StringBuffer();
  for (var i = 0; i < digits.length; i++) {
    if (i > 0 && (digits.length - i) % 3 == 0) buffer.write('.');
    buffer.write(digits[i]);
  }
  final sign = value < 0 ? '-' : '';
  return '$sign${buffer.toString()}đ';
}

/// "dd/MM/yyyy HH:mm" theo giờ máy.
String formatDateTime(DateTime date) {
  String two(int n) => n.toString().padLeft(2, '0');
  final d = date.toLocal();
  return '${two(d.day)}/${two(d.month)}/${d.year} ${two(d.hour)}:${two(d.minute)}';
}

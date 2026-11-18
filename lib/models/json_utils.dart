/// PostgreSQL (thư viện pg) trả NUMERIC dưới dạng chuỗi, nên các hàm này
/// chấp nhận cả số lẫn chuỗi.
int toInt(dynamic value, [int fallback = 0]) {
  if (value is int) return value;
  if (value is num) return value.toInt();
  return int.tryParse('$value') ?? fallback;
}

double toDouble(dynamic value, [double fallback = 0]) {
  if (value is num) return value.toDouble();
  return double.tryParse('$value') ?? fallback;
}

String? toStr(dynamic value) => value?.toString();

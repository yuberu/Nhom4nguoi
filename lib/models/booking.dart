import 'json_utils.dart';

class Booking {
  const Booking({
    required this.id,
    required this.lotName,
    required this.plate,
    required this.hours,
    required this.totalPrice,
    required this.status,
    this.createdAt,
  });

  final int id;
  final String lotName;
  final String plate;
  final int hours;
  final double totalPrice;

  /// 'active' | 'completed' | 'cancelled'
  final String status;
  final DateTime? createdAt;

  String get statusLabel => switch (status) {
        'active' => 'Đang giữ chỗ',
        'completed' => 'Hoàn thành',
        'cancelled' => 'Đã hủy',
        _ => status,
      };

  factory Booking.fromJson(Map<String, dynamic> json) => Booking(
        id: toInt(json['id']),
        lotName: toStr(json['lot_name']) ?? '',
        plate: toStr(json['plate']) ?? '',
        hours: toInt(json['hours']),
        totalPrice: toDouble(json['total_price']),
        status: toStr(json['status']) ?? 'active',
        createdAt: DateTime.tryParse(toStr(json['created_at']) ?? ''),
      );
}

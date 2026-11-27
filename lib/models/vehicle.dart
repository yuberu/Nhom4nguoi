
import 'json_utils.dart';

class Vehicle {
  const Vehicle({
    required this.id,
    required this.plate,
    required this.type,
    required this.brand,
    this.color,
  });

  static const String car = 'car';
  static const String motorbike = 'motorbike';

  final int id;
  final String plate;
  final String type;
  final String brand;
  final String? color;

  String get typeLabel => type == car ? 'Ô tô' : 'Xe máy';

  // Đọc dữ liệu JSON từ Backend
  factory Vehicle.fromJson(Map<String, dynamic> json) {
    final loaiXe = toStr(json['loai_xe']) ?? '';

    return Vehicle(
      id: toInt(json['id']),
      plate: toStr(json['bien_so_xe']) ?? '',
      type: loaiXe == car ? car : motorbike,
      brand: toStr(json['ten_xe']) ?? '',
      color: toStr(json['mau_xe']),
    );
  }

  // Chuyển dữ liệu Flutter thành JSON gửi Backend
  static Map<String, dynamic> toPayload({
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) {
    return {
      'bien_so_xe': plate,
      'ten_xe': brand,
      'loai_xe': type,
      'mau_xe': color,
    };
  }
}

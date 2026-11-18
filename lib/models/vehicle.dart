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

  /// 'car' hoặc 'motorbike'
  final String type;
  final String brand;
  final String? color;

  String get typeLabel => type == car ? 'Ô tô' : 'Xe máy';

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: toInt(json['id']),
        plate: toStr(json['plate']) ?? '',
        type: toStr(json['type']) == car ? car : motorbike,
        brand: toStr(json['brand']) ?? '',
        color: toStr(json['color']),
      );

  static Map<String, dynamic> toPayload({
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) =>
      {
        'plate': plate,
        'type': type,
        'brand': brand,
        'color': color,
      };
}

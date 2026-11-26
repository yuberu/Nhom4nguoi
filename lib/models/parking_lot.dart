
import 'json_utils.dart';

class ParkingLot {
  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.createdAt,
  });

  final int id;
  final String name;
  final String address;
  final double latitude;
  final double longitude;
  final DateTime? createdAt;

  factory ParkingLot.fromJson(Map<String, dynamic> json) {
    return ParkingLot(
      id: toInt(json['id']),
      name: toStr(json['ten']) ?? '',
      address: toStr(json['dia_chi']) ?? '',
      latitude: toDouble(json['vi_do']),
      longitude: toDouble(json['kinh_do']),
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'].toString()),
    );
  }
}

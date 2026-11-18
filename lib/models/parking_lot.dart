import 'json_utils.dart';

class ParkingLot {
  const ParkingLot({
    required this.id,
    required this.name,
    required this.address,
    required this.totalSlots,
    required this.availableSlots,
    required this.pricePerHour,
    this.imageUrl,
    this.description,
  });

  final int id;
  final String name;
  final String address;
  final int totalSlots;
  final int availableSlots;
  final double pricePerHour;
  final String? imageUrl;
  final String? description;

  bool get isFull => availableSlots <= 0;

  factory ParkingLot.fromJson(Map<String, dynamic> json) => ParkingLot(
        id: toInt(json['id']),
        name: toStr(json['name']) ?? '',
        address: toStr(json['address']) ?? '',
        totalSlots: toInt(json['total_slots']),
        availableSlots: toInt(json['available_slots']),
        pricePerHour: toDouble(json['price_per_hour']),
        imageUrl: toStr(json['image_url']),
        description: toStr(json['description']),
      );
}

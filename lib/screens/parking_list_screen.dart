
import 'package:flutter/material.dart';

class ParkingListScreen extends StatelessWidget {
  const ParkingListScreen({super.key});

  final List<String> parkingList = const [
    'Bãi xe Quận 1',
    'Bãi xe Tân Bình',
    'Bãi xe Tân Phú',
    'Bãi xe Thủ Đức'
    'Bãi xe Bình Thạnh'
    'Bãi xe Gò Vấp'
    'Bãi xe Phú Nhuận'
    'Bãi xe Bình Tân'
    'Bãi xe Củ Chi'
    'Bãi xe Hóc Môn'
    'Bãi xe Nhà Bè'
    'Bãi xe Cần Giờ'
    'Bãi xe Bình Chánh'
    'Bãi xe Quận 2'
    'Bãi xe Quận 3'
    'Bãi xe Quận 4'
    'Bãi xe Quận 5'
    'Bãi xe Quận 6'
    'Bãi xe Quận 7'
    'Bãi xe Quận 8'
    'Bãi xe Quận 9'
    'Bãi xe Quận 10'
    'Bãi xe Quận 11'
    'Bãi xe Quận 12'

    ,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bãi xe'),
      ),
      body: ListView.builder(
        itemCount: parkingList.length,
        itemBuilder: (context, index) {
          final parking = parkingList[index];

          return Card(
            margin: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 6,
            ),
            child: ListTile(
              leading: const Icon(
                Icons.local_parking,
                color: Colors.blue,
              ),
              title: Text(parking),
              subtitle: const Text('Còn chỗ trống'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.pop(context, parking);
              },
            ),
          );
        },
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'parking_list_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String selectedParking = 'Chưa chọn bãi xe';

  Future<void> _openParkingList() async {
    final result = await Navigator.push<String>(
      context,
      MaterialPageRoute(
        builder: (context) => const ParkingListScreen(),
      ),
    );

    // Kiem tra man hinh con ton tai khong sau await
    if (!mounted) return;

    if (result != null) {
      setState(() {
        selectedParking = result;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Smart Parking'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(
              Icons.local_parking,
              size: 80,
              color: Colors.blue,
            ),

            const Text(
              'Xin chao!',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    const Text('Bãi xe bạn đã chọn:'),
                    const SizedBox(height: 8),
                    Text(
                      selectedParking,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            ElevatedButton.icon(
              onPressed: _openParkingList,
              icon: const Icon(Icons.local_parking),
              label: const Text('Xem danh sách bãi xe'),
            ),
          ],
        ),
      ),
    );
  }
}

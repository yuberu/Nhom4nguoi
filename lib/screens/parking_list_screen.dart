
import 'package:flutter/material.dart';

import '../services/parking_service.dart';
import '../models/parking_lot.dart';

class ParkingListScreen extends StatefulWidget {
  const ParkingListScreen({super.key});

  @override
  State<ParkingListScreen> createState() =>
      _ParkingListScreenState();
}

class _ParkingListScreenState
    extends State<ParkingListScreen> {
  final ParkingService _service = ParkingService();

  final TextEditingController _searchController =
      TextEditingController();

  late Future<List<ParkingLot>> _lotsFuture;

  String _keyword = '';

  @override
  void initState() {
    super.initState();
    _lotsFuture = _service.getLots();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _reload() async {
    setState(() {
      _lotsFuture = _service.getLots();
    });
  }

  List<ParkingLot> _filterLots(List<ParkingLot> lots) {
    final keyword = _keyword.trim().toLowerCase();

    if (keyword.isEmpty) return lots;

    return lots.where((parking) {
      return parking.name.toLowerCase().contains(keyword) ||
          parking.address.toLowerCase().contains(keyword);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Danh sách bãi xe'),
        actions: [
          IconButton(
            onPressed: _reload,
            icon: const Icon(Icons.refresh),
            tooltip: 'Làm mới',
          ),
        ],
      ),
      body: FutureBuilder<List<ParkingLot>>(
        future: _lotsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Lỗi: ${snapshot.error}'),
                  ElevatedButton(
                    onPressed: _reload,
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            );
          }

          final lots = snapshot.data ?? [];
          final filteredLots = _filterLots(lots);

          return Column(
            children: [
              // THANH TÌM KIẾM
              Padding(
                padding: const EdgeInsets.all(12),
                child: TextField(
                  controller: _searchController,
                  onChanged: (value) {
                    setState(() {
                      _keyword = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText: 'Tìm tên hoặc địa chỉ bãi xe...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _keyword.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              setState(() {
                                _keyword = '';
                              });
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),

              // SỐ LƯỢNG KẾT QUẢ
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Tìm thấy ${filteredLots.length}/${lots.length} bãi xe',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // DANH SÁCH BÃI XE
              Expanded(
                child: filteredLots.isEmpty
                    ? const Center(
                        child: Text('Không tìm thấy bãi xe phù hợp.'),
                      )
                    : ListView.builder(
                        itemCount: filteredLots.length,
                        itemBuilder: (context, index) {
                          final parking = filteredLots[index];

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
                              title: Text(parking.name),
                              subtitle: Text(parking.address),
                              trailing: const Icon(
                                Icons.arrow_forward_ios,
                              ),
                              onTap: () {
                                Navigator.pop(
                                  context,
                                  parking.name,
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
    );
  }
}

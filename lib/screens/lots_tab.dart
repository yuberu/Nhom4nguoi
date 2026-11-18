import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../models/booking.dart';
import '../models/parking_lot.dart';
import '../services/parking_service.dart';
import '../widgets/app_network_image.dart';
import '../widgets/list_state_view.dart';
import '../widgets/snack.dart';
import 'lot_detail_screen.dart';

/// Tab 1 – Danh sách #1: bãi xe tải từ API bằng ListView.builder.
class LotsTab extends StatefulWidget {
  const LotsTab({super.key});

  @override
  State<LotsTab> createState() => _LotsTabState();
}

class _LotsTabState extends State<LotsTab> {
  final _service = ParkingService();

  List<ParkingLot> _lots = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool silent = false}) async {
    if (!silent) setState(() => _loading = true);
    try {
      final data = await _service.getLots();
      if (!mounted) return;
      setState(() {
        _lots = data;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      if (_lots.isNotEmpty) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openDetail(ParkingLot lot) async {
    // Màn hình chi tiết trả về Booking nếu người dùng đặt chỗ thành công.
    final booking = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(builder: (_) => LotDetailScreen(lot: lot)),
    );
    if (!mounted) return;
    if (booking != null) {
      showSnack(context, 'Đặt chỗ tại ${lot.name} thành công!');
      _load(silent: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bãi giữ xe')),
      body: ListStateView(
        loading: _loading,
        error: _error,
        isEmpty: _lots.isEmpty,
        emptyText: 'Chưa có bãi xe nào.',
        emptyIcon: Icons.local_parking_outlined,
        onRefresh: () => _load(silent: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: _lots.length,
          itemBuilder: (context, index) {
            final lot = _lots[index];
            return _LotCard(lot: lot, onTap: () => _openDetail(lot));
          },
        ),
      ),
    );
  }
}

class _LotCard extends StatelessWidget {
  const _LotCard({required this.lot, required this.onTap});

  final ParkingLot lot;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Card(
      clipBehavior: Clip.antiAlias,
      margin: const EdgeInsets.only(bottom: 12),
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppNetworkImage(url: lot.imageUrl, height: 150),
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(lot.name, style: theme.textTheme.titleMedium),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.place_outlined,
                          size: 16, color: cs.onSurfaceVariant),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          lot.address,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.bodySmall,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: lot.isFull
                              ? cs.errorContainer
                              : cs.primaryContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          lot.isFull
                              ? 'Hết chỗ'
                              : 'Còn ${lot.availableSlots}/${lot.totalSlots} chỗ',
                          style: theme.textTheme.labelMedium?.copyWith(
                            color: lot.isFull
                                ? cs.onErrorContainer
                                : cs.onPrimaryContainer,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${formatVnd(lot.pricePerHour)}/giờ',
                        style: theme.textTheme.titleSmall
                            ?.copyWith(color: cs.primary),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

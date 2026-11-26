
import 'package:flutter/material.dart';

import '../models/booking.dart';
import '../models/parking_lot.dart';
import 'booking_screen.dart';

/// Màn hình 6: chi tiết bãi xe.
/// Đặt chỗ xong thì pop trả [Booking] về danh sách.
class LotDetailScreen extends StatelessWidget {
  const LotDetailScreen({
    super.key,
    required this.lot,
  });

  final ParkingLot lot;

  Future<void> _book(BuildContext context) async {
    final booking = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(
        builder: (_) => BookingScreen(lot: lot),
      ),
    );

    if (!context.mounted) return;

    if (booking != null) {
      Navigator.pop(context, booking);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: Text(lot.name),
      ),
      body: ListView(
        children: [
          Container(
            height: 200,
            color: cs.surfaceContainerHighest,
            child: Icon(
              Icons.local_parking,
              size: 80,
              color: cs.primary,
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  lot.name,
                  style: theme.textTheme.headlineSmall,
                ),

                const SizedBox(height: 16),

                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.place_outlined,
                      color: cs.primary,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        lot.address,
                        style: theme.textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Text(
                  'Thông tin vị trí',
                  style: theme.textTheme.titleMedium,
                ),

                const SizedBox(height: 12),

                _InfoTile(
                  icon: Icons.map_outlined,
                  label: 'Vĩ độ',
                  value: lot.latitude.toString(),
                ),

                const SizedBox(height: 12),

                _InfoTile(
                  icon: Icons.explore_outlined,
                  label: 'Kinh độ',
                  value: lot.longitude.toString(),
                ),

                if (lot.createdAt != null) ...[
                  const SizedBox(height: 12),
                  _InfoTile(
                    icon: Icons.calendar_today_outlined,
                    label: 'Ngày tạo',
                    value: lot.createdAt!.toLocal().toString(),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),

      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: () => _book(context),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: const Text('Đặt chỗ'),
        ),
      ),
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelMedium,
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: theme.textTheme.titleMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

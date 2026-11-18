import 'package:flutter/material.dart';

import '../core/format.dart';
import '../models/booking.dart';
import '../models/parking_lot.dart';
import '../widgets/app_network_image.dart';
import 'booking_screen.dart';

/// Màn hình 6: chi tiết bãi xe. Đặt chỗ xong thì pop trả [Booking] về danh sách.
class LotDetailScreen extends StatelessWidget {
  const LotDetailScreen({super.key, required this.lot});

  final ParkingLot lot;

  Future<void> _book(BuildContext context) async {
    final booking = await Navigator.push<Booking>(
      context,
      MaterialPageRoute(builder: (_) => BookingScreen(lot: lot)),
    );
    if (!context.mounted) return;
    if (booking != null) Navigator.pop(context, booking);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: Text(lot.name)),
      body: ListView(
        children: [
          AppNetworkImage(url: lot.imageUrl, height: 230),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(lot.name, style: theme.textTheme.headlineSmall),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.place_outlined, color: cs.primary),
                    const SizedBox(width: 8),
                    Expanded(child: Text(lot.address)),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.event_seat_outlined,
                        label: 'Chỗ trống',
                        value: '${lot.availableSlots}/${lot.totalSlots}',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _InfoTile(
                        icon: Icons.payments_outlined,
                        label: 'Giá',
                        value: '${formatVnd(lot.pricePerHour)}/giờ',
                      ),
                    ),
                  ],
                ),
                if (lot.description != null && lot.description!.isNotEmpty) ...[
                  const SizedBox(height: 20),
                  Text('Mô tả', style: theme.textTheme.titleMedium),
                  const SizedBox(height: 6),
                  Text(lot.description!),
                ],
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: FilledButton.icon(
          onPressed: lot.isFull ? null : () => _book(context),
          icon: const Icon(Icons.bookmark_add_outlined),
          label: Text(lot.isFull ? 'Bãi đã hết chỗ' : 'Đặt chỗ'),
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
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: cs.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: cs.primary),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.labelMedium),
          Text(value, style: theme.textTheme.titleMedium),
        ],
      ),
    );
  }
}

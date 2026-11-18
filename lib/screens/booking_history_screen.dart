import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/format.dart';
import '../models/booking.dart';
import '../services/parking_service.dart';
import '../widgets/list_state_view.dart';
import '../widgets/snack.dart';

/// Màn hình 8 – Danh sách #3: lịch sử đặt chỗ tải từ API.
class BookingHistoryScreen extends StatefulWidget {
  const BookingHistoryScreen({super.key});

  @override
  State<BookingHistoryScreen> createState() => _BookingHistoryScreenState();
}

class _BookingHistoryScreenState extends State<BookingHistoryScreen> {
  final _service = ParkingService();

  List<Booking> _bookings = [];
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
      final data = await _service.getBookings();
      if (!mounted) return;
      setState(() {
        _bookings = data;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      if (_bookings.isNotEmpty) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Lịch sử đặt chỗ')),
      body: ListStateView(
        loading: _loading,
        error: _error,
        isEmpty: _bookings.isEmpty,
        emptyText: 'Bạn chưa có lượt đặt chỗ nào.',
        emptyIcon: Icons.history,
        onRefresh: () => _load(silent: true),
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          itemCount: _bookings.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final b = _bookings[index];
            final active = b.status == 'active';
            return Card(
              margin: EdgeInsets.zero,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor:
                      active ? cs.primaryContainer : cs.surfaceContainerHighest,
                  child: Icon(
                    active ? Icons.timelapse : Icons.check_circle_outline,
                    color: active ? cs.onPrimaryContainer : cs.onSurfaceVariant,
                  ),
                ),
                title: Text(b.lotName),
                subtitle: Text(
                  '${b.plate} · ${b.hours} giờ'
                  '${b.createdAt != null ? '\n${formatDateTime(b.createdAt!)}' : ''}',
                ),
                isThreeLine: b.createdAt != null,
                trailing: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      formatVnd(b.totalPrice),
                      style: theme.textTheme.titleSmall,
                    ),
                    Text(b.statusLabel, style: theme.textTheme.labelSmall),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

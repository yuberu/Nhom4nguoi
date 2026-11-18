import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../models/vehicle.dart';
import '../services/parking_service.dart';
import '../widgets/list_state_view.dart';
import '../widgets/snack.dart';
import 'vehicle_form_screen.dart';

/// Tab 2 – Danh sách #2: xe của tôi. Vuốt để xóa, có SnackBar "Hoàn tác".
class VehiclesTab extends StatefulWidget {
  const VehiclesTab({super.key});

  @override
  State<VehiclesTab> createState() => _VehiclesTabState();
}

class _VehiclesTabState extends State<VehiclesTab> {
  final _service = ParkingService();

  List<Vehicle> _vehicles = [];
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
      final data = await _service.getVehicles();
      if (!mounted) return;
      setState(() {
        _vehicles = data;
        _error = null;
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
      if (_vehicles.isNotEmpty) showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  /// Form trả về Vehicle đã lưu (mới hoặc đã sửa) qua Navigator.pop.
  Future<void> _openForm([Vehicle? vehicle]) async {
    final saved = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(builder: (_) => VehicleFormScreen(vehicle: vehicle)),
    );
    if (!mounted || saved == null) return;
    setState(() {
      if (vehicle == null) {
        _vehicles.insert(0, saved);
      } else {
        final i = _vehicles.indexWhere((v) => v.id == vehicle.id);
        if (i >= 0) _vehicles[i] = saved;
      }
    });
    showSnack(
      context,
      vehicle == null ? 'Đã thêm xe ${saved.plate}' : 'Đã cập nhật xe ${saved.plate}',
    );
  }

  /// Xóa lạc quan: gỡ khỏi danh sách ngay, chỉ gọi API khi SnackBar đóng
  /// mà người dùng không bấm "Hoàn tác".
  Future<void> _deleteWithUndo(int index, Vehicle vehicle) async {
    setState(() => _vehicles.removeAt(index));

    final messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    final controller = messenger.showSnackBar(
      SnackBar(
        content: Text('Đã xóa xe ${vehicle.plate}'),
        duration: const Duration(seconds: 5),
        action: SnackBarAction(
          label: 'Hoàn tác',
          onPressed: () {
            if (!mounted) return;
            setState(() {
              _vehicles.insert(math.min(index, _vehicles.length), vehicle);
            });
          },
        ),
      ),
    );

    final reason = await controller.closed;
    if (reason == SnackBarClosedReason.action) return;

    try {
      await _service.deleteVehicle(vehicle.id);
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() {
        _vehicles.insert(math.min(index, _vehicles.length), vehicle);
      });
      showSnack(context, 'Xóa thất bại: ${e.message}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(title: const Text('Xe của tôi')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openForm(),
        icon: const Icon(Icons.add),
        label: const Text('Thêm xe'),
      ),
      body: ListStateView(
        loading: _loading,
        error: _error,
        isEmpty: _vehicles.isEmpty,
        emptyText: 'Bạn chưa thêm xe nào.\nBấm "Thêm xe" để bắt đầu.',
        emptyIcon: Icons.directions_car_outlined,
        onRefresh: () => _load(silent: true),
        child: ListView.builder(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.only(bottom: 88),
          itemCount: _vehicles.length,
          itemBuilder: (context, index) {
            final v = _vehicles[index];
            final detail = [v.typeLabel, v.brand, if (v.color != null) v.color]
                .where((e) => e != null && e.isNotEmpty)
                .join(' · ');
            return Dismissible(
              key: ValueKey(v.id),
              direction: DismissDirection.endToStart,
              background: Container(
                color: cs.errorContainer,
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 24),
                child: Icon(Icons.delete_outline, color: cs.onErrorContainer),
              ),
              onDismissed: (_) => _deleteWithUndo(index, v),
              child: ListTile(
                leading: CircleAvatar(
                  child: Icon(
                    v.type == Vehicle.car
                        ? Icons.directions_car
                        : Icons.two_wheeler,
                  ),
                ),
                title: Text(v.plate),
                subtitle: Text(detail),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => _openForm(v),
              ),
            );
          },
        ),
      ),
    );
  }
}

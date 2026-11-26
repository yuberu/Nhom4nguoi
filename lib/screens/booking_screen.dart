
import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/validators.dart';
import '../models/booking.dart';
import '../models/parking_lot.dart';
import '../models/vehicle.dart';
import '../services/parking_service.dart';
import '../widgets/snack.dart';
import 'vehicle_form_screen.dart';

/// Màn hình 7: đặt chỗ. Pop trả về [Booking] khi thành công.
class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key, required this.lot});

  final ParkingLot lot;

  @override
  State<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends State<BookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _hoursCtrl = TextEditingController(text: '1');
  final _service = ParkingService();

  List<Vehicle> _vehicles = [];
  int? _vehicleId;
  bool _loading = true;
  bool _submitting = false;
  String? _error;
  

  @override
  void initState() {
    super.initState();
    _loadVehicles();
  }

  @override
  void dispose() {
    _hoursCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadVehicles() async {
    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final data = await _service.getVehicles();

      if (!mounted) return;

      setState(() {
        _vehicles = data;
        if (data.isNotEmpty) {
          _vehicleId = data.first.id;
        }
      });
    } on ApiException catch (e) {
      if (!mounted) return;
      setState(() => _error = e.message);
    } finally {
      if (mounted) {
        setState(() => _loading = false);
      }
    }
  }

  Future<void> _addVehicle() async {
    final vehicle = await Navigator.push<Vehicle>(
      context,
      MaterialPageRoute(
        builder: (_) => const VehicleFormScreen(),
      ),
    );

    if (!mounted || vehicle == null) return;

    setState(() {
      _vehicles.insert(0, vehicle);
      _vehicleId = vehicle.id;
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_vehicleId == null) {
      showSnack(context, 'Vui lòng chọn xe');
      return;
    }

    setState(() => _submitting = true);

    try {
      final booking = await _service.createBooking(
        lotId: widget.lot.id,
        vehicleId: _vehicleId!,
        hours: int.parse(_hoursCtrl.text.trim()),
      );

      if (!mounted) return;

      Navigator.pop<Booking>(context, booking);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message);
    } finally {
      if (mounted) {
        setState(() => _submitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Đặt chỗ – ${widget.lot.name}'),
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: _loadVehicles,
                child: const Text('Thử lại'),
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: ListTile(
                leading: const Icon(Icons.local_parking),
                title: Text(widget.lot.name),
                subtitle: Text(widget.lot.address),
              ),
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<int>(
              key: ValueKey(
                'vehicle-$_vehicleId-${_vehicles.length}',
              ),
              initialValue: _vehicleId,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Chọn xe',
                prefixIcon: Icon(
                  Icons.directions_car_outlined,
                ),
              ),
              items: [
                for (final v in _vehicles)
                  DropdownMenuItem<int>(
                    value: v.id,
                    child: Text('${v.plate} · ${v.typeLabel}'),
                  ),
              ],
              onChanged: (value) {
                setState(() => _vehicleId = value);
              },
              validator: (value) =>
                  value == null
                      ? 'Vui lòng chọn xe (hoặc thêm xe mới)'
                      : null,
            ),

            Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: _addVehicle,
                icon: const Icon(Icons.add),
                label: const Text('Thêm xe mới'),
              ),
            ),

            const SizedBox(height: 8),

            TextFormField(
              controller: _hoursCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Số giờ gửi',
                suffixText: 'giờ',
                prefixIcon: Icon(Icons.schedule),
              ),
              validator: Validators.hours,
            ),

            const SizedBox(height: 24),

            FilledButton.icon(
              onPressed: _submitting ? null : _submit,
              icon: _submitting
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    )
                  : const Icon(Icons.check),
              label: const Text('Xác nhận đặt chỗ'),
            ),
          ],
        ),
      ),
    );
  }
}

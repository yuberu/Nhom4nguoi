import 'package:flutter/material.dart';

import '../core/api_client.dart';
import '../core/validators.dart';
import '../models/vehicle.dart';
import '../services/parking_service.dart';
import '../widgets/snack.dart';

/// Màn hình 5: thêm / sửa xe. Lưu thành công thì pop trả về [Vehicle].
class VehicleFormScreen extends StatefulWidget {
  const VehicleFormScreen({super.key, this.vehicle});

  final Vehicle? vehicle;

  @override
  State<VehicleFormScreen> createState() => _VehicleFormScreenState();
}

class _VehicleFormScreenState extends State<VehicleFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _service = ParkingService();
  late final TextEditingController _plateCtrl;
  late final TextEditingController _brandCtrl;
  late final TextEditingController _colorCtrl;
  late String _type;

  bool _saving = false;

  bool get _isEdit => widget.vehicle != null;

  @override
  void initState() {
    super.initState();
    final v = widget.vehicle;
    _plateCtrl = TextEditingController(text: v?.plate ?? '');
    _brandCtrl = TextEditingController(text: v?.brand ?? '');
    _colorCtrl = TextEditingController(text: v?.color ?? '');
    _type = v?.type ?? Vehicle.motorbike;
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _brandCtrl.dispose();
    _colorCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final plate = _plateCtrl.text.trim().toUpperCase();
    final brand = _brandCtrl.text.trim();
    final color = _colorCtrl.text.trim().isEmpty ? null : _colorCtrl.text.trim();

    try {
      final Vehicle saved;
      if (_isEdit) {
        saved = await _service.updateVehicle(
          widget.vehicle!.id,
          plate: plate,
          type: _type,
          brand: brand,
          color: color,
        );
      } else {
        saved = await _service.createVehicle(
          plate: plate,
          type: _type,
          brand: brand,
          color: color,
        );
      }
      if (!mounted) return;
      Navigator.pop(context, saved);
    } on ApiException catch (e) {
      if (!mounted) return;
      showSnack(context, e.message);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_isEdit ? 'Sửa thông tin xe' : 'Thêm xe')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<String>(
                  showSelectedIcon: false,
                  segments: const [
                    ButtonSegment(
                      value: Vehicle.motorbike,
                      icon: Icon(Icons.two_wheeler),
                      label: Text('Xe máy'),
                    ),
                    ButtonSegment(
                      value: Vehicle.car,
                      icon: Icon(Icons.directions_car),
                      label: Text('Ô tô'),
                    ),
                  ],
                  selected: {_type},
                  onSelectionChanged: (s) => setState(() => _type = s.first),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  textInputAction: TextInputAction.next,
                  decoration: const InputDecoration(
                    labelText: 'Biển số',
                    hintText: '29A-123.45',
                    prefixIcon: Icon(Icons.confirmation_number_outlined),
                  ),
                  validator: Validators.plate,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _brandCtrl,
                  textInputAction: TextInputAction.next,
                  textCapitalization: TextCapitalization.words,
                  decoration: const InputDecoration(
                    labelText: 'Hãng xe',
                    hintText: 'Honda Vision, Toyota Vios...',
                    prefixIcon: Icon(Icons.badge_outlined),
                  ),
                  validator: (v) => Validators.notEmpty(v, 'Hãng xe'),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _colorCtrl,
                  textInputAction: TextInputAction.done,
                  decoration: const InputDecoration(
                    labelText: 'Màu sắc (không bắt buộc)',
                    prefixIcon: Icon(Icons.palette_outlined),
                  ),
                ),
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving
                      ? const SizedBox(
                          height: 18,
                          width: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.save_outlined),
                  label: Text(_isEdit ? 'Lưu thay đổi' : 'Thêm xe'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

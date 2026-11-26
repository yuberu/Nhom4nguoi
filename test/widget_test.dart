
import 'package:flutter_test/flutter_test.dart';
import 'package:parking_client/core/format.dart';
import 'package:parking_client/core/validators.dart';
import 'package:parking_client/models/booking.dart';
import 'package:parking_client/models/parking_lot.dart';
import 'package:parking_client/models/vehicle.dart';

void main() {
  group('formatVnd', () {
    test('nhóm hàng nghìn bằng dấu chấm', () {
      expect(formatVnd(0), '0đ');
      expect(formatVnd(15000), '15.000đ');
      expect(formatVnd(1234567), '1.234.567đ');
    });
  });

  group('Validators', () {
    test('email', () {
      expect(Validators.email(''), isNotNull);
      expect(Validators.email('abc'), isNotNull);
      expect(Validators.email('a@b.com'), isNull);
    });

    test('password tối thiểu 6 ký tự', () {
      expect(Validators.password('12345'), isNotNull);
      expect(Validators.password('123456'), isNull);
    });

    test('biển số xe', () {
      expect(Validators.plate('29A-123.45'), isNull);
      expect(Validators.plate('59X1-123.45'), isNull);
      expect(Validators.plate('30E-12345'), isNull);
      expect(Validators.plate('ABC'), isNotNull);
      expect(Validators.plate(''), isNotNull);
    });

    test('số giờ 1..72', () {
      expect(Validators.hours('0'), isNotNull);
      expect(Validators.hours('73'), isNotNull);
      expect(Validators.hours('abc'), isNotNull);
      expect(Validators.hours('5'), isNull);
    });
  });

  group('Models', () {
    test('ParkingLot đọc dữ liệu Backend mới', () {
      final lot = ParkingLot.fromJson({
        'id': 1,
        'ten': 'Bãi A',
        'dia_chi': 'Hà Nội',
        'vi_do': '21.0285',
        'kinh_do': '105.8542',
        'created_at': '2026-11-09T08:30:00.000Z',
      });

      expect(lot.id, 1);
      expect(lot.name, 'Bãi A');
      expect(lot.address, 'Hà Nội');
      expect(lot.latitude, 21.0285);
      expect(lot.longitude, 105.8542);
      expect(lot.createdAt, isNotNull);
    });

    test('Vehicle.fromJson', () {
      final v = Vehicle.fromJson({
        'id': 3,
        'plate': '29A-123.45',
        'type': 'car',
        'brand': 'Toyota Vios',
      });

      expect(v.typeLabel, 'Ô tô');
      expect(v.color, isNull);
    });

    test('Booking.fromJson', () {
      final b = Booking.fromJson({
        'id': 9,
        'lot_name': 'Bãi A',
        'plate': '29A-123.45',
        'hours': 2,
        'total_price': '30000',
        'status': 'active',
        'created_at': '2026-11-09T08:30:00.000Z',
      });

      expect(b.totalPrice, 30000);
      expect(b.statusLabel, 'Đang giữ chỗ');
      expect(b.createdAt, isNotNull);
    });
  });
}

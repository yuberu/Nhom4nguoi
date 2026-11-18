import '../core/api_client.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/parking_lot.dart';
import '../models/vehicle.dart';

class AuthResult {
  const AuthResult({required this.token, required this.user});

  final String token;
  final AppUser user;
}

/// Toàn bộ lời gọi API tới backend Node.js/Express.
class ParkingService {
  ParkingService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  // ---------- Xác thực ----------

  Future<AuthResult> login(String email, String password) async {
    final data = _asMap(await _api.post('/auth/login', {
      'email': email,
      'password': password,
    }));
    final token = data['token']?.toString();
    if (token == null || token.isEmpty) {
      throw ApiException('Máy chủ không trả về token.');
    }
    return AuthResult(
      token: token,
      user: AppUser.fromJson(_asMap(data['user'])),
    );
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    await _api.post('/auth/register', {
      'full_name': fullName,
      'email': email,
      'phone': phone,
      'password': password,
    });
  }

  Future<AppUser> me() async =>
      AppUser.fromJson(_asMap(await _api.get('/auth/me')));

  // ---------- Bãi xe ----------

  Future<List<ParkingLot>> getLots() async {
    final list = _asList(await _api.get('/lots'));
    return list
        .map((e) => ParkingLot.fromJson(_asMap(e)))
        .toList(growable: true);
  }

  // ---------- Xe của tôi ----------

  Future<List<Vehicle>> getVehicles() async {
    final list = _asList(await _api.get('/vehicles'));
    return list.map((e) => Vehicle.fromJson(_asMap(e))).toList(growable: true);
  }

  Future<Vehicle> createVehicle({
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.post(
      '/vehicles',
      Vehicle.toPayload(plate: plate, type: type, brand: brand, color: color),
    );
    return Vehicle.fromJson(_asMap(data));
  }

  Future<Vehicle> updateVehicle(
    int id, {
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.put(
      '/vehicles/$id',
      Vehicle.toPayload(plate: plate, type: type, brand: brand, color: color),
    );
    return Vehicle.fromJson(_asMap(data));
  }

  Future<void> deleteVehicle(int id) async {
    await _api.delete('/vehicles/$id');
  }

  // ---------- Đặt chỗ ----------

  Future<List<Booking>> getBookings() async {
    final list = _asList(await _api.get('/bookings'));
    return list.map((e) => Booking.fromJson(_asMap(e))).toList(growable: true);
  }

  Future<Booking> createBooking({
    required int lotId,
    required int vehicleId,
    required int hours,
  }) async {
    final data = await _api.post('/bookings', {
      'lot_id': lotId,
      'vehicle_id': vehicleId,
      'hours': hours,
    });
    return Booking.fromJson(_asMap(data));
  }

  // ---------- Helpers ----------

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Dữ liệu máy chủ trả về không hợp lệ.');
  }

  /// Chấp nhận cả `[...]` lẫn `{ "data": [...] }`.
  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['data'] is List) return data['data'] as List;
    throw ApiException('Dữ liệu máy chủ trả về không hợp lệ.');
  }
}

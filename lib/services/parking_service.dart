
import '../core/api_client.dart';
import '../models/app_user.dart';
import '../models/booking.dart';
import '../models/parking_lot.dart';
import '../models/vehicle.dart';

class AuthResult {
  const AuthResult({
    required this.token,
    required this.user,
  });

  final String token;
  final AppUser user;
}

// ================= ĐƯỜNG DẪN API =================

const String kVehiclesPath = '/xe';
const String kBookingsPath = '/dat-cho';

// Các trường API đặt chỗ.
// Chưa thay đổi cho đến khi kiểm tra Backend đặt chỗ.
const String kBookingLotKey = 'baiXeId';
const String kBookingVehicleKey = 'xeId';
const String kBookingHoursKey = 'soGio';

// ==================================================

class ParkingService {
  ParkingService({ApiClient? client})
      : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  // ================= XÁC THỰC =================

  Future<AuthResult> login(
    String email,
    String password,
  ) async {
    final data = _asMap(
      await _api.post('/auth/dang-nhap', {
        'email': email,
        'matKhau': password,
      }),
    );

    return AuthResult(
      token: data['token'].toString(),
      user: AppUser.fromJson(
        _asMap(data['nguoiDung']),
      ),
    );
  }

  Future<AppUser> register({
    required String fullName,
    required String email,
    required String phone,
    required String password,
  }) async {
    final data = _asMap(
      await _api.post('/auth/dang-ky', {
        'hoTen': fullName,
        'email': email,
        'soDienThoai': phone,
        'matKhau': password,
      }),
    );

    return AppUser.fromJson(
      _asMap(data['nguoiDung']),
    );
  }

  Future<AppUser> me() async {
    final data = _asMap(
      await _api.get('/auth/me'),
    );

    return AppUser.fromJson(
      _asMap(data['nguoiDung']),
    );
  }

  // ================= BÃI XE =================

  Future<List<ParkingLot>> getLots() async {
    final response = await _api.get('/bai-xe');

    return _asList(response)
        .map(
          (e) => ParkingLot.fromJson(
            _asMap(e),
          ),
        )
        .toList(growable: true);
  }

  // ================= PHƯƠNG TIỆN =================

  // Lấy danh sách xe
  Future<List<Vehicle>> getVehicles() async {
    final response = await _api.get(kVehiclesPath);

    return _asList(response)
        .map(
          (e) => Vehicle.fromJson(
            _asMap(e),
          ),
        )
        .toList(growable: true);
  }

  // Thêm xe
  Future<Vehicle> createVehicle({
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.post(
      kVehiclesPath,
      Vehicle.toPayload(
        plate: plate,
        type: type,
        brand: brand,
        color: color,
      ),
    );

    return Vehicle.fromJson(
      _unwrapMap(data),
    );
  }

  // Sửa xe
  Future<Vehicle> updateVehicle(
    int id, {
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.put(
      '$kVehiclesPath/$id',
      Vehicle.toPayload(
        plate: plate,
        type: type,
        brand: brand,
        color: color,
      ),
    );

    return Vehicle.fromJson(
      _unwrapMap(data),
    );
  }

  // Xóa xe
  Future<void> deleteVehicle(int id) async {
    await _api.delete(
      '$kVehiclesPath/$id',
    );
  }

  // ================= ĐẶT CHỖ =================

  Future<List<Booking>> getBookings() async {
    final response = await _api.get(kBookingsPath);

    return _asList(response)
        .map(
          (e) => Booking.fromJson(
            _asMap(e),
          ),
        )
        .toList(growable: true);
  }

 Future<Booking> createBooking({
  required int lotId,
  required int vehicleId,
  required int hours,
}) async {
  final start = DateTime.now();
  final end = start.add(Duration(hours: hours));

  final data = await _api.post(
    kBookingsPath,
    {
      'bai_xe_id': lotId,
      'xe_id': vehicleId,
      'thoi_gian_bat_dau': start.toUtc().toIso8601String(),
      'thoi_gian_ket_thuc': end.toUtc().toIso8601String(),
    },
  );

  return Booking.fromJson(_unwrapMap(data));
}
  }

  // ================= HÀM HỖ TRỢ =================

  // Chuyển dữ liệu thành Map
  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) {
      return Map<String, dynamic>.from(data);
    }

    throw ApiException(
      'Dữ liệu máy chủ trả về không hợp lệ.',
    );
  }

  // Đọc Map được Backend bọc trong duLieu
  Map<String, dynamic> _unwrapMap(dynamic data) {
    final map = _asMap(data);

    if (map['du_lieu'] is Map) {  
      return _asMap(map['du_lieu']);
    }

    if (map['duLieu'] is Map) {
      return _asMap(map['duLieu']);
    }

    if (map['data'] is Map) {
      return _asMap(map['data']);
    }

    return map;
  }

  // Đọc danh sách được Backend bọc trong duLieu
  List<dynamic> _asList(dynamic data) {
    if (data is List) {
      return data;
    }

    if (data is Map && data['du_lieu'] is List) {
      return data['du_lieu'] as List;
    }

    if (data is Map && data['duLieu'] is List) {
      return data['duLieu'] as List;
    }

    if (data is Map && data['data'] is List) {
      return data['data'] as List;
    }

    throw ApiException(
      'Dữ liệu máy chủ trả về không hợp lệ.',
    );
  }


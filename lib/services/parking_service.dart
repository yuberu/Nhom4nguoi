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

/// ===== SỬA Ở ĐÂY CHO KHỚP BACKEND =====
/// Đường dẫn (xem các dòng app.use('/api/...') trong server)
const String kVehiclesPath = '/phuong-tien'; // TODO: đổi cho đúng
const String kBookingsPath = '/dat-cho'; // TODO: đổi cho đúng

/// Tên field gửi lên khi tạo đặt chỗ
const String kBookingLotKey = 'baiXeId'; // TODO: đổi cho đúng
const String kBookingVehicleKey = 'phuongTienId'; // TODO: đổi cho đúng
const String kBookingHoursKey = 'soGio'; // TODO: đổi cho đúng
/// ======================================

/// Toàn bộ lời gọi API tới Backend Node.js/Express.
class ParkingService {
  ParkingService({ApiClient? client}) : _api = client ?? ApiClient.instance;

  final ApiClient _api;

  // ---------------- XÁC THỰC ----------------

  Future<AuthResult> login(String email, String password) async {
    final data = _asMap(
      await _api.post('/auth/dang-nhap', {
        'email': email,
        'matKhau': password,
      }),
    );
    return AuthResult(
      token: data['token'].toString(),
      user: AppUser.fromJson(_asMap(data['nguoiDung'])),
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
    return AppUser.fromJson(_asMap(data['nguoiDung']));
  }

  Future<AppUser> me() async {
    final data = _asMap(await _api.get('/auth/me'));
    return AppUser.fromJson(_asMap(data['nguoiDung']));
  }

  // ---------------- BÃI XE ----------------

  Future<List<ParkingLot>> getLots() async {
    final response = await _api.get('/bai-xe');
    return _asList(response)
        .map((e) => ParkingLot.fromJson(_asMap(e)))
        .toList(growable: true);
  }

  // ---------------- PHƯƠNG TIỆN ----------------

  Future<List<Vehicle>> getVehicles() async {
    final response = await _api.get(kVehiclesPath);
    return _asList(response)
        .map((e) => Vehicle.fromJson(_asMap(e)))
        .toList(growable: true);
  }

  Future<Vehicle> createVehicle({
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.post(
      kVehiclesPath,
      Vehicle.toPayload(plate: plate, type: type, brand: brand, color: color),
    );
    return Vehicle.fromJson(_unwrapMap(data));
  }

  Future<Vehicle> updateVehicle(
    int id, {
    required String plate,
    required String type,
    required String brand,
    String? color,
  }) async {
    final data = await _api.put(
      '$kVehiclesPath/$id',
      Vehicle.toPayload(plate: plate, type: type, brand: brand, color: color),
    );
    return Vehicle.fromJson(_unwrapMap(data));
  }

  Future<void> deleteVehicle(int id) async {
    await _api.delete('$kVehiclesPath/$id');
  }

  // ---------------- ĐẶT CHỖ ----------------

  Future<List<Booking>> getBookings() async {
    final response = await _api.get(kBookingsPath);
    return _asList(response)
        .map((e) => Booking.fromJson(_asMap(e)))
        .toList(growable: true);
  }

  Future<Booking> createBooking({
    required int lotId,
    required int vehicleId,
    required int hours,
  }) async {
    final data = await _api.post(kBookingsPath, {
      kBookingLotKey: lotId,
      kBookingVehicleKey: vehicleId,
      kBookingHoursKey: hours,
    });
    return Booking.fromJson(_unwrapMap(data));
  }

  // ---------------- HÀM HỖ TRỢ ----------------

  Map<String, dynamic> _asMap(dynamic data) {
    if (data is Map) return Map<String, dynamic>.from(data);
    throw ApiException('Dữ liệu máy chủ trả về không hợp lệ.');
  }

  /// Nhận Map trực tiếp hoặc Map bọc trong du_lieu / data.
  Map<String, dynamic> _unwrapMap(dynamic data) {
    final map = _asMap(data);
    if (map['du_lieu'] is Map) return _asMap(map['du_lieu']);
    if (map['data'] is Map) return _asMap(map['data']);
    return map;
  }

  /// Nhận List trực tiếp hoặc Map chứa du_lieu / data.
  List<dynamic> _asList(dynamic data) {
    if (data is List) return data;
    if (data is Map && data['du_lieu'] is List) return data['du_lieu'] as List;
    if (data is Map && data['data'] is List) return data['data'] as List;
    throw ApiException('Dữ liệu máy chủ trả về không hợp lệ.');
  }
}
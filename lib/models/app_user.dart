
import 'json_utils.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    this.role,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phone;
  final String? role;

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: toInt(json['id']),
      fullName: toStr(
        json['hoTen'] ?? json['full_name'],
      ) ?? '',
      email: toStr(json['email']) ?? '',
      phone: toStr(
        json['soDienThoai'] ?? json['phone'],
      ),
      role: toStr(
        json['vaiTro'] ?? json['role'],
      ),
    );
  }
}

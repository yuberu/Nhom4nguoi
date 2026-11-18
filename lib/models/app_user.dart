import 'json_utils.dart';

class AppUser {
  const AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
  });

  final int id;
  final String fullName;
  final String email;
  final String? phone;

  factory AppUser.fromJson(Map<String, dynamic> json) => AppUser(
        id: toInt(json['id']),
        fullName: toStr(json['full_name']) ?? '',
        email: toStr(json['email']) ?? '',
        phone: toStr(json['phone']),
      );
}

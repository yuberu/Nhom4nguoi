class Product {
  const Product({
    required this.id,
    required this.title,
    required this.description,
    required this.price,
    required this.thumbnail,
    required this.category,
  });

  final int id;
  final String title;
  final String description;
  final double price;
  final String thumbnail;
  final String category;

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      title: (json['title'] ?? '') as String,
      description: (json['description'] ?? '') as String,
      price: ((json['price'] ?? 0) as num).toDouble(),
      thumbnail: (json['thumbnail'] ?? '') as String,
      category: (json['category'] ?? '') as String,
    );
  }

  Product copyWith({int? id}) {
    return Product(
      id: id ?? this.id,
      title: title,
      description: description,
      price: price,
      thumbnail: thumbnail,
      category: category,
    );
  }
}

class AppUser {
  const AppUser({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.image,
    required this.phone,
  });

  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String image;
  final String phone;

  String get fullName => '$firstName $lastName'.trim();

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      id: json['id'] as int,
      username: (json['username'] ?? '') as String,
      firstName: (json['firstName'] ?? '') as String,
      lastName: (json['lastName'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      image: (json['image'] ?? '') as String,
      phone: (json['phone'] ?? '') as String,
    );
  }
}

enum ActionType { updated, deleted }

/// Kết quả trả từ màn hình chi tiết về danh sách.
class ProductAction {
  const ProductAction(this.type, this.product);

  final ActionType type;
  final Product product;
}

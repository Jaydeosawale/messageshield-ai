class User {
  final int id;
  final String email;
  final bool isActive;

  User({
    required this.id,
    required this.email,
    required this.isActive,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      isActive: json['is_active'] as bool,
    );
  }
}
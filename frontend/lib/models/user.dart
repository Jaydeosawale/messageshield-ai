class User {
  final int id;
  final String email;
  final bool isActive;

  // Roles received from backend.
  final List<String> roles;

  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      email: json['email'] as String,
      isActive: json['is_active'] as bool? ?? false,
      roles: (json['roles'] as List?)
              ?.map((role) => role.toString())
              .toList() ??
          const [],
    );
  }

  // ==========================================
  // Role helpers
  // ==========================================

  bool get isAdmin {
    return roles.any(
      (role) => role.toLowerCase() == 'admin',
    );
  }

  bool get hasRoles => roles.isNotEmpty;
}
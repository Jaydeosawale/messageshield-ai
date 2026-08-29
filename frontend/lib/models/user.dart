class User {
  final int id;

  final String email;

  final bool isActive;

  final bool isAdmin;

  final bool emailVerified;

  final String authProvider;

  const User({
    required this.id,
    required this.email,
    required this.isActive,
    required this.isAdmin,
    required this.emailVerified,
    required this.authProvider,
  });

  factory User.fromJson(
    Map<String, dynamic> json,
  ) {
    return User(
      id: json['id'] as int,

      email: json['email'] as String,

      isActive:
          json['is_active'] as bool? ?? false,

      isAdmin:
          json['is_admin'] as bool? ?? false,

      emailVerified:
          json['email_verified'] as bool? ?? false,

      authProvider:
          json['auth_provider'] as String? ??
              'password',
    );
  }

  // ==========================================
  // Authentication helpers
  // ==========================================

  bool get isGoogleUser =>
      authProvider == 'google';

  bool get isPasswordUser =>
      authProvider == 'password';
}
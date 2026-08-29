class ApiConstants {
  ApiConstants._();

  // ==========================================
  // Production API
  // ==========================================

  static const String baseUrl =
      'https://messageshield-ai.onrender.com/api/v1';

  // ==========================================
  // Authentication
  // ==========================================

  static const String register =
      '$baseUrl/auth/register';

  static const String login =
      '$baseUrl/auth/login';

  // Google / Firebase LOGIN
  static const String firebaseLogin =
      '$baseUrl/auth/firebase/login';

  // Google / Firebase REGISTER
  static const String firebaseRegister =
      '$baseUrl/auth/firebase/register';

  static const String me =
      '$baseUrl/auth/me';

  // ==========================================
  // Message analysis
  // ==========================================

  static const String analyze =
      '$baseUrl/analyze';

  static const String analyses =
      '$baseUrl/analyses';
}

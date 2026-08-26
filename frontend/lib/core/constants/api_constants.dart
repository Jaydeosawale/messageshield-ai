class ApiConstants {
  ApiConstants._();

  // Chrome / macOS development
 // static const String baseUrl = 'http://127.0.0.1:8002/api/v1';
  static const String baseUrl =
    'https://messageshield-ai.onrender.com/api/v1';

  static const String register = '$baseUrl/auth/register';
  static const String login = '$baseUrl/auth/login';
  static const String me = '$baseUrl/auth/me';

  static const String analyze = '$baseUrl/analyze';
  static const String analyses = '$baseUrl/analyses';
}
import '../../models/user.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  // Register
  static Future<User> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 201) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    return User.fromJson(data);
  }

  // Login
  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      body: {
        'email': email,
        'password': password,
      },
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    final token = data['access_token'] as String;

    await TokenStorage.saveToken(token);
  }

  // Current user
  static Future<User> getCurrentUser() async {
    final response = await ApiService.get(
      ApiConstants.me,
      authenticated: true,
    );

    if (response.statusCode != 200) {
      throw Exception(
        ApiService.getErrorMessage(response),
      );
    }

    final data =
        ApiService.decodeResponse(response)
            as Map<String, dynamic>;

    return User.fromJson(data);
  }

  // Logout
  static Future<void> logout() async {
    await TokenStorage.deleteToken();
  }
}
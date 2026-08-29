import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;

import '../../models/user.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // ==========================================
  // Register with email/password
  // ==========================================

  static Future<User> register({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.register,
      body: {
        'email': email.trim(),
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

  // ==========================================
  // Email/password login
  // ==========================================

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    final response = await ApiService.post(
      ApiConstants.login,
      body: {
        'email': email.trim(),
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

  // ==========================================
  // Firebase / Google login
  // ==========================================
  //
  // Flow:
  //
  // Google/Firebase login
  //        ↓
  // Firebase ID Token
  //        ↓
  // MessageShield backend
  //        ↓
  // Backend verifies Firebase token
  //        ↓
  // Backend returns MessageShield JWT
  // ==========================================

  static Future<void> loginWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    final idToken =
    await firebaseUser.getIdToken();

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Unable to get authentication token',
      );
    }

    final response = await ApiService.post(
      ApiConstants.firebaseLogin,
      body: {
        'id_token': idToken,
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

    final token = data['access_token'];

    if (token == null || token is! String) {
      throw Exception(
        'Invalid authentication response',
      );
    }

    await TokenStorage.saveToken(token);
  }

  // ==========================================
  // Current MessageShield user
  // ==========================================

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

  // ==========================================
  // Firebase user
  // ==========================================

  static firebase_auth.User? get firebaseUser {
    return _firebaseAuth.currentUser;
  }

  // ==========================================
  // Send email verification
  // ==========================================

  static Future<void> sendEmailVerification() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is signed in',
      );
    }

    if (user.emailVerified) {
      return;
    }

    await user.sendEmailVerification();
  }

  // ==========================================
  // Reload Firebase user
  // ==========================================

  static Future<bool> reloadFirebaseUser() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      return false;
    }

    await user.reload();

    final refreshedUser = _firebaseAuth.currentUser;

    return refreshedUser?.emailVerified ?? false;
  }

  // ==========================================
  // Logout
  // ==========================================

  static Future<void> logout() async {
    // Remove MessageShield JWT.
    await TokenStorage.deleteToken();

    // Sign out from Firebase.
    await _firebaseAuth.signOut();
  }
}
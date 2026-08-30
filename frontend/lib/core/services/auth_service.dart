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
      throw _getAuthException(response);
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
      throw _getAuthException(response);
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
  // Firebase / Google LOGIN
  // ==========================================
  //
  // Existing MessageShield user only.
  //
  // Flow:
  //
  // Google/Firebase
  //        ↓
  // Firebase ID Token
  //        ↓
  // POST /auth/firebase/login
  //        ↓
  // Backend verifies user exists
  //        ↓
  // MessageShield JWT
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
      throw _getAuthException(response);
    }

    await _saveAccessToken(response);
  }

  // ==========================================
  // Firebase / Google REGISTER
  // ==========================================
  //
  // New MessageShield user.
  //
  // Flow:
  //
  // Google/Firebase
  //        ↓
  // Firebase ID Token
  //        ↓
  // POST /auth/firebase/register
  //        ↓
  // Backend creates MessageShield user
  //        ↓
  // MessageShield JWT
  // ==========================================

  static Future<void> registerWithFirebaseUser(
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
      ApiConstants.firebaseRegister,
      body: {
        'id_token': idToken,
      },
    );

    if (response.statusCode != 200 &&
        response.statusCode != 201) {
      throw _getAuthException(response);
    }

    await _saveAccessToken(response);
  }

  // ==========================================
  // Friendly authentication errors
  // ==========================================

  static Exception _getAuthException(
    dynamic response,
  ) {
    final backendMessage =
        ApiService.getErrorMessage(response);

    final originalMessage = backendMessage
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();

    final message =
        originalMessage.toLowerCase();

    // ------------------------------------------
    // Account already exists / Conflict
    // ------------------------------------------

    if (response.statusCode == 409 ||
        message.contains('already exists') ||
        message.contains('already registered') ||
        message.contains('email already') ||
        message.contains('email exists') ||
        message.contains('duplicate')) {
      return Exception(
        'An account with this email already exists. '
        'Please sign in instead.',
      );
    }

    // ------------------------------------------
    // Existing password account
    // ------------------------------------------

    if (message.contains('email and password')) {
      return Exception(
        'An account with this email already exists. '
        'Please sign in using email and password.',
      );
    }

    // ------------------------------------------
    // Google account identity conflict
    // ------------------------------------------

    if (message.contains('google account identity')) {
      return Exception(
        'This Google account is already registered. '
        'Please sign in instead.',
      );
    }

    // ------------------------------------------
    // Google/Firebase user not registered
    // ------------------------------------------

    if (response.statusCode == 404 ||
        message.contains('not registered') ||
        message.contains('no messageshield account') ||
        message.contains('no message shield account')) {
      return Exception(
        'No account was found for this Google account. '
        'Please create an account first.',
      );
    }

    // ------------------------------------------
    // Invalid credentials
    // ------------------------------------------

    if (response.statusCode == 401 ||
        message.contains('invalid credentials') ||
        message.contains('incorrect password')) {
      return Exception(
        'Invalid email or password.',
      );
    }

    // ------------------------------------------
    // Email verification required
    // ------------------------------------------

    if (message.contains('email not verified') ||
        message.contains('verify your email') ||
        message.contains('email verification')) {
      return Exception(
        'Please verify your email before signing in.',
      );
    }

    // ------------------------------------------
    // Inactive account
    // ------------------------------------------

    if (message.contains('inactive')) {
      return Exception(
        'Your account is currently inactive. '
        'Please contact support.',
      );
    }

    // ------------------------------------------
    // Password login unavailable
    // ------------------------------------------

    if (message.contains('password login') ||
        message.contains('password sign-in')) {
      return Exception(
        'This account uses Google sign-in. '
        'Please continue with Google.',
      );
    }

    // ------------------------------------------
    // Network / server errors
    // ------------------------------------------

    if (response.statusCode >= 500) {
      return Exception(
        'Something went wrong on the server. '
        'Please try again later.',
      );
    }

    if (message.contains('network') ||
        message.contains('socket') ||
        message.contains('connection')) {
      return Exception(
        'Unable to connect to the server. '
        'Please check your internet connection.',
      );
    }

    // ------------------------------------------
    // Default backend error
    // ------------------------------------------

    return Exception(
      originalMessage.isNotEmpty
          ? originalMessage
          : 'Authentication failed. Please try again.',
    );
  }

  // ==========================================
  // Save MessageShield JWT
  // ==========================================

  static Future<void> _saveAccessToken(
    dynamic response,
  ) async {
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
      throw _getAuthException(response);
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

    final refreshedUser =
        _firebaseAuth.currentUser;

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
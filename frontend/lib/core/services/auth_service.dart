import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

import '../../models/user.dart';
import '../constants/api_constants.dart';
import '../storage/token_storage.dart';
import 'api_service.dart';

class AuthService {
  AuthService._();

  static final firebase_auth.FirebaseAuth _firebaseAuth =
      firebase_auth.FirebaseAuth.instance;

  // ==========================================
  // Firebase / Email-password REGISTER
  // ==========================================
  //
  // Step 1:
  // Create Firebase account.
  //
  // Step 2:
  // Send Firebase verification email.
  //
  // IMPORTANT:
  // We DO NOT create the MessageShield account here.
  //
  // The user must first verify the email.
  //
  // After verification:
  // completeFirebaseRegistration()
  // creates the MessageShield account.
  // ==========================================

  // ==========================================
// Firebase / Email-password REGISTER
// ==========================================
//
// Step 1:
// Check whether the email already exists
// in MessageShield.
//
// Step 2:
// Firebase creates the user.
//
// Step 3:
// Firebase sends verification email.
//
// IMPORTANT:
// We DO NOT create the MessageShield account here.
//
// The user must first verify the email.
//
// After verification:
// completeFirebaseRegistration()
// creates the MessageShield account.
// ==========================================
// ==========================================
// Check whether email already exists
// ==========================================

  static Future<bool> checkEmailExists(
    String email,
  ) async {
    final response = await ApiService.post(
      ApiConstants.checkEmail,
      body: {
        'email': email.trim(),
      },
    );

    if (response.statusCode != 200) {
      throw _getAuthException(response);
    }

    final data = ApiService.decodeResponse(response) as Map<String, dynamic>;

    return data['exists'] == true;
  }

  static Future<firebase_auth.User> register({
    required String email,
    required String password,
  }) async {
    try {
      final normalizedEmail = email.trim();

      // ==========================================
      // 1. Check MessageShield database first
      // ==========================================

      final emailExists = await checkEmailExists(
        normalizedEmail,
      );

      if (emailExists) {
        throw Exception(
          'An account with this email already exists. '
          'Please sign in instead.',
        );
      }

      // ==========================================
      // 2. Create Firebase account
      // ==========================================

      final credential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to create Firebase account.',
        );
      }

      // ==========================================
      // 3. Send Firebase verification email
      // ==========================================

      if (!firebaseUser.emailVerified) {
        await firebaseUser.sendEmailVerification();
      }

      return firebaseUser;
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _firebaseAuthException(error);
    }
  }

  // ==========================================
  // Complete Firebase email registration
  // ==========================================
  //
  // Called AFTER the user verifies their email.
  //
  // Flow:
  //
  // Firebase verified user
  //        ↓
  // fresh Firebase ID token
  //        ↓
  // POST /auth/firebase/register
  //        ↓
  // MessageShield PostgreSQL user
  //        ↓
  // MessageShield JWT
  // ==========================================

  // ==========================================
// Complete Firebase email registration
// ==========================================
//
// Called AFTER the user verifies their email.
//
// Flow:
//
// Firebase verified user
//        ↓
// fresh Firebase ID token
//        ↓
// POST /auth/firebase/register
//        ↓
// MessageShield PostgreSQL user
//        ↓
// Registration complete
//
// IMPORTANT:
// We intentionally DO NOT save the
// MessageShield JWT here.
//
// Registration must finish at the Login screen.
// ==========================================

  static Future<void> completeFirebaseRegistration() async {
    final user = _firebaseAuth.currentUser;

    if (user == null) {
      throw Exception(
        'No Firebase user is signed in.',
      );
    }

    // Always reload before checking verification.
    await user.reload();

    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      throw Exception(
        'Unable to refresh Firebase user.',
      );
    }

    if (!refreshedUser.emailVerified) {
      throw Exception(
        'Please verify your email address before continuing.',
      );
    }

    // Force Firebase to issue a fresh token so the backend
    // receives the latest email_verified=true state.
    final idToken = await refreshedUser.getIdToken(true);

    if (idToken == null || idToken.isEmpty) {
      throw Exception(
        'Unable to get authentication token.',
      );
    }

    final response = await ApiService.post(
      ApiConstants.firebaseRegister,
      body: {
        'id_token': idToken,
      },
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw _getAuthException(response);
    }

    // IMPORTANT:
    //
    // Do NOT call:
    //
    //   _saveAccessToken(response);
    //
    // Registration is complete, but the user is NOT
    // logged into MessageShield yet.
  }

  // ==========================================
  // Legacy password REGISTER
  // ==========================================
  //
  // Kept temporarily for compatibility with
  // existing backend users.
  //
  // New email/password registration should use
  // Firebase through register().
  // ==========================================

  static Future<User> registerLegacyPasswordUser({
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

    final data = ApiService.decodeResponse(response) as Map<String, dynamic>;

    return User.fromJson(data);
  }

  // ==========================================
  // Firebase / Email-password LOGIN
  // ==========================================
  //
  // Firebase verifies:
  // - email
  // - password
  //
  // Then Firebase email verification is checked.
  //
  // Finally the Firebase ID token is exchanged
  // for a MessageShield JWT.
  // ==========================================

  static Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final firebaseUser = credential.user;

      if (firebaseUser == null) {
        throw Exception(
          'Unable to sign in.',
        );
      }

      // Firebase user data may be stale.
      await firebaseUser.reload();

      final refreshedUser = _firebaseAuth.currentUser;

      if (refreshedUser == null) {
        throw Exception(
          'Unable to refresh Firebase user.',
        );
      }

      // Email verification is mandatory.
      if (!refreshedUser.emailVerified) {
        throw Exception(
          'Please verify your email address before signing in.',
        );
      }

      final idToken = await refreshedUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Unable to get authentication token.',
        );
      }

      // Exchange Firebase authentication
      // for MessageShield JWT.
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
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _firebaseAuthException(error);
    }
  }

  // ==========================================
  // Legacy password LOGIN
  // ==========================================
  //
  // Kept temporarily for migration/testing of
  // old PostgreSQL password accounts.
  //
  // New login() uses Firebase.
  // ==========================================

  static Future<void> loginLegacyPasswordUser({
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

    await _saveAccessToken(response);
  }

  // ==========================================
  // Firebase / Google LOGIN
  // ==========================================
  //
  // Existing MessageShield user only.
  //
  // Google/Firebase
  //        ↓
  // Firebase ID Token
  //        ↓
  // POST /auth/firebase/login
  //        ↓
  // MessageShield JWT
  // ==========================================

  static Future<void> loginWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Unable to get authentication token.',
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
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _firebaseAuthException(error);
    }
  }

  // ==========================================
  // Firebase / Google REGISTER
  // ==========================================
  //
  // New MessageShield user.
  //
  // Google/Firebase
  //        ↓
  // Firebase ID Token
  //        ↓
  // POST /auth/firebase/register
  //        ↓
  // MessageShield JWT
  // ==========================================

  static Future<void> registerWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    try {
      final idToken = await firebaseUser.getIdToken();

      if (idToken == null || idToken.isEmpty) {
        throw Exception(
          'Unable to get authentication token.',
        );
      }

      final response = await ApiService.post(
        ApiConstants.firebaseRegister,
        body: {
          'id_token': idToken,
        },
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw _getAuthException(response);
      }

      await _saveAccessToken(response);
    } on firebase_auth.FirebaseAuthException catch (error) {
      throw _firebaseAuthException(error);
    }
  }

  // ==========================================
  // Firebase Auth errors
  // ==========================================

  static Exception _firebaseAuthException(
    firebase_auth.FirebaseAuthException error,
  ) {
    switch (error.code) {
      case 'email-already-in-use':
        return Exception(
          'An account with this email already exists. '
          'Please sign in instead.',
        );

      case 'invalid-email':
        return Exception(
          'Please enter a valid email address.',
        );

      case 'weak-password':
        return Exception(
          'Your password is too weak. '
          'Please choose a stronger password.',
        );

      case 'user-not-found':
        return Exception(
          'No account was found with this email address.',
        );

      case 'wrong-password':
      case 'invalid-credential':
        return Exception(
          'Invalid email or password.',
        );

      case 'user-disabled':
        return Exception(
          'This account has been disabled. '
          'Please contact support.',
        );

      case 'too-many-requests':
        return Exception(
          'Too many authentication attempts. '
          'Please try again later.',
        );

      case 'network-request-failed':
        return Exception(
          'Unable to connect to Firebase. '
          'Please check your internet connection.',
        );

      default:
        return Exception(
          error.message ??
              'Firebase authentication failed. '
                  'Please try again.',
        );
    }
  }

  // ==========================================
  // Friendly backend authentication errors
  // ==========================================

  static Exception _getAuthException(
    dynamic response,
  ) {
    final backendMessage = ApiService.getErrorMessage(response);

    final originalMessage = backendMessage
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();

    final message = originalMessage.toLowerCase();

    // ------------------------------------------
    // Account already exists
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

    if (message.contains('google account identity') ||
        message.contains('firebase account identity')) {
      return Exception(
        'This account is already registered. '
        'Please sign in instead.',
      );
    }

    // ------------------------------------------
    // Firebase user not registered
    // ------------------------------------------

    if (response.statusCode == 404 ||
        message.contains('not registered') ||
        message.contains('account not found') ||
        message.contains('no messageshield account') ||
        message.contains('no message shield account')) {
      return Exception(
        'No MessageShield account was found. '
        'Please create an account first.',
      );
    }

    // ------------------------------------------
    // Invalid credentials
    // ------------------------------------------

    if (response.statusCode == 401 ||
        message.contains('invalid credentials') ||
        message.contains('incorrect password') ||
        message.contains('invalid email or password')) {
      return Exception(
        'Invalid email or password.',
      );
    }

    // ------------------------------------------
    // Email verification required
    // ------------------------------------------

    if (message.contains('email not verified') ||
        message.contains('verify your email') ||
        message.contains('email verification') ||
        message.contains('before continuing') ||
        message.contains('before signing in')) {
      return Exception(
        'Please verify your email address before continuing.',
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
    final data = ApiService.decodeResponse(response) as Map<String, dynamic>;

    final token = data['access_token'];

    if (token == null || token is! String) {
      throw Exception(
        'Invalid authentication response.',
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

    final data = ApiService.decodeResponse(response) as Map<String, dynamic>;

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
        'No Firebase user is signed in.',
      );
    }

    await user.reload();

    final refreshedUser = _firebaseAuth.currentUser;

    if (refreshedUser == null) {
      throw Exception(
        'Unable to refresh Firebase user.',
      );
    }

    if (refreshedUser.emailVerified) {
      return;
    }

    await refreshedUser.sendEmailVerification();
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

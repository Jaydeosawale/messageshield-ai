import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;

  bool _isLoading = false;
  bool _isInitialized = false;

  String? _error;

  // ==========================================
  // Getters
  // ==========================================

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _user != null;

  String? get error => _error;

  // ==========================================
  // Initialize app session
  // ==========================================
  //
  // MessageShield JWT is the local application
  // session.
  //
  // Firebase is NOT used here to authorize
  // MessageShield API access.
  // ==========================================

  Future<void> initialize() async {
    if (_isInitialized) return;

    _isLoading = true;
    _error = null;

    notifyListeners();

    try {
      final token = await TokenStorage.getToken();

      // No MessageShield JWT.
      if (token == null || token.trim().isEmpty) {
        _user = null;
        return;
      }

      // Verify MessageShield JWT with backend.
      _user = await AuthService.getCurrentUser();
    } catch (_) {
      // Invalid or expired MessageShield JWT.
      await TokenStorage.deleteToken();

      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;

      notifyListeners();
    }
  }

  // ==========================================
  // Email / Password REGISTER
  // ==========================================
  //
  // Step 1:
  // Firebase creates the user.
  //
  // Step 2:
  // Firebase sends verification email.
  //
  // IMPORTANT:
  // MessageShield PostgreSQL user is NOT created
  // yet.
  //
  // The user must verify the email first.
  // ==========================================

  Future<void> register({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.register(
        email: email,
        password: password,
      );

      // No MessageShield JWT yet.
      _user = null;

      notifyListeners();
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Verify email + complete registration
  // ==========================================
  //
  // Called after the user clicks the Firebase
  // verification link.
  //
  // Flow:
  //
  // Firebase email verified
  //        ↓
  // Reload Firebase user
  //        ↓
  // Firebase ID token
  //        ↓
  // POST /auth/firebase/register
  //        ↓
  // PostgreSQL MessageShield user
  //        ↓
  // MessageShield JWT
  //        ↓
  // /auth/me
  // ==========================================

  // ==========================================
// Verify email and complete registration
// ==========================================
//
// Flow:
//
// Firebase email verified
//        ↓
// Reload Firebase user
//        ↓
// POST /auth/firebase/register
//        ↓
// MessageShield account created/synchronized
//        ↓
// NO MessageShield login
//        ↓
// Caller navigates to LoginScreen
// ==========================================

  Future<bool> verifyEmailAndCompleteRegistration() async {
    _setLoading(true);

    try {
      _error = null;

      // ----------------------------------------
      // 1. Refresh Firebase user.
      // ----------------------------------------

      final verified = await AuthService.reloadFirebaseUser();

      // ----------------------------------------
      // 2. User has not verified email yet.
      // ----------------------------------------

      if (!verified) {
        _error = 'Please verify your email address first.';

        notifyListeners();

        return false;
      }

      // ----------------------------------------
      // 3. Complete MessageShield registration.
      // ----------------------------------------
      //
      // This creates/synchronizes the DB account.
      //
      // IMPORTANT:
      // This does NOT create a MessageShield
      // authenticated session.
      // ----------------------------------------

      await AuthService.completeFirebaseRegistration();

      // ----------------------------------------
      // 4. Registration succeeded.
      //
      // Do not load /auth/me.
      // Do not populate _user.
      // Do not keep a JWT.
      // ----------------------------------------

      await TokenStorage.deleteToken();

      _user = null;
      _error = null;

      notifyListeners();

      return true;
    } catch (error) {
      // Never leave a partial MessageShield session.
      await TokenStorage.deleteToken();

      _user = null;

      _error = _cleanError(error);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Email / Password LOGIN
  // ==========================================
  //
  // Firebase:
  //
  // email + password
  //        ↓
  // emailVerified
  //        ↓
  // Firebase ID token
  //
  // Backend:
  //
  // Firebase ID token
  //        ↓
  // MessageShield account lookup
  //        ↓
  // MessageShield JWT
  // ==========================================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.login(
        email: email,
        password: password,
      );

      // MessageShield JWT now exists.
      _user = await AuthService.getCurrentUser();

      notifyListeners();
    } catch (error) {
      // Never keep an invalid/partial JWT.
      await TokenStorage.deleteToken();

      _user = null;

      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Firebase / Google LOGIN
  // ==========================================
  //
  // Existing MessageShield user only.
  //
  // Google
  //   ↓
  // Firebase
  //   ↓
  // Firebase ID token
  //   ↓
  // /auth/firebase/login
  //   ↓
  // MessageShield JWT
  // ==========================================

  Future<void> loginWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.loginWithFirebaseUser(
        firebaseUser,
      );

      // Load MessageShield user.
      _user = await AuthService.getCurrentUser();

      notifyListeners();
    } catch (error) {
      await TokenStorage.deleteToken();

      _user = null;

      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Firebase / Google REGISTER
  // ==========================================
  //
  // Google
  //   ↓
  // Firebase
  //   ↓
  // Firebase ID token
  //   ↓
  // /auth/firebase/register
  //   ↓
  // MessageShield user
  //   ↓
  // MessageShield JWT
  // ==========================================

  Future<void> registerWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.registerWithFirebaseUser(
        firebaseUser,
      );

      // Backend returned MessageShield JWT.
      _user = await AuthService.getCurrentUser();

      notifyListeners();
    } catch (error) {
      await TokenStorage.deleteToken();

      _user = null;

      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Send Firebase email verification
  // ==========================================

  Future<void> sendFirebaseVerificationEmail() async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.sendEmailVerification();

      notifyListeners();
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Check Firebase email verification
  // ==========================================
  //
  // Returns:
  //
  // true  -> verified
  // false -> not verified
  // ==========================================

  Future<bool> checkFirebaseEmailVerification() async {
    _setLoading(true);

    try {
      _error = null;

      final verified = await AuthService.reloadFirebaseUser();

      notifyListeners();

      return verified;
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Firebase user
  // ==========================================

  firebase_auth.User? get firebaseUser {
    return AuthService.firebaseUser;
  }

  // ==========================================
  // Refresh current MessageShield user
  // ==========================================

  Future<void> refreshUser() async {
    try {
      _user = await AuthService.getCurrentUser();

      _error = null;

      notifyListeners();
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();
    }
  }
  // ==========================================
// Clear authentication session
// ==========================================
//
// Used after successful registration when
// the user should continue to LoginScreen.
//

  Future<void> clearAuthenticationSession() async {
    try {
      await AuthService.logout();

      _user = null;
      _error = null;
    } finally {
      notifyListeners();
    }
  }
  // ==========================================
  // Logout
  // ==========================================
  //
  // Removes:
  // 1. MessageShield JWT
  // 2. Firebase session
  // ==========================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      await AuthService.logout();

      _user = null;
      _error = null;
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Clear error
  // ==========================================

  void clearError() {
    if (_error == null) return;

    _error = null;

    notifyListeners();
  }

  // ==========================================
  // Helpers
  // ==========================================

  void _setLoading(bool value) {
    _isLoading = value;

    notifyListeners();
  }

  String _cleanError(Object error) {
    return error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        )
        .trim();
  }
}

import 'package:firebase_auth/firebase_auth.dart'
    as firebase_auth;
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

      // Verify token with backend.
      _user = await AuthService.getCurrentUser();
    } catch (_) {
      // Invalid or expired JWT.
      await TokenStorage.deleteToken();

      _user = null;
    } finally {
      _isLoading = false;
      _isInitialized = true;

      notifyListeners();
    }
  }

  // ==========================================
  // Register
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
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Email/password login
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
  // Firebase / Google login
  // ==========================================

  Future<void> loginWithFirebaseUser(
    firebase_auth.User firebaseUser,
  ) async {
    _setLoading(true);

    try {
      _error = null;

      // Send verified Firebase ID token
      // to MessageShield backend.
      await AuthService.loginWithFirebaseUser(
        firebaseUser,
      );

      // Get local MessageShield user.
      _user = await AuthService.getCurrentUser();

      notifyListeners();
    } catch (error) {
      // Important:
      // Backend authentication failed,
      // so remove local MessageShield JWT.
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
  // Refresh current user
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
  // Firebase email verification
  // ==========================================

  Future<void> sendFirebaseVerificationEmail() async {
    _setLoading(true);

    try {
      _error = null;

      await AuthService.sendEmailVerification();
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

  Future<bool> checkFirebaseEmailVerification() async {
    _setLoading(true);

    try {
      _error = null;

      return await AuthService.reloadFirebaseUser();
    } catch (error) {
      _error = _cleanError(error);

      notifyListeners();

      return false;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Logout
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
        );
  }
}

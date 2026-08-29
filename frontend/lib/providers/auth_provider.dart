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

      // No token -> user is not logged in.
      if (token == null || token.trim().isEmpty) {
        _user = null;
        return;
      }

      // Token exists -> verify with backend.
      _user = await AuthService.getCurrentUser();
    } catch (_) {
      // Invalid or expired token.
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
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  // ==========================================
  // Login
  // ==========================================

  Future<void> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);

    try {
      _error = null;

      // Login saves JWT token.
      await AuthService.login(
        email: email,
        password: password,
      );

      // Verify token and get logged-in user.
      _user = await AuthService.getCurrentUser();

      notifyListeners();
    } catch (error) {
      // Remove invalid/partial token.
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
  // Logout
  // ==========================================

  Future<void> logout() async {
    _setLoading(true);

    try {
      // Clear local JWT token.
      await TokenStorage.deleteToken();

      _user = null;
      _error = null;
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
        .replaceFirst('Exception: ', '');
  }
}
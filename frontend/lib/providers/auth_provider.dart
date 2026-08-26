import 'package:flutter/material.dart';

import '../core/services/auth_service.dart';
import '../core/storage/token_storage.dart';
import '../models/user.dart';

class AuthProvider extends ChangeNotifier {
  User? _user;
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;

  User? get user => _user;

  bool get isLoading => _isLoading;

  bool get isInitialized => _isInitialized;

  bool get isAuthenticated => _user != null;

  String? get error => _error;

  // Restore session when app starts
  Future<void> initialize() async {
    _setLoading(true);

    try {
      final token = await TokenStorage.getToken();

      if (token != null && token.isNotEmpty) {
        _user = await AuthService.getCurrentUser();
      }
    } catch (_) {
      await TokenStorage.deleteToken();
      _user = null;
    } finally {
      _isInitialized = true;
      _isLoading = false;
      notifyListeners();
    }
  }

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
      _error = error.toString().replaceFirst(
        'Exception: ',
        '',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

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
      _error = error.toString().replaceFirst(
        'Exception: ',
        '',
      );
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);

    try {
      await AuthService.logout();
      _user = null;
      _error = null;
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }
}
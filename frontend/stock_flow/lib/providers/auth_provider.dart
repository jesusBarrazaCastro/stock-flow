import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isAuthenticated = false;
  bool _isLoading = true;
  Map<String, dynamic>? _currentUser;

  bool get isAuthenticated => _isAuthenticated;
  bool get isLoading => _isLoading;
  Map<String, dynamic>? get currentUser => _currentUser;
  bool get isAdmin => _currentUser?['rol_nombre'] == 'Admin';

  AuthProvider() {
    checkAuthStatus();
  }

  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    _currentUser = await _authService.getCurrentUser();
    _isAuthenticated = _currentUser != null;

    _isLoading = false;
    notifyListeners();
  }

  // Returns null on success, error message on failure.
  Future<String?> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.login(email, password);
    if (error == null) {
      await checkAuthStatus();
      return null;
    }

    _isLoading = false;
    notifyListeners();
    return error;
  }

  // Returns null on success, error message on failure.
  Future<String?> register(
      String nombre, String negocio, String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final error = await _authService.register(nombre, negocio, email, password);

    _isLoading = false;
    notifyListeners();
    return error;
  }

  Future<void> logout() async {
    await _authService.logout();
    _isAuthenticated = false;
    _currentUser = null;
    notifyListeners();
  }
}

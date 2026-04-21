import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../core/network/api_client.dart';

class AuthService {
  static const _storage = FlutterSecureStorage();
  final ApiClient _api = ApiClient.instance;

  // Returns null on success, error message on failure.
  Future<String?> login(String email, String password) async {
    try {
      final response = await _api.postUrlEncoded('/auth/login', body: {
        'username': email,
        'password': password,
      });

      debugPrint('[AuthService.login] status=${response.statusCode}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        await _storage.write(key: 'jwt', value: data['access_token']);
        return null;
      }

      return _extractErrorMessage(response.body, 'Error al iniciar sesión');
    } catch (err) {
      debugPrint('[AuthService.login] exception: $err');
      return 'Error de conexión. Verifica tu red.';
    }
  }

  // Returns null on success, error message on failure.
  Future<String?> register(
      String nombre, String negocio, String email, String password) async {
    try {
      final Map<String, dynamic> body = {
        'nombre': nombre,
        'negocio': negocio,
        'email': email,
        'password': password,
      };

      final response = await _api.post('/auth/register', body: body);

      debugPrint('[AuthService.register] status=${response.statusCode} body=${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        return null;
      }

      return _extractErrorMessage(response.body, 'Error al crear la cuenta');
    } catch (err) {
      debugPrint('[AuthService.register] exception: $err');
      return 'Error de conexión. Verifica tu red.';
    }
  }

  Future<void> logout() async {
    await _storage.delete(key: 'jwt');
  }

  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final response = await _api.get('/auth/me');
      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      }
      return null;
    } catch (err) {
      return null;
    }
  }

  Future<bool> isTokenValid() async {
    final user = await getCurrentUser();
    return user != null;
  }

  /// Safely extracts a human-readable message from a FastAPI error response body.
  /// FastAPI can return {"detail": "string"} or {"detail": [{...}]}.
  String _extractErrorMessage(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) {
        final detail = decoded['detail'];
        if (detail is List && detail.isNotEmpty) {
          final first = detail.first;
          if (first is Map) return first['msg']?.toString() ?? fallback;
          return first.toString();
        }
        return detail?.toString() ?? fallback;
      }
    } catch (_) {
      // body was not valid JSON (e.g. HTML error page)
    }
    return fallback;
  }
}

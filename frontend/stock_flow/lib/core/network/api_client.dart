import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiClient {
  static const _storage = FlutterSecureStorage();
  
  // Singleton
  ApiClient._privateConstructor();
  static final ApiClient instance = ApiClient._privateConstructor();

  String get baseUrl {
    // Si estás en iOS/Mac o Web localmente, localhost sirve.
    // Si usas el emulador de Android usa 10.0.2.2 en lugar de localhost en el .env
    return dotenv.env['API_URL'] ?? 'http://localhost:8000/api';
  }

  Future<Map<String, String>> _getHeaders() async {
    final token = await _storage.read(key: 'jwt');
    if (token != null) {
      return {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      };
    }
    return {
      'Content-Type': 'application/json',
    };
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.get(Uri.parse('$baseUrl$endpoint'), headers: headers);
    _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> post(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> postUrlEncoded(String endpoint, {required Map<String, String> body}) async {
    Map<String, String> headers = await _getHeaders();
    headers['Content-Type'] = 'application/x-www-form-urlencoded';
    final response = await http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body,
    );
    _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> put(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.put(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> patch(String endpoint, {Map<String, dynamic>? body}) async {
    final headers = await _getHeaders();
    final response = await http.patch(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
    _checkUnauthorized(response);
    return response;
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    final response = await http.delete(Uri.parse('$baseUrl$endpoint'), headers: headers);
    _checkUnauthorized(response);
    return response;
  }

  void _checkUnauthorized(http.Response response) {
    // Si el backend retorna 401, podríamos disparar una notificación 
    // para cerrar la sesión a nivel global aquí.
    if (response.statusCode == 401) {
      print("Token inválido o expirado. Cerrar sesión...");
      // Puedes usar un StreamController o un EventBus para avisarle a la app que desloguee.
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

class SettingsService {
  final ApiClient _api = ApiClient.instance;

  Future<String?> updatePerfil(String nombreCompleto, String? telefono) async {
    try {
      final response = await _api.put('/settings/perfil', body: {
        'nombre_completo': nombreCompleto,
        if (telefono != null) 'telefono': telefono,
      });
      if (response.statusCode == 200) return null;
      return _extractError(response.body, 'Error al actualizar perfil');
    } catch (e) {
      debugPrint('[SettingsService.updatePerfil] $e');
      return 'Error de conexión. Verifica tu red.';
    }
  }

  Future<Map<String, dynamic>?> getEmpresa() async {
    try {
      final response = await _api.get('/settings/empresa');
      if (response.statusCode == 200) return jsonDecode(response.body);
      return null;
    } catch (e) {
      debugPrint('[SettingsService.getEmpresa] $e');
      return null;
    }
  }

  Future<String?> updateEmpresa(Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/settings/empresa', body: data);
      if (response.statusCode == 200) return null;
      return _extractError(response.body, 'Error al actualizar empresa');
    } catch (e) {
      debugPrint('[SettingsService.updateEmpresa] $e');
      return 'Error de conexión. Verifica tu red.';
    }
  }

  String _extractError(String body, String fallback) {
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map) return decoded['detail']?.toString() ?? fallback;
    } catch (_) {}
    return fallback;
  }
}

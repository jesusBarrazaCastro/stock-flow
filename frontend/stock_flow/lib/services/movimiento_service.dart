import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class AlmacenItem {
  final int id;
  final String nombre;
  final String? direccion;
  final int? capacidadMaxima;

  const AlmacenItem({
    required this.id,
    required this.nombre,
    this.direccion,
    this.capacidadMaxima,
  });

  factory AlmacenItem.fromJson(Map<String, dynamic> j) => AlmacenItem(
        id: j['id'],
        nombre: j['nombre'],
        direccion: j['direccion'],
        capacidadMaxima: (j['capacidad_maxima'] as num?)?.toInt(),
      );
}

class MovimientoRegistroRequest {
  final int productoId;
  final int? almacenId;
  final String tipo; // 'ENTRADA' | 'SALIDA'
  final int cantidad;
  final double? precioUnitario;
  final int? proveedorId;
  final String? notas;
  final DateTime? fecha;
  final DateTime? fechaCaducidad;
  final int? loteEntradaId;

  const MovimientoRegistroRequest({
    required this.productoId,
    this.almacenId,
    required this.tipo,
    required this.cantidad,
    this.precioUnitario,
    this.proveedorId,
    this.notas,
    this.fecha,
    this.fechaCaducidad,
    this.loteEntradaId,
  });

  Map<String, dynamic> toJson() => {
        'producto_id': productoId,
        if (almacenId != null) 'almacen_id': almacenId,
        'tipo': tipo,
        'cantidad': cantidad,
        if (precioUnitario != null) 'precio_unitario': precioUnitario,
        if (proveedorId != null) 'proveedor_id': proveedorId,
        if (notas != null && notas!.isNotEmpty) 'notas': notas,
        if (fecha != null) 'fecha': fecha!.toIso8601String(),
        if (fechaCaducidad != null)
          'fecha_caducidad':
              '${fechaCaducidad!.year.toString().padLeft(4, '0')}-'
              '${fechaCaducidad!.month.toString().padLeft(2, '0')}-'
              '${fechaCaducidad!.day.toString().padLeft(2, '0')}',
        if (loteEntradaId != null) 'lote_entrada_id': loteEntradaId,
      };
}

class MovimientoRegistroResult {
  final bool ok;
  final int movimientoId;
  final int stockNuevo;

  const MovimientoRegistroResult({
    required this.ok,
    required this.movimientoId,
    required this.stockNuevo,
  });

  factory MovimientoRegistroResult.fromJson(Map<String, dynamic> j) =>
      MovimientoRegistroResult(
        ok: j['ok'] ?? false,
        movimientoId: (j['movimiento_id'] as num).toInt(),
        stockNuevo: (j['stock_nuevo'] as num).toInt(),
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class MovimientoService {
  final ApiClient _api = ApiClient.instance;

  /// Registra un movimiento de inventario (ENTRADA o SALIDA).
  Future<MovimientoRegistroResult> registrarMovimiento(
      MovimientoRegistroRequest req) async {
    try {
      final response = await _api.post(
        '/movimientos/registrar',
        body: req.toJson(),
      );
      if (response.statusCode == 200) {
        return MovimientoRegistroResult.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      final body = jsonDecode(response.body) as Map<String, dynamic>?;
      throw Exception(body?['detail'] ?? 'Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[MovimientoService.registrarMovimiento] $e');
      rethrow;
    }
  }

  Future<void> updateCaducidad(int movimientoId, DateTime nuevaFecha) async {
    try {
      final body = {
        'nueva_fecha':
            '${nuevaFecha.year.toString().padLeft(4, '0')}-'
            '${nuevaFecha.month.toString().padLeft(2, '0')}-'
            '${nuevaFecha.day.toString().padLeft(2, '0')}',
      };
      final response = await _api.patch(
        '/movimientos/$movimientoId/caducidad',
        body: body,
      );
      if (response.statusCode != 200) {
        final b = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(b?['detail'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[MovimientoService.updateCaducidad] $e');
      rethrow;
    }
  }

  /// Obtiene los almacenes activos de la empresa del usuario en sesión.
  Future<List<AlmacenItem>> getAlmacenes() async {
    try {
      final response = await _api.get('/settings/almacenes');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>)
            .map((e) => AlmacenItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[MovimientoService.getAlmacenes] $e');
      rethrow;
    }
  }
}

import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class DashboardKpis {
  final int inventarioTotalUnidades;
  final int totalProductos;
  final int totalAlmacenes;
  final int capacidadTotal;

  const DashboardKpis({
    required this.inventarioTotalUnidades,
    required this.totalProductos,
    required this.totalAlmacenes,
    required this.capacidadTotal,
  });

  factory DashboardKpis.fromJson(Map<String, dynamic> j) => DashboardKpis(
        inventarioTotalUnidades:
            (j['inventario_total_unidades'] as num?)?.toInt() ?? 0,
        totalProductos: (j['total_productos'] as num?)?.toInt() ?? 0,
        totalAlmacenes: (j['total_almacenes'] as num?)?.toInt() ?? 0,
        capacidadTotal: (j['capacidad_total'] as num?)?.toInt() ?? 0,
      );
}

class ActividadItem {
  final int id;
  final String tipoMovimiento;
  final int cantidad;
  final DateTime fechaMovimiento;
  final String? productoNombre;
  final String? almacenNombre;

  const ActividadItem({
    required this.id,
    required this.tipoMovimiento,
    required this.cantidad,
    required this.fechaMovimiento,
    this.productoNombre,
    this.almacenNombre,
  });

  factory ActividadItem.fromJson(Map<String, dynamic> j) => ActividadItem(
        id: j['id'],
        tipoMovimiento: j['tipo_movimiento'] ?? '',
        cantidad: (j['cantidad'] as num?)?.toInt() ?? 0,
        fechaMovimiento:
            DateTime.tryParse(j['fecha_movimiento'] ?? '')?.toLocal() ??
                DateTime.now(),
        productoNombre: j['producto_nombre'],
        almacenNombre: j['almacen_nombre'],
      );

  String get timeAgo {
    final diff = DateTime.now().difference(fechaMovimiento);
    if (diff.inSeconds < 60) return 'AHORA';
    if (diff.inMinutes < 60) return 'HACE ${diff.inMinutes}MIN';
    if (diff.inHours < 24) return 'HACE ${diff.inHours}H';
    return 'HACE ${diff.inDays}D';
  }
}

class InsightsDia {
  final String fecha;
  final int total;

  const InsightsDia({required this.fecha, required this.total});

  factory InsightsDia.fromJson(Map<String, dynamic> j) => InsightsDia(
        fecha: j['fecha'] ?? '',
        total: (j['total'] as num?)?.toInt() ?? 0,
      );
}

class DashboardInsights {
  final bool sinDatos;
  final String? productoNombre;
  final double? pctCambio;
  final List<InsightsDia> dias;

  const DashboardInsights({
    required this.sinDatos,
    this.productoNombre,
    this.pctCambio,
    required this.dias,
  });

  factory DashboardInsights.fromJson(Map<String, dynamic> j) {
    if (j['sin_datos'] == true) {
      return const DashboardInsights(sinDatos: true, dias: []);
    }
    return DashboardInsights(
      sinDatos: false,
      productoNombre: j['producto_nombre'],
      pctCambio: (j['pct_cambio'] as num?)?.toDouble(),
      dias: (j['dias'] as List<dynamic>? ?? [])
          .map((e) => InsightsDia.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class DashboardService {
  final ApiClient _api = ApiClient.instance;

  Future<DashboardKpis> getKpis() async {
    try {
      final response = await _api.get('/dashboard/kpis');
      if (response.statusCode == 200) {
        return DashboardKpis.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[DashboardService.getKpis] $e');
      rethrow;
    }
  }

  Future<List<ActividadItem>> getActividad({int limit = 5}) async {
    try {
      final response = await _api.get('/dashboard/actividad?limit=$limit');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>)
            .map((e) => ActividadItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[DashboardService.getActividad] $e');
      rethrow;
    }
  }

  Future<DashboardInsights> getInsights() async {
    try {
      final response = await _api.get('/dashboard/insights');
      if (response.statusCode == 200) {
        return DashboardInsights.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[DashboardService.getInsights] $e');
      rethrow;
    }
  }
}

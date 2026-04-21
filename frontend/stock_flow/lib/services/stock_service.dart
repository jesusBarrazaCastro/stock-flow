import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

// ─────────────────────────────────────────────────────────────────────────────
// MODELOS
// ─────────────────────────────────────────────────────────────────────────────

class StockCategoriaItem {
  final int id;
  final String nombre;
  final String? colorHex;

  const StockCategoriaItem({
    required this.id,
    required this.nombre,
    this.colorHex,
  });

  factory StockCategoriaItem.fromJson(Map<String, dynamic> j) =>
      StockCategoriaItem(
        id: j['id'],
        nombre: j['nombre'],
        colorHex: j['color_hex'],
      );
}

class StockItem {
  final int id;
  final String nombre;
  final String sku;
  final String? categoriaNombre;
  final String? categoriaColor;
  final int? categoriaId;
  final int stockTotal;
  final int stockMinimo;
  final int? stockMaximo;
  final String estadoStock;
  final String unidadMedida;
  final double precioUnitario;

  const StockItem({
    required this.id,
    required this.nombre,
    required this.sku,
    this.categoriaNombre,
    this.categoriaColor,
    this.categoriaId,
    required this.stockTotal,
    required this.stockMinimo,
    this.stockMaximo,
    required this.estadoStock,
    required this.unidadMedida,
    required this.precioUnitario,
  });

  factory StockItem.fromJson(Map<String, dynamic> j) => StockItem(
        id: j['id'],
        nombre: j['nombre'],
        sku: j['sku'],
        categoriaNombre: j['categoria_nombre'],
        categoriaColor: j['categoria_color'],
        categoriaId: j['categoria_id'],
        stockTotal: (j['stock_total'] as num?)?.toInt() ?? 0,
        stockMinimo: (j['stock_minimo'] as num?)?.toInt() ?? 0,
        stockMaximo: (j['stock_maximo'] as num?)?.toInt(),
        estadoStock: j['estado_stock'] ?? 'AGOTADO',
        unidadMedida: j['unidad_medida'] ?? 'unidad',
        precioUnitario: (j['precio_unitario'] as num?)?.toDouble() ?? 0.0,
      );
}

// ─────────────────────────────────────────────────────────────────────────────
// SERVICE
// ─────────────────────────────────────────────────────────────────────────────

class StockService {
  final ApiClient _api = ApiClient.instance;

  /// Obtiene el listado completo de stock de la empresa en sesión.
  /// Soporta búsqueda por nombre/SKU y filtro por categoría.
  /// El filtrado por estado_stock se realiza en el cliente dentro del Provider.
  Future<List<StockItem>> getStock({
    String? search,
    int? categoriaId,
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final params = <String, String>{
        'sort': 'newest',
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoriaId != null) 'categoria_id': '$categoriaId',
      };
      final query = Uri(queryParameters: params).query;
      final response = await _api.get('/productos/catalogo?$query');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final items = data['items'] as List<dynamic>? ?? [];
        return items
            .map((e) => StockItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[StockService.getStock] $e');
      rethrow;
    }
  }

  /// Obtiene las categorías de la empresa para los filtros avanzados.
  Future<List<StockCategoriaItem>> getCategorias() async {
    try {
      final response = await _api.get('/productos/categorias');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>)
            .map((e) =>
                StockCategoriaItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[StockService.getCategorias] $e');
      rethrow;
    }
  }
}

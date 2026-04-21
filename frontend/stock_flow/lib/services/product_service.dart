import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

class CategoriaItem {
  final int id;
  final String nombre;
  final String? colorHex;

  const CategoriaItem({required this.id, required this.nombre, this.colorHex});

  factory CategoriaItem.fromJson(Map<String, dynamic> j) => CategoriaItem(
        id: j['id'],
        nombre: j['nombre'],
        colorHex: j['color_hex'],
      );
}

class CatalogoProducto {
  final int id;
  final String nombre;
  final String sku;
  final String? descripcion;
  final double precioUnitario;
  final String? imagenUrl;
  final String unidadMedida;
  final int stockMinimo;
  final int? stockMaximo;
  final String? registroFecha;
  final int? categoriaId;
  final String? categoriaNombre;
  final String? categoriaColor;
  final int? proveedorId;
  final String? proveedorNombre;
  final int stockTotal;
  final String estadoStock;

  const CatalogoProducto({
    required this.id,
    required this.nombre,
    required this.sku,
    this.descripcion,
    required this.precioUnitario,
    this.imagenUrl,
    required this.unidadMedida,
    required this.stockMinimo,
    this.stockMaximo,
    this.registroFecha,
    this.categoriaId,
    this.categoriaNombre,
    this.categoriaColor,
    this.proveedorId,
    this.proveedorNombre,
    required this.stockTotal,
    required this.estadoStock,
  });

  factory CatalogoProducto.fromJson(Map<String, dynamic> j) => CatalogoProducto(
        id: j['id'],
        nombre: j['nombre'],
        sku: j['sku'],
        descripcion: j['descripcion'],
        precioUnitario: (j['precio_unitario'] as num?)?.toDouble() ?? 0.0,
        imagenUrl: j['imagen_url'],
        unidadMedida: j['unidad_medida'] ?? 'unidad',
        stockMinimo: (j['stock_minimo'] as num?)?.toInt() ?? 0,
        stockMaximo: (j['stock_maximo'] as num?)?.toInt(),
        registroFecha: j['registro_fecha']?.toString(),
        categoriaId: j['categoria_id'],
        categoriaNombre: j['categoria_nombre'],
        categoriaColor: j['categoria_color'],
        proveedorId: j['proveedor_id'],
        proveedorNombre: j['proveedor_nombre'],
        stockTotal: (j['stock_total'] as num?)?.toInt() ?? 0,
        estadoStock: j['estado_stock'] ?? 'AGOTADO',
      );
}

class MovimientoReciente {
  final int id;
  final String tipoMovimiento;
  final int cantidad;
  final double? precioUnitario;
  final String? fechaMovimiento;
  final String? notas;
  final String metodoRegistro;
  final String? almacenNombre;
  final String? usuarioNombre;

  const MovimientoReciente({
    required this.id,
    required this.tipoMovimiento,
    required this.cantidad,
    this.precioUnitario,
    this.fechaMovimiento,
    this.notas,
    required this.metodoRegistro,
    this.almacenNombre,
    this.usuarioNombre,
  });

  factory MovimientoReciente.fromJson(Map<String, dynamic> j) =>
      MovimientoReciente(
        id: j['id'],
        tipoMovimiento: j['tipo_movimiento'],
        cantidad: (j['cantidad'] as num).toInt(),
        precioUnitario: (j['precio_unitario'] as num?)?.toDouble(),
        fechaMovimiento: j['fecha_movimiento']?.toString(),
        notas: j['notas'],
        metodoRegistro: j['metodo_registro'] ?? 'MANUAL',
        almacenNombre: j['almacen_nombre'],
        usuarioNombre: j['usuario_nombre'],
      );
}

class ProductoDetalle extends CatalogoProducto {
  final int? almacenId;
  final String? ubicacionFisica;
  final String? almacenNombre;
  final List<MovimientoReciente> movimientosRecientes;

  const ProductoDetalle({
    required super.id,
    required super.nombre,
    required super.sku,
    super.descripcion,
    required super.precioUnitario,
    super.imagenUrl,
    required super.unidadMedida,
    required super.stockMinimo,
    super.stockMaximo,
    super.registroFecha,
    super.categoriaId,
    super.categoriaNombre,
    super.categoriaColor,
    super.proveedorId,
    super.proveedorNombre,
    required super.stockTotal,
    required super.estadoStock,
    this.almacenId,
    this.ubicacionFisica,
    this.almacenNombre,
    required this.movimientosRecientes,
  });

  factory ProductoDetalle.fromJson(Map<String, dynamic> j) => ProductoDetalle(
        id: j['id'],
        nombre: j['nombre'],
        sku: j['sku'],
        descripcion: j['descripcion'],
        precioUnitario: (j['precio_unitario'] as num?)?.toDouble() ?? 0.0,
        imagenUrl: j['imagen_url'],
        unidadMedida: j['unidad_medida'] ?? 'unidad',
        stockMinimo: (j['stock_minimo'] as num?)?.toInt() ?? 0,
        stockMaximo: (j['stock_maximo'] as num?)?.toInt(),
        registroFecha: j['registro_fecha']?.toString(),
        categoriaId: j['categoria_id'],
        categoriaNombre: j['categoria_nombre'],
        categoriaColor: j['categoria_color'],
        proveedorId: j['proveedor_id'],
        proveedorNombre: j['proveedor_nombre'],
        stockTotal: (j['stock_total'] as num?)?.toInt() ?? 0,
        estadoStock: j['estado_stock'] ?? 'AGOTADO',
        almacenId: j['almacen_id'],
        ubicacionFisica: j['ubicacion_fisica'],
        almacenNombre: j['almacen_nombre'],
        movimientosRecientes: (j['movimientos_recientes'] as List<dynamic>? ?? [])
            .map((m) => MovimientoReciente.fromJson(m as Map<String, dynamic>))
            .toList(),
      );
}

class CatalogoPaginado {
  final List<CatalogoProducto> items;
  final int total;
  final int page;
  final int limit;
  final double pages;

  const CatalogoPaginado({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
  });

  factory CatalogoPaginado.fromJson(Map<String, dynamic> j) => CatalogoPaginado(
        items: (j['items'] as List<dynamic>)
            .map((e) => CatalogoProducto.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: j['total'] ?? 0,
        page: j['page'] ?? 1,
        limit: j['limit'] ?? 10,
        pages: (j['pages'] as num?)?.toDouble() ?? 1.0,
      );
}

class ProductService {
  final ApiClient _api = ApiClient.instance;

  Future<List<CategoriaItem>> getCategorias() async {
    try {
      final response = await _api.get('/productos/categorias');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        return (data['items'] as List<dynamic>)
            .map((e) => CategoriaItem.fromJson(e as Map<String, dynamic>))
            .toList();
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[ProductService.getCategorias] $e');
      rethrow;
    }
  }

  Future<CatalogoPaginado> getCatalogo({
    String? search,
    int? categoriaId,
    String sort = 'newest',
    int page = 1,
    int limit = 10,
  }) async {
    try {
      final params = <String, String>{
        'sort': sort,
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoriaId != null) 'categoria_id': '$categoriaId',
      };
      final query = Uri(queryParameters: params).query;
      final response = await _api.get('/productos/catalogo?$query');
      if (response.statusCode == 200) {
        return CatalogoPaginado.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[ProductService.getCatalogo] $e');
      rethrow;
    }
  }

  Future<ProductoDetalle> getProductoDetalle(int id) async {
    try {
      final response = await _api.get('/productos/$id/detalle');
      if (response.statusCode == 200) {
        return ProductoDetalle.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[ProductService.getProductoDetalle] $e');
      rethrow;
    }
  }

  Future<void> updateProducto(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/productos/$id', body: data);
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(body?['detail'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[ProductService.updateProducto] $e');
      rethrow;
    }
  }
}

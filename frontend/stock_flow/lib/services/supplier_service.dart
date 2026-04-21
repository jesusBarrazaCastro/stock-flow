import 'dart:convert';
import 'package:flutter/foundation.dart';
import '../core/network/api_client.dart';

// ─── Modelos ──────────────────────────────────────────────────────────────────

class ProductoSuministrado {
  final int id;
  final String nombre;
  final String sku;
  final String? imagenUrl;
  final String? categoriaNombre;
  final String? categoriaColor;
  final int stockTotal;

  const ProductoSuministrado({
    required this.id,
    required this.nombre,
    required this.sku,
    this.imagenUrl,
    this.categoriaNombre,
    this.categoriaColor,
    required this.stockTotal,
  });

  factory ProductoSuministrado.fromJson(Map<String, dynamic> j) =>
      ProductoSuministrado(
        id: j['id'],
        nombre: j['nombre'],
        sku: j['sku'],
        imagenUrl: j['imagen_url'],
        categoriaNombre: j['categoria_nombre'],
        categoriaColor: j['categoria_color'],
        stockTotal: (j['stock_total'] as num?)?.toInt() ?? 0,
      );
}

class PedidoHistorial {
  final int id;
  final String numeroPedido;
  final String? fecha;
  final int cantidad;
  final double? precioUnitario;
  final double montoTotal;
  final String? productoNombre;
  final String estadoPedido;

  const PedidoHistorial({
    required this.id,
    required this.numeroPedido,
    this.fecha,
    required this.cantidad,
    this.precioUnitario,
    required this.montoTotal,
    this.productoNombre,
    required this.estadoPedido,
  });

  factory PedidoHistorial.fromJson(Map<String, dynamic> j) => PedidoHistorial(
        id: j['id'],
        numeroPedido: j['numero_pedido'] ?? 'PO-00000',
        fecha: j['fecha']?.toString(),
        cantidad: (j['cantidad'] as num?)?.toInt() ?? 0,
        precioUnitario: (j['precio_unitario'] as num?)?.toDouble(),
        montoTotal: (j['monto_total'] as num?)?.toDouble() ?? 0.0,
        productoNombre: j['producto_nombre'],
        estadoPedido: j['estado_pedido'] ?? 'COMPLETADO',
      );
}

class ProveedorItem {
  final int id;
  final String nombre;
  final String? categoria;
  final String? contactoNombre;
  final String? contactoEmail;
  final String? contactoTelefono;
  final String? direccion;
  final int? diasEntrega;
  final String? logoUrl;
  final double? calificacion;
  final int? certificadoDesde;
  final String? notas;
  final String? registroFecha;
  final String estado;
  final int totalProductos;

  const ProveedorItem({
    required this.id,
    required this.nombre,
    this.categoria,
    this.contactoNombre,
    this.contactoEmail,
    this.contactoTelefono,
    this.direccion,
    this.diasEntrega,
    this.logoUrl,
    this.calificacion,
    this.certificadoDesde,
    this.notas,
    this.registroFecha,
    required this.estado,
    required this.totalProductos,
  });

  factory ProveedorItem.fromJson(Map<String, dynamic> j) => ProveedorItem(
        id: j['id'],
        nombre: j['nombre'],
        categoria: j['categoria'],
        contactoNombre: j['contacto_nombre'],
        contactoEmail: j['contacto_email'],
        contactoTelefono: j['contacto_telefono'],
        direccion: j['direccion'],
        diasEntrega: (j['dias_entrega'] as num?)?.toInt(),
        logoUrl: j['logo_url'],
        calificacion: (j['calificacion'] as num?)?.toDouble(),
        certificadoDesde: (j['certificado_desde'] as num?)?.toInt(),
        notas: j['notas'],
        registroFecha: j['registro_fecha']?.toString(),
        estado: j['estado'] ?? 'ACTIVO',
        totalProductos: (j['total_productos'] as num?)?.toInt() ?? 0,
      );
}

class ProveedorDetalle extends ProveedorItem {
  final List<ProductoSuministrado> productosSuministrados;
  final int pedidosTotal;
  final double cumplimiento;
  final double tiempoEntrega;
  final List<PedidoHistorial> historialPedidos;

  const ProveedorDetalle({
    required super.id,
    required super.nombre,
    super.categoria,
    super.contactoNombre,
    super.contactoEmail,
    super.contactoTelefono,
    super.direccion,
    super.diasEntrega,
    super.logoUrl,
    super.calificacion,
    super.certificadoDesde,
    super.notas,
    super.registroFecha,
    required super.estado,
    required super.totalProductos,
    required this.productosSuministrados,
    required this.pedidosTotal,
    required this.cumplimiento,
    required this.tiempoEntrega,
    required this.historialPedidos,
  });

  factory ProveedorDetalle.fromJson(Map<String, dynamic> j) => ProveedorDetalle(
        id: j['id'],
        nombre: j['nombre'],
        categoria: j['categoria'],
        contactoNombre: j['contacto_nombre'],
        contactoEmail: j['contacto_email'],
        contactoTelefono: j['contacto_telefono'],
        direccion: j['direccion'],
        diasEntrega: (j['dias_entrega'] as num?)?.toInt(),
        logoUrl: j['logo_url'],
        calificacion: (j['calificacion'] as num?)?.toDouble(),
        certificadoDesde: (j['certificado_desde'] as num?)?.toInt(),
        notas: j['notas'],
        registroFecha: j['registro_fecha']?.toString(),
        estado: j['estado'] ?? 'ACTIVO',
        totalProductos: (j['total_productos'] as num?)?.toInt() ?? 0,
        productosSuministrados:
            (j['productos_suministrados'] as List<dynamic>? ?? [])
                .map((e) => ProductoSuministrado.fromJson(e as Map<String, dynamic>))
                .toList(),
        pedidosTotal: (j['pedidos_total'] as num?)?.toInt() ?? 0,
        cumplimiento: (j['cumplimiento'] as num?)?.toDouble() ?? 0.0,
        tiempoEntrega: (j['tiempo_entrega'] as num?)?.toDouble() ?? 0.0,
        historialPedidos: (j['historial_pedidos'] as List<dynamic>? ?? [])
            .map((e) => PedidoHistorial.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}

class ProveedorListaPaginada {
  final List<ProveedorItem> items;
  final int total;
  final int page;
  final int limit;
  final double pages;
  final int aliadosTotal;
  final int nuevos;
  final int enRevision;

  const ProveedorListaPaginada({
    required this.items,
    required this.total,
    required this.page,
    required this.limit,
    required this.pages,
    required this.aliadosTotal,
    required this.nuevos,
    required this.enRevision,
  });

  factory ProveedorListaPaginada.fromJson(Map<String, dynamic> j) =>
      ProveedorListaPaginada(
        items: (j['items'] as List<dynamic>)
            .map((e) => ProveedorItem.fromJson(e as Map<String, dynamic>))
            .toList(),
        total: j['total'] ?? 0,
        page: j['page'] ?? 1,
        limit: j['limit'] ?? 20,
        pages: (j['pages'] as num?)?.toDouble() ?? 1.0,
        aliadosTotal: (j['aliados_total'] as num?)?.toInt() ?? 0,
        nuevos: (j['nuevos'] as num?)?.toInt() ?? 0,
        enRevision: (j['en_revision'] as num?)?.toInt() ?? 0,
      );
}

// ─── Service ──────────────────────────────────────────────────────────────────

class SupplierService {
  final ApiClient _api = ApiClient.instance;

  Future<ProveedorListaPaginada> getProveedores({
    String? search,
    String? categoria,
    String? estado,
    int? maxDias,
    int page = 1,
    int limit = 20,
  }) async {
    try {
      final params = <String, String>{
        'page': '$page',
        'limit': '$limit',
        if (search != null && search.isNotEmpty) 'search': search,
        if (categoria != null && categoria.isNotEmpty) 'categoria': categoria,
        if (estado != null && estado.isNotEmpty) 'estado': estado,
        if (maxDias != null) 'max_dias': '$maxDias',
      };
      final query = Uri(queryParameters: params).query;
      final response = await _api.get('/proveedores/lista?$query');
      if (response.statusCode == 200) {
        return ProveedorListaPaginada.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[SupplierService.getProveedores] $e');
      rethrow;
    }
  }

  Future<ProveedorDetalle> getProveedorDetalle(int id) async {
    try {
      final response = await _api.get('/proveedores/$id/detalle');
      if (response.statusCode == 200) {
        return ProveedorDetalle.fromJson(
            jsonDecode(response.body) as Map<String, dynamic>);
      }
      throw Exception('Error ${response.statusCode}');
    } catch (e) {
      debugPrint('[SupplierService.getProveedorDetalle] $e');
      rethrow;
    }
  }

  Future<void> createProveedor(Map<String, dynamic> data) async {
    try {
      final response = await _api.post('/proveedores/', body: data);
      if (response.statusCode != 200 && response.statusCode != 201) {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(body?['detail'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[SupplierService.createProveedor] $e');
      rethrow;
    }
  }

  Future<void> updateProveedor(int id, Map<String, dynamic> data) async {
    try {
      final response = await _api.put('/proveedores/$id', body: data);
      if (response.statusCode != 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>?;
        throw Exception(body?['detail'] ?? 'Error ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('[SupplierService.updateProveedor] $e');
      rethrow;
    }
  }
}

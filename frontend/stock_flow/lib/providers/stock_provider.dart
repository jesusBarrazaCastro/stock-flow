import 'package:flutter/material.dart';
import '../services/stock_service.dart';

class StockProvider extends ChangeNotifier {
  final StockService _service = StockService();

  // ── Estado interno ────────────────────────────────────────────
  List<StockItem> _allItems = [];
  List<StockCategoriaItem> _categorias = [];

  bool _isLoading = false;
  String? _error;

  // ── Filtros ───────────────────────────────────────────────────
  String? _searchQuery;
  String? _estadoFiltro; // null | 'AGOTADO' | 'STOCK_BAJO' | 'SUFICIENTE' | 'EXCESO'
  int? _categoriaFiltroId;

  // ── Getters públicos ──────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get estadoFiltro => _estadoFiltro;
  int? get categoriaFiltroId => _categoriaFiltroId;
  List<StockCategoriaItem> get categorias => _categorias;

  /// Lista filtrada que la UI debe renderizar.
  List<StockItem> get filtered {
    var result = _allItems;

    // Filtro por estado de stock (aplicado en cliente)
    if (_estadoFiltro != null) {
      result = result
          .where((item) => item.estadoStock == _estadoFiltro)
          .toList();
    }

    return result;
  }

  // ── Carga de datos ────────────────────────────────────────────

  /// Carga inicial del stock. Trae hasta 50 productos de la empresa en sesión.
  /// La búsqueda por texto y filtro por categoría se envían al backend.
  Future<void> loadStock() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _allItems = await _service.getStock(
        search: _searchQuery,
        categoriaId: _categoriaFiltroId,
        limit: 50,
      );
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Carga las categorías disponibles (para el filtro avanzado).
  Future<void> loadCategorias() async {
    try {
      _categorias = await _service.getCategorias();
      notifyListeners();
    } catch (e) {
      debugPrint('[StockProvider.loadCategorias] $e');
    }
  }

  /// Recarga desde cero respetando los filtros actuales.
  Future<void> refresh() async {
    await loadStock();
  }

  // ── Filtros ───────────────────────────────────────────────────

  /// Busca por nombre o SKU. Dispara una nueva llamada al backend.
  void setSearch(String? query) {
    _searchQuery = (query == null || query.trim().isEmpty) ? null : query.trim();
    loadStock();
  }

  /// Filtra por estado de stock en cliente (sin nueva llamada HTTP).
  void setEstadoFiltro(String? estado) {
    _estadoFiltro = estado;
    notifyListeners();
  }

  /// Filtra por categoría. Dispara una nueva llamada al backend.
  void setCategoria(int? categoriaId) {
    _categoriaFiltroId = categoriaId;
    loadStock();
  }

  /// Limpia todos los filtros y recarga.
  void clearFiltros() {
    _searchQuery = null;
    _estadoFiltro = null;
    _categoriaFiltroId = null;
    loadStock();
  }
}

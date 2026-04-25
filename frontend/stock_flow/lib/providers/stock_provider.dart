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
  String? _estadoFiltro; // null | 'AGOTADO' | 'STOCK_BAJO' | 'SUFICIENTE' | 'EXCESO' | 'EXPIRA_PRONTO'
  int? _categoriaFiltroId;
  String? _sortOrder;
  RangeValues? _precioRango;
  Set<String> _unidadesFiltro = {};

  // ── Getters públicos ──────────────────────────────────────────
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get searchQuery => _searchQuery;
  String? get estadoFiltro => _estadoFiltro;
  int? get categoriaFiltroId => _categoriaFiltroId;
  String? get sortOrder => _sortOrder;
  RangeValues? get precioRango => _precioRango;
  Set<String> get unidadesFiltro => Set.unmodifiable(_unidadesFiltro);
  List<StockCategoriaItem> get categorias => _categorias;

  double get precioMin => _allItems.isEmpty
      ? 0.0
      : _allItems.map((e) => e.precioUnitario).reduce((a, b) => a < b ? a : b);

  double get precioMax => _allItems.isEmpty
      ? 1.0
      : _allItems.map((e) => e.precioUnitario).reduce((a, b) => a > b ? a : b);

  List<String> get unidadesDisponibles =>
      (_allItems.map((e) => e.unidadMedida).toSet().toList()..sort());

  bool get hasAdvancedFilters =>
      _categoriaFiltroId != null ||
      _sortOrder != null ||
      _precioRango != null ||
      _unidadesFiltro.isNotEmpty;

  /// Lista filtrada que la UI debe renderizar.
  List<StockItem> get filtered {
    var result = List<StockItem>.from(_allItems);

    if (_estadoFiltro != null) {
      if (_estadoFiltro == 'EXPIRA_PRONTO') {
        result = result.where((i) => i.expiraProto == true).toList();
      } else {
        result = result.where((i) => i.estadoStock == _estadoFiltro).toList();
      }
    }

    if (_precioRango != null) {
      result = result
          .where((i) =>
              i.precioUnitario >= _precioRango!.start &&
              i.precioUnitario <= _precioRango!.end)
          .toList();
    }

    if (_unidadesFiltro.isNotEmpty) {
      result = result
          .where((i) => _unidadesFiltro.contains(i.unidadMedida))
          .toList();
    }

    switch (_sortOrder) {
      case 'name_asc':
        result.sort((a, b) => a.nombre.compareTo(b.nombre));
      case 'stock_asc':
        result.sort((a, b) => a.stockTotal.compareTo(b.stockTotal));
      case 'stock_desc':
        result.sort((a, b) => b.stockTotal.compareTo(a.stockTotal));
    }

    return result;
  }

  // ── Carga de datos ────────────────────────────────────────────

  Future<void> loadStock() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    const serverSorts = {'newest', 'price_asc', 'price_desc'};
    final serverSort =
        (_sortOrder != null && serverSorts.contains(_sortOrder))
            ? _sortOrder!
            : 'newest';

    try {
      _allItems = await _service.getStock(
        search: _searchQuery,
        categoriaId: _categoriaFiltroId,
        sort: serverSort,
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

  void setSearch(String? query) {
    _searchQuery = (query == null || query.trim().isEmpty) ? null : query.trim();
    loadStock();
  }

  void setEstadoFiltro(String? estado) {
    _estadoFiltro = estado;
    notifyListeners();
  }

  void setCategoria(int? categoriaId) {
    _categoriaFiltroId = categoriaId;
    loadStock();
  }

  /// Aplica todos los filtros avanzados atómicamente con un solo loadStock().
  void applyFiltros({
    String? estado,
    int? categoriaId,
    String? sortOrder,
    RangeValues? precioRango,
    Set<String>? unidades,
  }) {
    _estadoFiltro = estado;
    _categoriaFiltroId = categoriaId;
    _sortOrder = sortOrder;
    _precioRango = precioRango;
    _unidadesFiltro = unidades != null ? Set.from(unidades) : {};
    loadStock();
  }

  /// Limpia todos los filtros y recarga.
  void clearFiltros() {
    _searchQuery = null;
    _estadoFiltro = null;
    _categoriaFiltroId = null;
    _sortOrder = null;
    _precioRango = null;
    _unidadesFiltro = {};
    loadStock();
  }
}

import 'package:flutter/material.dart';
import '../services/product_service.dart';

class ProductProvider extends ChangeNotifier {
  final ProductService _service = ProductService();

  List<CatalogoProducto> _productos = [];
  ProductoDetalle? _selectedProducto;
  List<CategoriaItem> _categorias = [];

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  String? _searchQuery;
  int? _selectedCategoriaId;
  String _sort = 'newest';

  List<CatalogoProducto> get productos => _productos;
  ProductoDetalle? get selectedProducto => _selectedProducto;
  List<CategoriaItem> get categorias => _categorias;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  String? get searchQuery => _searchQuery;
  int? get selectedCategoriaId => _selectedCategoriaId;
  String get sort => _sort;

  Future<void> loadCategorias() async {
    try {
      _categorias = await _service.getCategorias();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> loadCatalogo({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getCatalogo(
        search: _searchQuery,
        categoriaId: _selectedCategoriaId,
        sort: _sort,
        page: _currentPage,
        limit: 10,
      );
      _productos = result.items;
      _totalItems = result.total;
      _totalPages = result.pages.ceil();
      _currentPage = result.page;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadDetalle(int id) async {
    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _selectedProducto = await _service.getProductoDetalle(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<String?> updateProducto(int id, Map<String, dynamic> data) async {
    try {
      await _service.updateProducto(id, data);
      await loadDetalle(id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> createProducto(Map<String, dynamic> data) async {
    try {
      await _service.createProducto(data);
      await loadCatalogo(resetPage: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setSearch(String? query) {
    _searchQuery = (query == null || query.isEmpty) ? null : query;
    loadCatalogo(resetPage: true);
  }

  void setCategoria(int? categoriaId) {
    _selectedCategoriaId = categoriaId;
    loadCatalogo(resetPage: true);
  }

  void setSort(String sort) {
    _sort = sort;
    loadCatalogo(resetPage: true);
  }

  void setPage(int page) {
    _currentPage = page;
    loadCatalogo();
  }

  void clearSelectedProducto() {
    _selectedProducto = null;
    notifyListeners();
  }
}

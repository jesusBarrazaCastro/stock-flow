import 'package:flutter/material.dart';
import '../services/supplier_service.dart';

class SupplierProvider extends ChangeNotifier {
  final SupplierService _service = SupplierService();

  List<ProveedorItem> _proveedores = [];
  ProveedorDetalle? _selectedProveedor;

  bool _isLoading = false;
  bool _isLoadingDetail = false;
  String? _error;

  int _currentPage = 1;
  int _totalPages = 1;
  int _totalItems = 0;

  // Stats de red
  int _aliadosTotal = 0;
  int _nuevos = 0;
  int _enRevision = 0;

  String? _searchQuery;

  // Getters
  List<ProveedorItem> get proveedores => _proveedores;
  ProveedorDetalle? get selectedProveedor => _selectedProveedor;
  bool get isLoading => _isLoading;
  bool get isLoadingDetail => _isLoadingDetail;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalItems => _totalItems;
  int get aliadosTotal => _aliadosTotal;
  int get nuevos => _nuevos;
  int get enRevision => _enRevision;
  String? get searchQuery => _searchQuery;

  Future<void> loadProveedores({bool resetPage = false}) async {
    if (resetPage) _currentPage = 1;
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getProveedores(
        search: _searchQuery,
        page: _currentPage,
        limit: 20,
      );
      _proveedores = result.items;
      _totalItems = result.total;
      _totalPages = result.pages.ceil();
      _currentPage = result.page;
      _aliadosTotal = result.aliadosTotal;
      _nuevos = result.nuevos;
      _enRevision = result.enRevision;
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
      _selectedProveedor = await _service.getProveedorDetalle(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }

  Future<String?> createProveedor(Map<String, dynamic> data) async {
    try {
      await _service.createProveedor(data);
      await loadProveedores(resetPage: true);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  Future<String?> updateProveedor(int id, Map<String, dynamic> data) async {
    try {
      await _service.updateProveedor(id, data);
      await loadDetalle(id);
      return null;
    } catch (e) {
      return e.toString();
    }
  }

  void setSearch(String? query) {
    _searchQuery = (query == null || query.isEmpty) ? null : query;
    loadProveedores(resetPage: true);
  }

  void setPage(int page) {
    _currentPage = page;
    loadProveedores();
  }

  void clearSelectedProveedor() {
    _selectedProveedor = null;
    notifyListeners();
  }
}

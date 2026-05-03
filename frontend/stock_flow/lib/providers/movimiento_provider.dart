import 'package:flutter/foundation.dart';
import '../services/movimiento_service.dart';
import '../services/product_service.dart';
import '../services/stock_service.dart';
import '../services/supplier_service.dart';

class MovimientoProvider extends ChangeNotifier {
  final MovimientoService _service = MovimientoService();
  final ProductService _productService = ProductService();
  final StockService _stockService = StockService();
  final SupplierService _supplierService = SupplierService();

  // ── Estado del formulario ─────────────────────────────────────
  bool _isSubmitting = false;
  bool _isLoadingFormData = false;
  bool _isSearching = false;
  String? _error;

  // ── Datos para los dropdowns ──────────────────────────────────
  List<AlmacenItem> _almacenes = [];
  List<ProveedorItem> _proveedores = [];

  // ── Resultados de búsqueda de producto ───────────────────────
  List<StockItem> _productosSearch = [];

  // ── Producto seleccionado ─────────────────────────────────────
  StockItem? _productoSeleccionado;

  // ── Lotes disponibles para SALIDA ────────────────────────────
  List<LoteDisponible> _lotesDisponibles = [];
  bool _isLoadingLotes = false;
  LoteDisponible? _loteSeleccionado;

  // ── Getters públicos ──────────────────────────────────────────
  bool get isSubmitting => _isSubmitting;
  bool get isLoadingFormData => _isLoadingFormData;
  bool get isSearching => _isSearching;
  String? get error => _error;
  List<AlmacenItem> get almacenes => _almacenes;
  List<ProveedorItem> get proveedores => _proveedores;
  List<StockItem> get productosSearch => _productosSearch;
  StockItem? get productoSeleccionado => _productoSeleccionado;
  List<LoteDisponible> get lotesDisponibles => _lotesDisponibles;
  bool get isLoadingLotes => _isLoadingLotes;
  LoteDisponible? get loteSeleccionado => _loteSeleccionado;

  /// Si la empresa tiene solo un almacén, lo devuelve para autoselección.
  AlmacenItem? get almacenAutoselect =>
      _almacenes.length == 1 ? _almacenes.first : null;

  // ── Carga de datos del formulario ─────────────────────────────

  /// Carga almacenes y proveedores en paralelo al abrir el formulario.
  Future<void> loadFormData() async {
    _isLoadingFormData = true;
    _error = null;
    notifyListeners();

    await Future.wait([
      _loadAlmacenes(),
      _loadProveedores(),
    ]);

    _isLoadingFormData = false;
    notifyListeners();
  }

  Future<void> _loadAlmacenes() async {
    try {
      _almacenes = await _service.getAlmacenes();
    } catch (e) {
      debugPrint('[MovimientoProvider._loadAlmacenes] $e');
    }
  }

  Future<void> _loadProveedores() async {
    try {
      final result = await _supplierService.getProveedores(limit: 100);
      _proveedores = result.items;
    } catch (e) {
      debugPrint('[MovimientoProvider._loadProveedores] $e');
    }
  }

  // ── Búsqueda de producto ──────────────────────────────────────

  Future<void> searchProducto(String query) async {
    if (query.trim().isEmpty) {
      _productosSearch = [];
      notifyListeners();
      return;
    }

    _isSearching = true;
    notifyListeners();

    try {
      _productosSearch = await _stockService.getStock(
        search: query.trim(),
        limit: 10,
      );
    } catch (e) {
      debugPrint('[MovimientoProvider.searchProducto] $e');
      _productosSearch = [];
    } finally {
      _isSearching = false;
      notifyListeners();
    }
  }

  void seleccionarProducto(StockItem producto) {
    _productoSeleccionado = producto;
    _productosSearch = [];
    notifyListeners();
  }

  void clearProducto() {
    _productoSeleccionado = null;
    _productosSearch = [];
    clearLotes();
    notifyListeners();
  }

  // ── Lotes disponibles ─────────────────────────────────────────

  Future<void> loadLotesDisponibles(int productoId) async {
    _isLoadingLotes = true;
    _lotesDisponibles = [];
    _loteSeleccionado = null;
    notifyListeners();
    try {
      _lotesDisponibles = await _productService.getLotesDisponibles(productoId);
      if (_lotesDisponibles.isNotEmpty) {
        _loteSeleccionado = _lotesDisponibles.first;
      }
    } catch (e) {
      debugPrint('[MovimientoProvider.loadLotesDisponibles] $e');
    } finally {
      _isLoadingLotes = false;
      notifyListeners();
    }
  }

  void seleccionarLote(LoteDisponible lote) {
    _loteSeleccionado = lote;
    notifyListeners();
  }

  void clearLotes() {
    _lotesDisponibles = [];
    _loteSeleccionado = null;
  }

  void clearSearch() {
    _productosSearch = [];
    notifyListeners();
  }

  // ── Registro ──────────────────────────────────────────────────

  /// Envía el movimiento al backend.
  /// Devuelve null si fue exitoso, o un String con el mensaje de error.
  Future<String?> registrar(MovimientoRegistroRequest req) async {
    _isSubmitting = true;
    _error = null;
    notifyListeners();

    try {
      await _service.registrarMovimiento(req);
      return null;
    } catch (e) {
      final msg = e.toString().replaceFirst('Exception: ', '');
      _error = msg;
      return msg;
    } finally {
      _isSubmitting = false;
      notifyListeners();
    }
  }

  /// Limpia el estado del provider para un nuevo registro.
  void reset() {
    _productoSeleccionado = null;
    _productosSearch = [];
    _error = null;
    _isSubmitting = false;
    clearLotes();
    notifyListeners();
  }
}

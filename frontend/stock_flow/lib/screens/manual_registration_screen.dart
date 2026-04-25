import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/movimiento_provider.dart';
import '../providers/stock_provider.dart';
import '../services/movimiento_service.dart';
import '../services/supplier_service.dart';
import '../utilities/msg_util.dart';

class ManualRegistrationScreen extends StatefulWidget {
  final bool? initialIsEntry;
  const ManualRegistrationScreen({super.key, this.initialIsEntry});

  @override
  State<ManualRegistrationScreen> createState() =>
      _ManualRegistrationScreenState();
}

class _ManualRegistrationScreenState extends State<ManualRegistrationScreen> {
  late bool _isEntry;
  int _quantity = 1;
  DateTime _selectedDate = DateTime.now();
  DateTime? _selectedFechaCaducidad;

  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _notesController = TextEditingController();

  AlmacenItem? _selectedAlmacen;
  ProveedorItem? _selectedProveedor;

  bool _showSearchResults = false;

  @override
  void initState() {
    super.initState();
    _isEntry = widget.initialIsEntry ?? true;
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final provider = context.read<MovimientoProvider>();
      await provider.loadFormData();
      // Autoseleccionar almacén si solo hay uno
      if (mounted && provider.almacenAutoselect != null) {
        setState(() => _selectedAlmacen = provider.almacenAutoselect);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _priceController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: AppTheme.primary,
            onPrimary: Colors.white,
            onSurface: AppTheme.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectFechaCaducidad() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedFechaCaducidad ?? now.add(const Duration(days: 30)),
      firstDate: now,
      lastDate: DateTime(now.year + 10),
      helpText: 'Fecha de caducidad del lote',
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
            primary: Color(0xFFD97706),
            onPrimary: Colors.white,
            onSurface: AppTheme.textDark,
          ),
        ),
        child: child!,
      ),
    );
    if (picked != null) setState(() => _selectedFechaCaducidad = picked);
  }

  Future<void> _confirmar() async {
    final provider = context.read<MovimientoProvider>();
    final stock = context.read<StockProvider>();

    // Validaciones
    if (provider.productoSeleccionado == null) {
      MsgtUtil.showWarning(context, 'Selecciona un producto');
      return;
    }
    if (_selectedAlmacen == null && false) {
      // Validación de almacén omitida por configuración
    }
    if (_quantity < 1) {
      MsgtUtil.showWarning(context, 'La cantidad debe ser mayor a cero');
      return;
    }

    final precio = double.tryParse(
        _priceController.text.replaceAll(',', '.'));

    final req = MovimientoRegistroRequest(
      productoId: provider.productoSeleccionado!.id,
      // almacenId omitido: la SP auto-selecciona el primero disponible
      tipo: _isEntry ? 'ENTRADA' : 'SALIDA',
      cantidad: _quantity,
      precioUnitario: precio,
      proveedorId: _selectedProveedor?.id,
      notas: _notesController.text.trim().isEmpty
          ? null
          : _notesController.text.trim(),
      fecha: _selectedDate,
      fechaCaducidad: _isEntry ? _selectedFechaCaducidad : null,
    );

    final error = await provider.registrar(req);

    if (!mounted) return;

    if (error != null) {
      MsgtUtil.showError(context, error);
    } else {
      MsgtUtil.showSuccess(context, 'Movimiento registrado correctamente');
      // Refrescar la pantalla de stock
      await stock.refresh();
      if (mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MovimientoProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: AppTheme.neutral,
          appBar: _buildAppBar(),
          body: GestureDetector(
            onTap: () {
              FocusScope.of(context).unfocus();
              setState(() => _showSearchResults = false);
              provider.clearSearch();
            },
            child: Stack(
              children: [
                SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildTypeSelector(),
                      const SizedBox(height: 32),

                      // ── Producto ──────────────────────────────
                      _buildLabel('Nombre del Producto'),
                      _buildProductSearch(provider),
                      const SizedBox(height: 24),

                      // ── SKU + Fecha ───────────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('SKU'),
                                _buildReadonlyField(
                                  provider.productoSeleccionado?.sku ?? '—',
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Fecha'),
                                _buildDateField(),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Cantidad + Precio ─────────────────────
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildLabel('Cantidad'),
                                _buildQuantityStepper(),
                              ],
                            ),
                          ),
                          if (_isEntry) ...[
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  _buildLabel('Precio Unitario'),
                                  _buildPriceField(provider),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 24),

                      // ── Proveedor / Origen (solo en ENTRADA) ──────────
                      if (_isEntry) ...[
                        _buildLabel('Proveedor / Origen'),
                        _buildProveedorDropdown(provider),
                        const SizedBox(height: 24),
                      ],

                      // ── Fecha de Caducidad (ENTRADA + producto expirable) ──
                      if (_isEntry &&
                          provider.productoSeleccionado?.tieneCaducidad == true) ...[
                        _buildLabel('Fecha de Caducidad del Lote'),
                        _buildFechaCaducidadField(),
                        const SizedBox(height: 24),
                      ],

                      // ── Notas ─────────────────────────────────
                      _buildLabel('Notas Adicionales'),
                      _buildNotesField(),
                      const SizedBox(height: 40),

                      // ── Botón Confirmar ───────────────────────
                      _buildConfirmButton(provider),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),

                // ── Overlay resultados búsqueda ───────────────
                if (_showSearchResults &&
                    provider.productosSearch.isNotEmpty)
                  _buildSearchOverlay(provider),
              ],
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGETS
  // ═══════════════════════════════════════════════════════════════

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        onPressed: () => Navigator.pop(context),
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark, size: 20),
      ),
      title: Text(
        'Registro manual',
        style: TextStyle(
          fontFamily: 'Noto Serif',
          fontWeight: FontWeight.w800,
          color: AppTheme.textDark,
          fontSize: 20,
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    return Container(
      padding: const EdgeInsets.all(6),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildTypeButton(
              title: 'Entrada',
              icon: Icons.login_rounded,
              isSelected: _isEntry,
              onTap: () => setState(() => _isEntry = true),
            ),
          ),
          Expanded(
            child: _buildTypeButton(
              title: 'Salida',
              icon: Icons.logout_rounded,
              isSelected: !_isEntry,
              onTap: () => setState(() {
                _isEntry = false;
                _priceController.clear();
                _selectedProveedor = null;
                _selectedFechaCaducidad = null;
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeButton({
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.primary : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ]
              : [],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                color: isSelected ? Colors.white : AppTheme.textLight,
                size: 20),
            const SizedBox(width: 8),
            Text(
              title,
              style: GoogleFonts.manrope(
                color: isSelected ? Colors.white : AppTheme.textLight,
                fontWeight: FontWeight.w700,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        text,
        style: GoogleFonts.manrope(
          color: AppTheme.textDark,
          fontSize: 14,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  Widget _buildProductSearch(MovimientoProvider provider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Si ya hay producto seleccionado, mostrar chip
        if (provider.productoSeleccionado != null)
          _buildSelectedProductChip(provider)
        else
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(16),
            ),
            child: TextField(
              controller: _searchController,
              onChanged: (value) {
                setState(() => _showSearchResults = value.isNotEmpty);
                provider.searchProducto(value);
              },
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o SKU...',
                prefixIcon: provider.isSearching
                    ? const Padding(
                        padding: EdgeInsets.all(14),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      )
                    : const Icon(Icons.search_rounded,
                        color: AppTheme.textLight),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                  borderSide:
                      const BorderSide(color: AppTheme.primary, width: 1.5),
                ),
                contentPadding: const EdgeInsets.symmetric(
                    vertical: 16, horizontal: 20),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSelectedProductChip(MovimientoProvider provider) {
    final p = provider.productoSeleccionado!;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primaryDark.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
            color: AppTheme.primaryDark.withValues(alpha: 0.3), width: 1),
      ),
      child: Row(
        children: [
          Icon(Icons.inventory_2_outlined,
              color: AppTheme.primaryDark, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(p.nombre,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontSize: 14)),
                Text(
                    'Stock: ${p.stockTotal} ${p.unidadMedida} · ${p.estadoStock}',
                    style: GoogleFonts.manrope(
                        fontSize: 12, color: AppTheme.textMedium)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              provider.clearProducto();
              _searchController.clear();
              _priceController.clear();
            },
            icon: const Icon(Icons.close, color: AppTheme.textLight, size: 18),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchOverlay(MovimientoProvider provider) {
    return Positioned(
      top: 148, // debajo del campo de búsqueda
      left: 18,
      right: 18,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          constraints: const BoxConstraints(maxHeight: 220),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            itemCount: provider.productosSearch.length,
            separatorBuilder: (_, __) =>
                Divider(height: 1, color: AppTheme.divider),
            itemBuilder: (ctx, i) {
              final item = provider.productosSearch[i];
              return ListTile(
                leading: Icon(Icons.inventory_2_outlined,
                    color: AppTheme.primaryDark),
                title: Text(item.nombre,
                    style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
                subtitle: Text('SKU: ${item.sku}',
                    style: GoogleFonts.manrope(fontSize: 12)),
                trailing: Text('${item.stockTotal} uds',
                    style: GoogleFonts.manrope(
                        fontSize: 12, color: AppTheme.textMedium)),
                onTap: () {
                  provider.seleccionarProducto(item);
                  _searchController.clear();
                  // Autocompletar precio solo en ENTRADA
                  if (_isEntry && item.precioUnitario > 0) {
                    _priceController.text =
                        item.precioUnitario.toStringAsFixed(2);
                  }
                  setState(() => _showSearchResults = false);
                },
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildReadonlyField(String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(value,
          style: GoogleFonts.manrope(
              color: AppTheme.textMedium, fontSize: 15)),
    );
  }

  Widget _buildDateField() {
    return GestureDetector(
      onTap: _selectDate,
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              DateFormat('dd/MM/yyyy').format(_selectedDate),
              style: GoogleFonts.manrope(
                  color: AppTheme.textDark, fontSize: 15),
            ),
            const Icon(Icons.calendar_today_rounded,
                size: 18, color: AppTheme.textDark),
          ],
        ),
      ),
    );
  }

  Widget _buildQuantityStepper() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () =>
                setState(() { if (_quantity > 1) _quantity--; }),
            icon: const Icon(Icons.remove,
                color: Color(0xFFB76E5D)),
          ),
          Text('$_quantity',
              style: GoogleFonts.manrope(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark)),
          IconButton(
            onPressed: () => setState(() => _quantity++),
            icon:
                const Icon(Icons.add, color: Color(0xFFB76E5D)),
          ),
        ],
      ),
    );
  }

  Widget _buildPriceField(MovimientoProvider provider) {
    return Container(
      padding:
          const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Text('\$',
              style: GoogleFonts.manrope(
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w600)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: _priceController,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.zero,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                hintText: '0.00',
              ),
              style: GoogleFonts.manrope(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlmacenDropdown(MovimientoProvider provider) {
    if (provider.isLoadingFormData) {
      return _buildLoadingField();
    }
    if (provider.almacenes.isEmpty) {
      return _buildReadonlyField('Sin almacenes disponibles');
    }
    return GestureDetector(
      onTap: () => _showAlmacenPicker(provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedAlmacen?.nombre ?? 'Seleccionar almacén...',
              style: GoogleFonts.manrope(
                color: _selectedAlmacen != null
                    ? AppTheme.textDark
                    : AppTheme.textLight,
                fontSize: 15,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildProveedorDropdown(MovimientoProvider provider) {
    if (provider.isLoadingFormData) {
      return _buildLoadingField();
    }
    return GestureDetector(
      onTap: () => _showProveedorPicker(provider),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              _selectedProveedor?.nombre ?? 'Sin proveedor',
              style: GoogleFonts.manrope(
                color: _selectedProveedor != null
                    ? AppTheme.textDark
                    : AppTheme.textLight,
                fontSize: 15,
              ),
            ),
            const Icon(Icons.keyboard_arrow_down_rounded,
                color: AppTheme.textLight),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingField() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const SizedBox(
        height: 18,
        width: 18,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildFechaCaducidadField() {
    final hasDate = _selectedFechaCaducidad != null;
    return GestureDetector(
      onTap: _selectFechaCaducidad,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: hasDate
              ? const Color(0xFFF59E0B).withValues(alpha: 0.08)
              : Colors.white.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: hasDate
                ? const Color(0xFFF59E0B).withValues(alpha: 0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  hasDate
                      ? DateFormat('dd/MM/yyyy').format(_selectedFechaCaducidad!)
                      : 'Sin fecha (opcional)',
                  style: GoogleFonts.manrope(
                    color: hasDate
                        ? const Color(0xFFD97706)
                        : AppTheme.textLight,
                    fontSize: 15,
                    fontWeight:
                        hasDate ? FontWeight.w700 : FontWeight.w400,
                  ),
                ),
                if (!hasDate)
                  Text(
                    'Toca para seleccionar',
                    style: GoogleFonts.manrope(
                        fontSize: 11, color: AppTheme.textLight),
                  ),
              ],
            ),
            Row(
              children: [
                if (hasDate)
                  GestureDetector(
                    onTap: () =>
                        setState(() => _selectedFechaCaducidad = null),
                    child: const Icon(Icons.close,
                        size: 16, color: Color(0xFFD97706)),
                  ),
                const SizedBox(width: 8),
                Icon(
                  Icons.event_outlined,
                  size: 18,
                  color: hasDate
                      ? const Color(0xFFD97706)
                      : AppTheme.textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _notesController,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: 'Observaciones sobre el movimiento...',
          hintStyle: GoogleFonts.manrope(
              color: AppTheme.textLight.withValues(alpha: 0.6)),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          contentPadding: const EdgeInsets.all(20),
        ),
      ),
    );
  }

  Widget _buildConfirmButton(MovimientoProvider provider) {
    return SizedBox(
      width: double.infinity,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: const LinearGradient(
            colors: [Color(0xFFB76E5D), Color(0xFF9E5343)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF9E5343).withValues(alpha: 0.4),
              blurRadius: 15,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: ElevatedButton(
          onPressed: provider.isSubmitting ? null : _confirmar,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            padding: const EdgeInsets.symmetric(vertical: 20),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20)),
          ),
          child: provider.isSubmitting
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Text(
                  'Confirmar Registro',
                  style: GoogleFonts.manrope(
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // PICKERS (bottom sheets)
  // ═══════════════════════════════════════════════════════════════

  void _showAlmacenPicker(MovimientoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24),
        children: [
          Text('Seleccionar Almacén',
              style: TextStyle(
                  fontFamily: 'Noto Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          ...provider.almacenes.map((a) => ListTile(
                leading: const Icon(Icons.warehouse_outlined,
                    color: AppTheme.primaryDark),
                title: Text(a.nombre,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600)),
                subtitle: a.direccion != null
                    ? Text(a.direccion!,
                        style: GoogleFonts.manrope(fontSize: 12))
                    : null,
                selected: _selectedAlmacen?.id == a.id,
                selectedColor: AppTheme.primaryDark,
                onTap: () {
                  setState(() => _selectedAlmacen = a);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }

  void _showProveedorPicker(MovimientoProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => ListView(
        shrinkWrap: true,
        padding: const EdgeInsets.all(24),
        children: [
          Text('Seleccionar Proveedor',
              style: TextStyle(
                  fontFamily: 'Noto Serif',
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark)),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.block, color: AppTheme.textLight),
            title: Text('Sin proveedor',
                style: GoogleFonts.manrope(fontWeight: FontWeight.w600)),
            selected: _selectedProveedor == null,
            selectedColor: AppTheme.primaryDark,
            onTap: () {
              setState(() => _selectedProveedor = null);
              Navigator.pop(context);
            },
          ),
          ...provider.proveedores.map((p) => ListTile(
                leading: const Icon(Icons.local_shipping_outlined,
                    color: AppTheme.primaryDark),
                title: Text(p.nombre,
                    style: GoogleFonts.manrope(
                        fontWeight: FontWeight.w600)),
                subtitle: p.contactoNombre != null
                    ? Text(p.contactoNombre!,
                        style: GoogleFonts.manrope(fontSize: 12))
                    : null,
                selected: _selectedProveedor?.id == p.id,
                selectedColor: AppTheme.primaryDark,
                onTap: () {
                  setState(() => _selectedProveedor = p);
                  Navigator.pop(context);
                },
              )),
        ],
      ),
    );
  }
}

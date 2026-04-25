import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import '../utilities/msg_util.dart';

class EditProductScreen extends StatefulWidget {
  final int? productoId;

  const EditProductScreen({super.key, this.productoId});

  bool get isEditing => productoId != null;

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _skuCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();
  final _precioCtrl = TextEditingController();
  final _stockMinCtrl = TextEditingController(text: '0');
  final _stockMaxCtrl = TextEditingController();
  final _ubicacionCtrl = TextEditingController();
  String _unidadMedida = 'unidad';
  int? _selectedCategoriaId;
  bool _tieneCaducidad = false;

  bool _isSaving = false;
  bool _initialized = false;

  static const _unidades = [
    'unidad', 'kg', 'g', 'lt', 'ml', 'm', 'cm', 'caja', 'paquete', 'par',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadCategorias();
      if (widget.isEditing) {
        provider.loadDetalle(widget.productoId!);
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _skuCtrl.dispose();
    _descripcionCtrl.dispose();
    _precioCtrl.dispose();
    _stockMinCtrl.dispose();
    _stockMaxCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  void _initFromProducto(ProductoDetalle p) {
    if (_initialized) return;
    _nombreCtrl.text = p.nombre;
    _skuCtrl.text = p.sku;
    _descripcionCtrl.text = p.descripcion ?? '';
    _precioCtrl.text = p.precioUnitario.toStringAsFixed(2);
    _unidadMedida = p.unidadMedida;
    _stockMinCtrl.text = '${p.stockMinimo}';
    _stockMaxCtrl.text = p.stockMaximo != null ? '${p.stockMaximo}' : '';
    _ubicacionCtrl.text = p.ubicacionFisica ?? '';
    _selectedCategoriaId = p.categoriaId;
    _tieneCaducidad = p.tieneCaducidad;
    _initialized = true;
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    if (widget.isEditing) {
      await _doEdit();
    } else {
      await _doAdd();
    }
  }

  Future<void> _doAdd() async {
    final data = <String, dynamic>{
      'nombre': _nombreCtrl.text.trim(),
      'sku': _skuCtrl.text.trim(),
      if (_descripcionCtrl.text.trim().isNotEmpty)
        'descripcion': _descripcionCtrl.text.trim(),
      'precio_unitario': double.tryParse(_precioCtrl.text) ?? 0.0,
      'unidad_medida': _unidadMedida,
      'stock_minimo': int.tryParse(_stockMinCtrl.text) ?? 0,
      if (_stockMaxCtrl.text.trim().isNotEmpty)
        'stock_maximo': int.tryParse(_stockMaxCtrl.text),
      if (_ubicacionCtrl.text.trim().isNotEmpty)
        'ubicacion_fisica': _ubicacionCtrl.text.trim(),
      if (_selectedCategoriaId != null) 'categoria_id': _selectedCategoriaId,
      'tiene_caducidad': _tieneCaducidad,
    };
    final error = await context.read<ProductProvider>().createProducto(data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      MsgtUtil.showError(context, error);
    } else {
      Navigator.pop(context, true);
    }
  }

  Future<void> _doEdit() async {
    final provider = context.read<ProductProvider>();
    final original = provider.selectedProducto!;
    final data = <String, dynamic>{};

    final nombre = _nombreCtrl.text.trim();
    if (nombre.isNotEmpty && nombre != original.nombre) data['nombre'] = nombre;

    final sku = _skuCtrl.text.trim();
    if (sku.isNotEmpty && sku != original.sku) data['sku'] = sku;

    final descripcion = _descripcionCtrl.text.trim();
    if (descripcion != (original.descripcion ?? '')) {
      data['descripcion'] = descripcion.isNotEmpty ? descripcion : null;
    }

    final precio = double.tryParse(_precioCtrl.text.trim());
    if (precio != null && precio != original.precioUnitario) {
      data['precio_unitario'] = precio;
    }

    if (_unidadMedida != original.unidadMedida) {
      data['unidad_medida'] = _unidadMedida;
    }

    final stockMin = int.tryParse(_stockMinCtrl.text.trim());
    if (stockMin != null && stockMin != original.stockMinimo) {
      data['stock_minimo'] = stockMin;
    }

    final stockMaxStr = _stockMaxCtrl.text.trim();
    final stockMax = stockMaxStr.isNotEmpty ? int.tryParse(stockMaxStr) : null;
    if (stockMax != original.stockMaximo) data['stock_maximo'] = stockMax;

    final ubicacion = _ubicacionCtrl.text.trim();
    if (ubicacion != (original.ubicacionFisica ?? '')) {
      data['ubicacion_fisica'] = ubicacion.isNotEmpty ? ubicacion : null;
    }

    if (_selectedCategoriaId != original.categoriaId) {
      data['categoria_id'] = _selectedCategoriaId;
    }

    if (_tieneCaducidad != original.tieneCaducidad) {
      data['tiene_caducidad'] = _tieneCaducidad;
    }

    if (data.isEmpty) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      return;
    }

    final error = await provider.updateProducto(widget.productoId!, data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      MsgtUtil.showError(context, error);
    } else {
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, provider, _) {
        if (widget.isEditing) {
          if (provider.isLoadingDetail) {
            return Scaffold(
              backgroundColor: AppTheme.neutral,
              appBar: _buildAppBar(),
              body: const Center(
                child: CircularProgressIndicator(color: AppTheme.primaryDark),
              ),
            );
          }
          final p = provider.selectedProducto;
          if (p == null) {
            return Scaffold(
              backgroundColor: AppTheme.neutral,
              appBar: _buildAppBar(),
              body: Center(
                child: Text(
                  'Producto no encontrado',
                  style: TextStyle(color: AppTheme.textMedium),
                ),
              ),
            );
          }
          _initFromProducto(p);
        }

        return Scaffold(
          backgroundColor: AppTheme.neutral,
          appBar: _buildAppBar(),
          body: Form(
            key: _formKey,
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                    child: _buildFields(provider.categorias),
                  ),
                ),
                _buildSaveButton(),
              ],
            ),
          ),
        );
      },
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: AppTheme.neutral,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.close, color: AppTheme.textDark),
        onPressed: () => Navigator.pop(context),
      ),
      title: Text(
        widget.isEditing ? 'Editar Producto' : 'Nuevo Producto',
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
          fontFamily: 'Noto Serif',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildFields(List<CategoriaItem> categorias) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader('Información General'),
        const SizedBox(height: 16),

        _buildFieldLabel('NOMBRE DEL PRODUCTO'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _nombreCtrl,
          hint: 'Ej. Laptop Dell XPS 13',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 16),

        _buildFieldLabel('SKU'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _skuCtrl,
          hint: 'Ej. LAP-DELL-001',
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
        ),
        const SizedBox(height: 16),

        _buildFieldLabel('DESCRIPCIÓN'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _descripcionCtrl,
          hint: 'Descripción opcional del producto',
          maxLines: 3,
        ),
        const SizedBox(height: 16),

        _buildFieldLabel('CATEGORÍA'),
        const SizedBox(height: 6),
        _buildCategoriaDropdown(categorias),

        const SizedBox(height: 20),
        _buildCaducidadToggle(),

        const SizedBox(height: 28),
        _buildSectionHeader('Precio y Unidad'),
        const SizedBox(height: 16),

        _buildFieldLabel('PRECIO UNITARIO'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _precioCtrl,
          hint: '0.00',
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}'))
          ],
          prefix: '\$',
        ),
        const SizedBox(height: 16),

        _buildFieldLabel('UNIDAD DE MEDIDA'),
        const SizedBox(height: 6),
        _buildUnidadDropdown(),

        const SizedBox(height: 28),
        _buildSectionHeader('Inventario y Logística'),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('STOCK MÍNIMO'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _stockMinCtrl,
                    hint: '0',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildFieldLabel('STOCK MÁXIMO'),
                  const SizedBox(height: 6),
                  _buildTextField(
                    controller: _stockMaxCtrl,
                    hint: 'Sin límite',
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        _buildFieldLabel('UBICACIÓN EN ALMACÉN'),
        const SizedBox(height: 6),
        _buildTextField(
          controller: _ubicacionCtrl,
          hint: 'Ej. Pasillo A-4, Estante 2',
          prefixIcon: Icons.location_on_outlined,
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildSaveButton() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.neutral,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 50,
        child: ElevatedButton.icon(
          onPressed: _isSaving ? null : _save,
          icon: _isSaving
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(
                  widget.isEditing ? Icons.update_rounded : Icons.check_rounded),
          label: Text(
            _isSaving
                ? 'Guardando...'
                : (widget.isEditing ? 'Actualizar Registro' : 'Guardar producto'),
            style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primaryDark,
            foregroundColor: Colors.white,
            disabledBackgroundColor: AppTheme.primaryDark.withValues(alpha: 0.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
          ),
        ),
      ),
    );
  }

  // ─── HELPERS ──────────────────────────────────────────────────────────────

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.primaryDark,
        fontFamily: 'Noto Serif',
      ),
    );
  }

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w600,
        color: AppTheme.textLight,
        letterSpacing: 1.0,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    bool enabled = true,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? prefix,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(
        fontSize: 14,
        color: enabled ? AppTheme.textDark : AppTheme.textMedium,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
        prefixText: prefix,
        prefixStyle: TextStyle(color: AppTheme.textMedium, fontSize: 14),
        prefixIcon: prefixIcon != null
            ? Icon(prefixIcon, color: AppTheme.textLight, size: 18)
            : null,
        filled: true,
        fillColor:
            enabled ? Colors.white : AppTheme.surfaceVariant.withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.primary, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          borderSide: BorderSide(color: AppTheme.error, width: 1.5),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _onCategoriaChanged(int? categoriaId, List<CategoriaItem> categorias) {
    setState(() {
      _selectedCategoriaId = categoriaId;
      if (categoriaId != null) {
        final cat = categorias.firstWhere(
          (c) => c.id == categoriaId,
          orElse: () => const CategoriaItem(id: -1, nombre: ''),
        );
        final nombre = cat.nombre.toLowerCase();
        if (nombre.contains('aliment') || nombre.contains('bebida') ||
            nombre.contains('pereceder') || nombre.contains('lácteo') ||
            nombre.contains('lacteo') || nombre.contains('carne') ||
            nombre.contains('fruta') || nombre.contains('verdura')) {
          _tieneCaducidad = true;
        }
      }
    });
  }

  Widget _buildCategoriaDropdown(List<CategoriaItem> categorias) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int?>(
          value: _selectedCategoriaId,
          isExpanded: true,
          style: TextStyle(fontSize: 14, color: AppTheme.textDark),
          hint: Text('Sin categoría',
              style: TextStyle(color: AppTheme.textLight, fontSize: 14)),
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMedium),
          items: [
            DropdownMenuItem<int?>(
              value: null,
              child: Text('Sin categoría',
                  style: TextStyle(color: AppTheme.textLight)),
            ),
            ...categorias.map(
              (cat) => DropdownMenuItem<int?>(
                value: cat.id,
                child: Text(cat.nombre),
              ),
            ),
          ],
          onChanged: (v) => _onCategoriaChanged(v, categorias),
        ),
      ),
    );
  }

  Widget _buildCaducidadToggle() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Row(
        children: [
          Icon(
            Icons.event_available_outlined,
            size: 20,
            color: _tieneCaducidad ? AppTheme.primary : AppTheme.textLight,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '¿Este producto expira?',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                Text(
                  'Se pedirá fecha de caducidad en cada entrada',
                  style: TextStyle(fontSize: 11, color: AppTheme.textLight),
                ),
              ],
            ),
          ),
          Switch(
            value: _tieneCaducidad,
            onChanged: (v) => setState(() => _tieneCaducidad = v),
            activeColor: AppTheme.primary,
          ),
        ],
      ),
    );
  }

  Widget _buildUnidadDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _unidadMedida,
          isExpanded: true,
          style: TextStyle(fontSize: 14, color: AppTheme.textDark),
          icon:
              Icon(Icons.keyboard_arrow_down_rounded, color: AppTheme.textMedium),
          items: _unidades
              .map((u) => DropdownMenuItem(value: u, child: Text(u)))
              .toList(),
          onChanged: (v) => setState(() => _unidadMedida = v!),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';

class EditProductScreen extends StatefulWidget {
  final ProductoDetalle producto;

  const EditProductScreen({super.key, required this.producto});

  @override
  State<EditProductScreen> createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nombreCtrl;
  late TextEditingController _skuCtrl;
  late TextEditingController _stockCtrl;
  late TextEditingController _precioCtrl;
  late TextEditingController _ubicacionCtrl;

  int? _selectedCategoriaId;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final p = widget.producto;
    _nombreCtrl = TextEditingController(text: p.nombre);
    _skuCtrl = TextEditingController(text: p.sku);
    _stockCtrl = TextEditingController(text: '${p.stockTotal}');
    _precioCtrl =
        TextEditingController(text: p.precioUnitario.toStringAsFixed(2));
    _ubicacionCtrl = TextEditingController(text: p.ubicacionFisica ?? '');
    _selectedCategoriaId = p.categoriaId;
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _skuCtrl.dispose();
    _stockCtrl.dispose();
    _precioCtrl.dispose();
    _ubicacionCtrl.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    if (!_formKey.currentState!.validate()) return;

    final data = <String, dynamic>{};

    final nombre = _nombreCtrl.text.trim();
    if (nombre.isNotEmpty && nombre != widget.producto.nombre) {
      data['nombre'] = nombre;
    }

    final sku = _skuCtrl.text.trim();
    if (sku.isNotEmpty && sku != widget.producto.sku) {
      data['sku'] = sku;
    }

    final precioStr = _precioCtrl.text.trim();
    final precio = double.tryParse(precioStr);
    if (precio != null && precio != widget.producto.precioUnitario) {
      data['precio_unitario'] = precio;
    }

    final ubicacion = _ubicacionCtrl.text.trim();
    if (ubicacion.isNotEmpty && ubicacion != widget.producto.ubicacionFisica) {
      data['ubicacion_fisica'] = ubicacion;
    }

    if (_selectedCategoriaId != widget.producto.categoriaId) {
      data['categoria_id'] = _selectedCategoriaId;
    }

    final stockStr = _stockCtrl.text.trim();
    final stockNuevo = int.tryParse(stockStr);
    if (stockNuevo != null && stockNuevo != widget.producto.stockTotal) {
      data['cantidad_nueva'] = stockNuevo;
      if (widget.producto.almacenId != null) {
        data['almacen_id'] = widget.producto.almacenId;
      }
    }

    if (data.isEmpty) {
      Navigator.pop(context);
      return;
    }

    setState(() => _isSaving = true);

    final error = await context
        .read<ProductProvider>()
        .updateProducto(widget.producto.id, data);

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppTheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Producto actualizado correctamente'),
          backgroundColor: AppTheme.tertiary,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: AppTheme.neutral,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Editar Producto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: _isSaving ? null : _onSave,
            child: Text(
              'Guardar',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
                color: _isSaving ? AppTheme.textLight : AppTheme.primary,
              ),
            ),
          ),
        ],
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _ImageSection(imagenUrl: widget.producto.imagenUrl),
              const SizedBox(height: 28),

              _SectionHeader('Información General'),
              const SizedBox(height: 16),

              _FieldLabel('NOMBRE DEL PRODUCTO'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _nombreCtrl,
                hint: 'Nombre del producto',
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
              ),
              const SizedBox(height: 16),

              _FieldLabel('SKU'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _skuCtrl,
                hint: 'Identificador SKU',
              ),
              const SizedBox(height: 16),

              _FieldLabel('CATEGORÍA'),
              const SizedBox(height: 6),
              Consumer<ProductProvider>(
                builder: (_, provider, __) {
                  final categorias = provider.categorias;
                  return _buildDropdown(categorias);
                },
              ),
              const SizedBox(height: 16),

              _FieldLabel('PROVEEDOR'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: TextEditingController(
                    text: widget.producto.proveedorNombre ?? '—'),
                hint: 'Proveedor',
                enabled: false,
              ),

              const SizedBox(height: 28),
              _SectionHeader('Inventario y Logística'),
              const SizedBox(height: 16),

              _FieldLabel('STOCK ACTUAL'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _stockCtrl,
                hint: '0',
                keyboardType: TextInputType.number,
                suffix: 'UNIDADES',
              ),
              const SizedBox(height: 16),

              _FieldLabel('PRECIO UNITARIO'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _precioCtrl,
                hint: '0.00',
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                prefix: '\$',
              ),
              const SizedBox(height: 16),

              _FieldLabel('UBICACIÓN EN ALMACÉN'),
              const SizedBox(height: 6),
              _buildTextField(
                controller: _ubicacionCtrl,
                hint: 'Ej. Pasillo A-4, Estante 2',
                prefixIcon: Icons.location_on_outlined,
              ),

              if (widget.producto.movimientosRecientes.isNotEmpty) ...[
                const SizedBox(height: 24),
                _LastMovementInfo(
                  ultimaFecha: widget.producto.movimientosRecientes.first
                      .fechaMovimiento,
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _onSave,
                  icon: _isSaving
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.update_rounded),
                  label: Text(
                    _isSaving ? 'Guardando...' : 'Actualizar Registro',
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w700),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    foregroundColor: Colors.white,
                    disabledBackgroundColor:
                        AppTheme.primaryDark.withValues(alpha: 0.5),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    bool enabled = true,
    TextInputType? keyboardType,
    String? suffix,
    String? prefix,
    IconData? prefixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
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
        suffixText: suffix,
        suffixStyle: TextStyle(
          color: AppTheme.primary,
          fontSize: 12,
          fontWeight: FontWeight.w700,
        ),
        filled: true,
        fillColor: enabled ? Colors.white : AppTheme.surfaceVariant.withValues(alpha: 0.3),
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
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildDropdown(List<CategoriaItem> categorias) {
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
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMedium),
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
          onChanged: (v) => setState(() => _selectedCategoriaId = v),
        ),
      ),
    );
  }
}

class _ImageSection extends StatelessWidget {
  final String? imagenUrl;

  const _ImageSection({this.imagenUrl});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTheme.radiusXl),
                child: imagenUrl != null
                    ? Image.network(
                        imagenUrl!,
                        width: 120,
                        height: 120,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _placeholder(),
                      )
                    : _placeholder(),
              ),
              Positioned(
                bottom: 4,
                right: 4,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.primary,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(Icons.camera_alt_outlined,
                      color: Colors.white, size: 16),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'IMAGEN DEL PRODUCTO',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
              letterSpacing: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _placeholder() {
    return Container(
      width: 120,
      height: 120,
      color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
      child: Icon(Icons.inventory_2_outlined,
          color: AppTheme.textLight, size: 40),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader(this.title);

  @override
  Widget build(BuildContext context) {
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
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) {
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
}

class _LastMovementInfo extends StatelessWidget {
  final String? ultimaFecha;
  const _LastMovementInfo({this.ultimaFecha});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppTheme.primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
            color: AppTheme.primary.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: AppTheme.primary, size: 16),
          const SizedBox(width: 8),
          Text(
            'ÚLTIMO MOVIMIENTO: ${ultimaFecha ?? "—"}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppTheme.primary,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/supplier_provider.dart';
import '../services/supplier_service.dart';
import '../utilities/msg_util.dart';

class EditSupplierScreen extends StatefulWidget {
  final int? proveedorId;

  const EditSupplierScreen({super.key, this.proveedorId});

  bool get isEditing => proveedorId != null;

  @override
  State<EditSupplierScreen> createState() => _EditSupplierScreenState();
}

class _EditSupplierScreenState extends State<EditSupplierScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nombreCtrl = TextEditingController();
  final _contactoNombreCtrl = TextEditingController();
  final _contactoEmailCtrl = TextEditingController();
  final _contactoTelefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();
  final _diasEntregaCtrl = TextEditingController(text: '5');
  final _notasCtrl = TextEditingController();

  String? _selectedCategoria;
  bool _isSaving = false;
  bool _initialized = false;

  static const _categorias = [
    'Mobiliario',
    'Iluminación',
    'Revestimientos',
    'Pinturas & Acabados',
    'Carpintería',
    'Textiles',
    'Papelería',
    'Electrónica',
    'Otros',
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.isEditing) {
        context.read<SupplierProvider>().loadDetalle(widget.proveedorId!);
      }
    });
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _contactoNombreCtrl.dispose();
    _contactoEmailCtrl.dispose();
    _contactoTelefonoCtrl.dispose();
    _direccionCtrl.dispose();
    _diasEntregaCtrl.dispose();
    _notasCtrl.dispose();
    super.dispose();
  }

  void _initFromProveedor(ProveedorDetalle p) {
    if (_initialized) return;
    _nombreCtrl.text = p.nombre;
    _contactoNombreCtrl.text = p.contactoNombre ?? '';
    _contactoEmailCtrl.text = p.contactoEmail ?? '';
    _contactoTelefonoCtrl.text = p.contactoTelefono ?? '';
    _direccionCtrl.text = p.direccion ?? '';
    _diasEntregaCtrl.text = '${p.diasEntrega ?? 5}';
    _notasCtrl.text = p.notas ?? '';
    _selectedCategoria = p.categoria != null &&
            _categorias.contains(p.categoria)
        ? p.categoria
        : null;
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
      if (_selectedCategoria != null) 'categoria': _selectedCategoria,
      if (_contactoNombreCtrl.text.trim().isNotEmpty)
        'contacto_nombre': _contactoNombreCtrl.text.trim(),
      if (_contactoEmailCtrl.text.trim().isNotEmpty)
        'contacto_email': _contactoEmailCtrl.text.trim(),
      if (_contactoTelefonoCtrl.text.trim().isNotEmpty)
        'contacto_telefono': _contactoTelefonoCtrl.text.trim(),
      if (_direccionCtrl.text.trim().isNotEmpty)
        'direccion': _direccionCtrl.text.trim(),
      'dias_entrega': int.tryParse(_diasEntregaCtrl.text) ?? 5,
      if (_notasCtrl.text.trim().isNotEmpty)
        'notas': _notasCtrl.text.trim(),
    };
    final error =
        await context.read<SupplierProvider>().createProveedor(data);
    if (!mounted) return;
    setState(() => _isSaving = false);
    if (error != null) {
      MsgtUtil.showError(context, error);
    } else {
      Navigator.pop(context, true);
    }
  }

  Future<void> _doEdit() async {
    final provider = context.read<SupplierProvider>();
    final original = provider.selectedProveedor!;
    final data = <String, dynamic>{};

    final nombre = _nombreCtrl.text.trim();
    if (nombre.isNotEmpty && nombre != original.nombre) {
      data['nombre'] = nombre;
    }

    if (_selectedCategoria != original.categoria) {
      data['categoria'] = _selectedCategoria;
    }

    final contactoNombre = _contactoNombreCtrl.text.trim();
    if (contactoNombre != (original.contactoNombre ?? '')) {
      data['contacto_nombre'] =
          contactoNombre.isNotEmpty ? contactoNombre : null;
    }

    final contactoEmail = _contactoEmailCtrl.text.trim();
    if (contactoEmail != (original.contactoEmail ?? '')) {
      data['contacto_email'] =
          contactoEmail.isNotEmpty ? contactoEmail : null;
    }

    final contactoTelefono = _contactoTelefonoCtrl.text.trim();
    if (contactoTelefono != (original.contactoTelefono ?? '')) {
      data['contacto_telefono'] =
          contactoTelefono.isNotEmpty ? contactoTelefono : null;
    }

    final direccion = _direccionCtrl.text.trim();
    if (direccion != (original.direccion ?? '')) {
      data['direccion'] = direccion.isNotEmpty ? direccion : null;
    }

    final diasEntrega = int.tryParse(_diasEntregaCtrl.text.trim());
    if (diasEntrega != null && diasEntrega != original.diasEntrega) {
      data['dias_entrega'] = diasEntrega;
    }

    final notas = _notasCtrl.text.trim();
    if (notas != (original.notas ?? '')) {
      data['notas'] = notas.isNotEmpty ? notas : null;
    }

    if (data.isEmpty) {
      setState(() => _isSaving = false);
      Navigator.pop(context);
      return;
    }

    final error =
        await provider.updateProveedor(widget.proveedorId!, data);
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
    return Consumer<SupplierProvider>(
      builder: (context, provider, _) {
        if (widget.isEditing) {
          if (provider.isLoadingDetail) {
            return Scaffold(
              backgroundColor: AppTheme.neutral,
              appBar: _buildAppBar(),
              body: const Center(
                child:
                    CircularProgressIndicator(color: AppTheme.primaryDark),
              ),
            );
          }
          final p = provider.selectedProveedor;
          if (p == null) {
            return Scaffold(
              backgroundColor: AppTheme.neutral,
              appBar: _buildAppBar(),
              body: Center(
                child: Text('Proveedor no encontrado',
                    style: TextStyle(color: AppTheme.textMedium)),
              ),
            );
          }
          _initFromProveedor(p);
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
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: _buildContent(),
                  ),
                ),
                _buildBottomBar(),
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
        widget.isEditing ? 'Editar Proveedor' : 'Nuevo Proveedor',
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: AppTheme.textDark,
          fontFamily: 'Noto Serif',
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Título descriptivo
        const SizedBox(height: 8),
        Text(
          widget.isEditing
              ? 'Editar Socio Comercial'
              : 'Registro de Socio\nComercial',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
            height: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          widget.isEditing
              ? 'Actualiza la información de este proveedor en tu red logística.'
              : 'Inicia la integración de un nuevo colaborador en tu red logística. Los detalles precisos aseguran una gestión de inventario impecable.',
          style: TextStyle(
            fontSize: 13,
            color: AppTheme.textMedium,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 20),

        // Avatar / Logo
        Center(
          child: Stack(
            children: [
              Container(
                width: 88,
                height: 88,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  shape: BoxShape.circle,
                  border:
                      Border.all(color: AppTheme.divider, width: 1.5),
                ),
                child: Icon(Icons.camera_alt_outlined,
                    color: AppTheme.textLight, size: 28),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryDark,
                    shape: BoxShape.circle,
                    border: Border.all(
                        color: AppTheme.neutral, width: 2),
                  ),
                  child: const Icon(Icons.edit,
                      color: Colors.white, size: 12),
                ),
              ),
            ],
          ),
        ),
        Center(
          child: Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text(
              'LOGOTIPO EMPRESA',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppTheme.textLight,
                letterSpacing: 1.0,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        // ── Sección 1: Información de Empresa ──────────────────────
        _buildSectionCard(
          icon: Icons.business_outlined,
          title: 'Información de Empresa',
          children: [
            _buildFieldLabel('Nombre Comercial'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _nombreCtrl,
              hint: 'Ej. Artisan Woodworks',
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Campo requerido' : null,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Categoría'),
            const SizedBox(height: 6),
            _buildCategoriaDropdown(),
          ],
        ),
        const SizedBox(height: 16),

        // ── Sección 2: Contacto Principal ──────────────────────────
        _buildSectionCard(
          icon: Icons.person_outline_rounded,
          title: 'Contacto Principal',
          children: [
            _buildFieldLabel('Nombre Completo'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _contactoNombreCtrl,
              hint: 'Nombre del responsable',
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Correo Electrónico'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _contactoEmailCtrl,
              hint: 'email@empresa.com',
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Teléfono'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _contactoTelefonoCtrl,
              hint: '+34 000 000 000',
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        const SizedBox(height: 16),

        // ── Sección 3: Logística y Fiscalidad ─────────────────────
        _buildSectionCard(
          icon: Icons.local_shipping_outlined,
          title: 'Logística y Fiscalidad',
          children: [
            _buildFieldLabel('Dirección Fiscal'),
            const SizedBox(height: 6),
            _buildTextField(
              controller: _direccionCtrl,
              hint: 'Calle, Número, Ciudad, CP y País',
              maxLines: 2,
            ),
            const SizedBox(height: 16),
            _buildFieldLabel('Días de Entrega Estimados'),
            const SizedBox(height: 6),
            // Input especial con icono reloj
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(color: AppTheme.divider),
              ),
              child: Row(
                children: [
                  Icon(Icons.schedule_outlined,
                      size: 18, color: AppTheme.textLight),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextFormField(
                      controller: _diasEntregaCtrl,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly
                      ],
                      decoration: InputDecoration(
                        hintText: '5',
                        hintStyle: TextStyle(
                            color: AppTheme.textLight, fontSize: 14),
                        border: InputBorder.none,
                        enabledBorder: InputBorder.none,
                        focusedBorder: InputBorder.none,
                        contentPadding: EdgeInsets.zero,
                        isDense: true,
                      ),
                      style: TextStyle(
                          fontSize: 14, color: AppTheme.textDark),
                    ),
                  ),
                  Text('Días',
                      style: TextStyle(
                          fontSize: 13, color: AppTheme.textMedium)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            // Info box azul
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF5A8FBF).withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: const Color(0xFF5A8FBF).withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Icon(Icons.info_outline,
                      size: 14,
                      color: const Color(0xFF5A8FBF)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Este plazo afecta al cálculo de reposición automática.',
                      style: TextStyle(
                        fontSize: 11,
                        color: const Color(0xFF5A8FBF),
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),

        // Disclaimer legal
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Al guardar, los datos serán verificados con el Registro Mercantil. Asegúrese de que el CIF/VAT sea correcto.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 10,
              color: AppTheme.textLight,
              height: 1.5,
              letterSpacing: 0.2,
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }

  Widget _buildSectionCard({
    required IconData icon,
    required String title,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
                child: Icon(icon, size: 16, color: AppTheme.primaryDark),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  fontFamily: 'Noto Serif',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      decoration: BoxDecoration(
        color: AppTheme.neutral,
        border: Border(top: BorderSide(color: AppTheme.divider)),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.close, size: 16),
              label: const Text('Cancelar'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.textDark,
                side: BorderSide(color: AppTheme.divider),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _isSaving ? null : _save,
              icon: _isSaving
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : const Icon(Icons.save_outlined, size: 16),
              label: Text(
                _isSaving
                    ? 'Guardando...'
                    : (widget.isEditing
                        ? 'Actualizar Proveedor'
                        : 'Guardar Proveedor'),
                style: const TextStyle(
                    fontSize: 14, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                disabledBackgroundColor:
                    AppTheme.primaryDark.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Helpers ────────────────────────────────────────────────────────────────

  Widget _buildFieldLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: AppTheme.textMedium,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    int maxLines = 1,
    TextInputType? keyboardType,
    List<TextInputFormatter>? inputFormatters,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      style: TextStyle(fontSize: 14, color: AppTheme.textDark),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
        filled: true,
        fillColor: AppTheme.neutral,
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
            const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget _buildCategoriaDropdown() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.neutral,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: AppTheme.divider),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String?>(
          value: _selectedCategoria,
          isExpanded: true,
          style: TextStyle(fontSize: 14, color: AppTheme.textDark),
          hint: Text('Mobiliario',
              style:
                  TextStyle(color: AppTheme.textLight, fontSize: 14)),
          icon: Icon(Icons.keyboard_arrow_down_rounded,
              color: AppTheme.textMedium),
          items: [
            DropdownMenuItem<String?>(
              value: null,
              child: Text('Sin categoría',
                  style: TextStyle(color: AppTheme.textLight)),
            ),
            ..._categorias.map(
              (cat) => DropdownMenuItem<String?>(
                value: cat,
                child: Text(cat),
              ),
            ),
          ],
          onChanged: (v) => setState(() => _selectedCategoria = v),
        ),
      ),
    );
  }
}

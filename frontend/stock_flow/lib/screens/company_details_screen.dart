import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/auth_provider.dart';
import '../services/settings_service.dart';

class CompanyDetailsScreen extends StatefulWidget {
  const CompanyDetailsScreen({super.key});

  @override
  State<CompanyDetailsScreen> createState() => _CompanyDetailsScreenState();
}

class _CompanyDetailsScreenState extends State<CompanyDetailsScreen> {
  final SettingsService _service = SettingsService();

  Map<String, dynamic>? _empresa;
  bool _isLoading = true;
  bool _isEditing = false;
  bool _isSaving = false;

  final _formKey = GlobalKey<FormState>();
  final _razonSocialCtrl = TextEditingController();
  final _nombreComercialCtrl = TextEditingController();
  final _rfcCtrl = TextEditingController();
  final _correoCtrl = TextEditingController();
  final _telefonoCtrl = TextEditingController();
  final _direccionCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadEmpresa();
  }

  @override
  void dispose() {
    _razonSocialCtrl.dispose();
    _nombreComercialCtrl.dispose();
    _rfcCtrl.dispose();
    _correoCtrl.dispose();
    _telefonoCtrl.dispose();
    _direccionCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadEmpresa() async {
    setState(() => _isLoading = true);
    final data = await _service.getEmpresa();
    if (!mounted) return;
    setState(() {
      _empresa = data;
      _isLoading = false;
      if (data != null) _fillControllers(data);
    });
  }

  void _fillControllers(Map<String, dynamic> data) {
    _razonSocialCtrl.text = data['razon_social'] ?? '';
    _nombreComercialCtrl.text = data['nombre_comercial'] ?? '';
    _rfcCtrl.text = data['rfc'] ?? '';
    _correoCtrl.text = data['correo_electronico'] ?? '';
    _telefonoCtrl.text = data['telefono_principal'] ?? '';
    _direccionCtrl.text = data['direccion_fiscal'] ?? '';
  }

  Future<void> _saveEmpresa() async {
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() => _isSaving = true);

    final error = await _service.updateEmpresa({
      'razon_social': _razonSocialCtrl.text.trim(),
      'nombre_comercial': _nombreComercialCtrl.text.trim().isEmpty ? null : _nombreComercialCtrl.text.trim(),
      'rfc': _rfcCtrl.text.trim().isEmpty ? null : _rfcCtrl.text.trim(),
      'correo_electronico': _correoCtrl.text.trim().isEmpty ? null : _correoCtrl.text.trim(),
      'telefono_principal': _telefonoCtrl.text.trim().isEmpty ? null : _telefonoCtrl.text.trim(),
      'direccion_fiscal': _direccionCtrl.text.trim().isEmpty ? null : _direccionCtrl.text.trim(),
    });

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (error != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(error),
        backgroundColor: AppTheme.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
      ));
      return;
    }

    await _loadEmpresa();
    setState(() => _isEditing = false);

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Row(children: [
        Icon(Icons.check_circle, color: Colors.white),
        SizedBox(width: 8),
        Text('Empresa actualizada correctamente'),
      ]),
      backgroundColor: AppTheme.success,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = context.watch<AuthProvider>().isAdmin;

    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          SliverAppBar(
            expandedHeight: 180.0,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: AppTheme.textOnPrimary,
            actions: [
              if (isAdmin && !_isLoading)
                _isEditing
                    ? IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          if (_empresa != null) _fillControllers(_empresa!);
                          setState(() => _isEditing = false);
                        },
                      )
                    : IconButton(
                        icon: const Icon(Icons.edit_outlined),
                        onPressed: () => setState(() => _isEditing = true),
                      ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _isEditing ? 'Editar Empresa' : 'Perfil de Empresa',
                style: const TextStyle(
                  color: AppTheme.textOnPrimary,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppTheme.primaryDark, AppTheme.primary],
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                      ),
                    ),
                  ),
                  Positioned(
                    right: -40,
                    top: -40,
                    child: Icon(Icons.domain, size: 200, color: Colors.white.withOpacity(0.1)),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: _isLoading
                ? const Padding(
                    padding: EdgeInsets.all(48),
                    child: Center(child: CircularProgressIndicator()),
                  )
                : _empresa == null
                    ? Padding(
                        padding: const EdgeInsets.all(48),
                        child: Center(
                          child: Column(children: [
                            const Icon(Icons.error_outline, color: AppTheme.error, size: 48),
                            const SizedBox(height: 16),
                            const Text('No se pudo cargar la información de la empresa',
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.textMedium)),
                            const SizedBox(height: 16),
                            TextButton(onPressed: _loadEmpresa, child: const Text('Reintentar')),
                          ]),
                        ),
                      )
                    : _isEditing
                        ? _buildEditForm()
                        : _buildViewMode(),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode() {
    final e = _empresa!;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 100,
              height: 100,
              margin: const EdgeInsets.only(bottom: AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: AppTheme.elevatedShadow,
                image: const DecorationImage(
                  image: NetworkImage('https://ui-avatars.com/api/?name=SF&background=34B19B&color=fff&size=200'),
                  fit: BoxFit.cover,
                ),
                border: Border.all(color: AppTheme.neutral, width: 4),
              ),
            ),
          ),

          _buildSectionTitle('Información General'),
          _buildInfoCard([
            _buildInfoRow(Icons.business, 'Razón Social', e['razon_social'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.storefront_outlined, 'Nombre Comercial', e['nombre_comercial'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.badge_outlined, 'RFC / Tax ID', e['rfc'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de Registro', e['fecha_registro'] ?? '-'),
          ]),

          const SizedBox(height: AppTheme.spacingXl),

          _buildSectionTitle('Contacto y Ubicación'),
          _buildInfoCard([
            _buildInfoRow(Icons.email_outlined, 'Correo Electrónico', e['correo_electronico'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.phone_outlined, 'Teléfono Principal', e['telefono_principal'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.location_on_outlined, 'Dirección Fiscal',
                e['direccion_fiscal'] ?? '-', isMultiline: true),
          ]),

          const SizedBox(height: AppTheme.spacingXl),

          _buildSectionTitle('Suscripción y Límites'),
          _buildInfoCard([
            _buildInfoRow(Icons.star_outline, 'Plan Actual', e['plan_suscripcion'] ?? '-'),
            _buildDivider(),
            _buildInfoRow(Icons.inventory_2_outlined, 'Límite de Almacenes',
                '${e['limite_almacenes'] ?? '-'}'),
          ]),

          const SizedBox(height: AppTheme.spacingXl * 2),
        ],
      ),
    );
  }

  Widget _buildEditForm() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildFormSection(title: 'Información General', children: [
              _buildField(_razonSocialCtrl, 'Razón Social', Icons.business, required: true),
              const SizedBox(height: AppTheme.spacingMd),
              _buildField(_nombreComercialCtrl, 'Nombre Comercial', Icons.storefront_outlined),
              const SizedBox(height: AppTheme.spacingMd),
              _buildField(_rfcCtrl, 'RFC / Tax ID', Icons.badge_outlined),
            ]),
            const SizedBox(height: AppTheme.spacingLg),
            _buildFormSection(title: 'Contacto y Ubicación', children: [
              _buildField(_correoCtrl, 'Correo Electrónico', Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress),
              const SizedBox(height: AppTheme.spacingMd),
              _buildField(_telefonoCtrl, 'Teléfono Principal', Icons.phone_outlined,
                  keyboardType: TextInputType.phone),
              const SizedBox(height: AppTheme.spacingMd),
              _buildField(_direccionCtrl, 'Dirección Fiscal', Icons.location_on_outlined,
                  maxLines: 3),
            ]),
            const SizedBox(height: AppTheme.spacingXl),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isSaving ? null : _saveEmpresa,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Guardar Cambios'),
              ),
            ),
            const SizedBox(height: AppTheme.spacingXl * 2),
          ],
        ),
      ),
    );
  }

  Widget _buildFormSection({required String title, required List<Widget> children}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppTheme.textDark, fontSize: 16, fontWeight: FontWeight.bold)),
          const SizedBox(height: AppTheme.spacingLg),
          ...children,
        ],
      ),
    );
  }

  Widget _buildField(
    TextEditingController ctrl,
    String label,
    IconData icon, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool required = false,
  }) {
    return TextFormField(
      controller: ctrl,
      keyboardType: keyboardType,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: maxLines == 1 ? Icon(icon, color: AppTheme.primary) : null,
        alignLabelWithHint: maxLines > 1,
      ),
      validator: required
          ? (v) => (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null
          : null,
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd, left: 4),
      child: Text(title,
          style: const TextStyle(
              color: AppTheme.textMedium, fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: 0.5)),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, {bool isMultiline = false}) {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        crossAxisAlignment: isMultiline ? CrossAxisAlignment.start : CrossAxisAlignment.center,
        children: [
          Icon(icon, color: AppTheme.textLight, size: 22),
          const SizedBox(width: AppTheme.spacingMd),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: AppTheme.textLight, fontSize: 12, fontWeight: FontWeight.w500)),
                const SizedBox(height: 2),
                Text(value,
                    style: const TextStyle(color: AppTheme.textDark, fontSize: 14, fontWeight: FontWeight.w600),
                    softWrap: isMultiline,
                    maxLines: isMultiline ? null : 1,
                    overflow: isMultiline ? null : TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
        height: 1, thickness: 1, color: AppTheme.divider, indent: AppTheme.spacingMd * 2 + 22);
  }
}

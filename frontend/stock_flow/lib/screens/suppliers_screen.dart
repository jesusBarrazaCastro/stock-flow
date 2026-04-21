import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/supplier_provider.dart';
import '../services/supplier_service.dart';
import '../utilities/msg_util.dart';
import 'supplier_detail_screen.dart';
import 'edit_supplier_screen.dart';

class SuppliersScreen extends StatefulWidget {
  const SuppliersScreen({super.key});

  @override
  State<SuppliersScreen> createState() => _SuppliersScreenState();
}

class _SuppliersScreenState extends State<SuppliersScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().loadProveedores(resetPage: true);
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchCtrl.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      context.read<SupplierProvider>().setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        backgroundColor: AppTheme.neutral,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Proveedores',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Barra de búsqueda
                      _buildSearchBar(provider),
                      const SizedBox(height: 16),

                      // Card de Resumen de Red
                      _buildRedSummaryCard(provider),
                      const SizedBox(height: 16),

                      // Lista de proveedores
                      _buildProveedorList(provider),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              if (provider.totalPages > 1) _buildPaginationBar(provider),
            ],
          );
        },
      ),
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Label del FAB
          
          const SizedBox(height: 8),
          FloatingActionButton.extended(
            onPressed: () async {
              final added = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                    builder: (_) => const EditSupplierScreen()),
              );
              if (added == true && context.mounted) {
                MsgtUtil.showSuccess(context, 'Proveedor añadido correctamente');
                context
                    .read<SupplierProvider>()
                    .loadProveedores(resetPage: true);
              }
            },
            backgroundColor: AppTheme.primary,
            icon: const Icon(Icons.add, color: Colors.white),
            label: const Text(
              'Añadir Proveedor',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  Widget _buildSearchBar(SupplierProvider provider) {
    return Row(
      children: [
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              boxShadow: AppTheme.cardShadow,
            ),
            child: TextField(
              controller: _searchCtrl,
              onChanged: _onSearchChanged,
              decoration: InputDecoration(
                hintText: 'Buscar por nombre o categoría...',
                hintStyle: TextStyle(fontSize: 14, color: AppTheme.textLight),
                prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close,
                            color: AppTheme.textLight, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<SupplierProvider>().setSearch(null);
                        },
                      )
                    : null,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _showAdvancedFilters,
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: provider.hasActiveFilters
                      ? AppTheme.primary
                      : AppTheme.primaryDark,
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                child: const Icon(Icons.tune_rounded, color: Colors.white),
              ),
              if (provider.hasActiveFilters)
                Positioned(
                  top: -4,
                  right: -4,
                  child: Container(
                    width: 10,
                    height: 10,
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _showAdvancedFilters() {
    final provider = context.read<SupplierProvider>();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SupplierFiltersSheet(
        estadoActual: provider.estadoFiltro,
        categoriaActual: provider.categoriaFiltro,
        maxDiasActual: provider.maxDiasFiltro,
        categoriasDisponibles: provider.categoriasDisponibles,
        onApply: ({required String? estado, required String? categoria, required int? maxDias}) {
          provider.applyFilters(
            estado: estado,
            categoria: categoria,
            maxDias: maxDias,
          );
        },
        onClear: provider.clearFilters,
      ),
    );
  }

  Widget _buildRedSummaryCard(SupplierProvider provider) {
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
          Text(
            'RESUMEN DE RED',
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppTheme.textLight,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${provider.aliadosTotal}',
                style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  fontFamily: 'Noto Serif',
                  height: 1.0,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                'Aliados Activos',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMedium,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _StatPill(
                value: '${provider.nuevos}',
                label: 'NUEVOS (7D)',
                color: AppTheme.tertiary,
              ),
              const SizedBox(width: 10),
              _StatPill(
                value: '${provider.enRevision}',
                label: 'EN REVISIÓN',
                color: AppTheme.warning,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProveedorList(SupplierProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(40),
          child: CircularProgressIndicator(color: AppTheme.primaryDark),
        ),
      );
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 12),
            Text('Error al cargar proveedores',
                style: TextStyle(color: AppTheme.textMedium)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () =>
                  provider.loadProveedores(resetPage: true),
              child: Text('Reintentar',
                  style: TextStyle(color: AppTheme.primaryDark)),
            ),
          ],
        ),
      );
    }
    if (provider.proveedores.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(40),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.storefront_outlined,
                  color: AppTheme.textLight, size: 56),
              const SizedBox(height: 16),
              Text(
                'No hay proveedores',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textMedium,
                  fontFamily: 'Noto Serif',
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Añade tu primer socio comercial',
                style: TextStyle(fontSize: 13, color: AppTheme.textLight),
              ),
            ],
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.proveedores.length,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (context, i) => _ProveedorCard(
        proveedor: provider.proveedores[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => SupplierDetailScreen(
                proveedorId: provider.proveedores[i].id),
          ),
        ),
      ),
    );
  }

  Widget _buildPaginationBar(SupplierProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      color: AppTheme.neutral,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: provider.currentPage > 1
                ? () => provider.setPage(provider.currentPage - 1)
                : null,
            icon: Icon(
              Icons.chevron_left_rounded,
              color: provider.currentPage > 1
                  ? AppTheme.primaryDark
                  : AppTheme.textLight,
            ),
          ),
          Text(
            'Página ${provider.currentPage} de ${provider.totalPages}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          IconButton(
            onPressed: provider.currentPage < provider.totalPages
                ? () => provider.setPage(provider.currentPage + 1)
                : null,
            icon: Icon(
              Icons.chevron_right_rounded,
              color: provider.currentPage < provider.totalPages
                  ? AppTheme.primaryDark
                  : AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Stat Pill ────────────────────────────────────────────────────────────────
class _StatPill extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatPill(
      {required this.value, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: color,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: color,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Proveedor Card ───────────────────────────────────────────────────────────
class _ProveedorCard extends StatelessWidget {
  final ProveedorItem proveedor;
  final VoidCallback onTap;

  const _ProveedorCard({required this.proveedor, required this.onTap});

  Color get _badgeColor {
    switch (proveedor.estado) {
      case 'EN_REVISION':
        return AppTheme.warning;
      default:
        return AppTheme.tertiary;
    }
  }

  String get _badgeLabel {
    switch (proveedor.estado) {
      case 'EN_REVISION':
        return 'EN REVISIÓN';
      default:
        return 'ACTIVO';
    }
  }

  Color _categoryColor() {
    // Paleta de colores por categoría
    final cats = {
      'mobiliario': const Color(0xFF8B5E3C),
      'iluminación': const Color(0xFFE8A84A),
      'revestimientos': const Color(0xFF6B8E6B),
      'pinturas': const Color(0xFF5A8FBF),
      'carpintería': const Color(0xFFB87333),
      'textiles': const Color(0xFF9B6B9B),
    };
    final key = (proveedor.categoria ?? '').toLowerCase();
    for (final entry in cats.entries) {
      if (key.contains(entry.key)) return entry.value;
    }
    return AppTheme.primaryDark;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Avatar / Logo
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: _categoryColor().withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                    color: _categoryColor().withValues(alpha: 0.3), width: 1.5),
              ),
              child: proveedor.logoUrl != null
                  ? ClipRRect(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusMd - 1),
                      child: Image.network(proveedor.logoUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) =>
                              _iconPlaceholder()),
                    )
                  : _iconPlaceholder(),
            ),
            const SizedBox(width: 14),

            // Contenido
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nombre + badge estado
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          proveedor.nombre,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                            fontFamily: 'Noto Serif',
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                          color: _badgeColor.withValues(alpha: 0.12),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusFull),
                        ),
                        child: Text(
                          _badgeLabel,
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            color: _badgeColor,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),

                  // Categoría
                  if (proveedor.categoria != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      proveedor.categoria!.toUpperCase(),
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _categoryColor(),
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                  const SizedBox(height: 8),

                  // Contacto
                  if (proveedor.contactoNombre != null)
                    _InfoRow(
                      icon: Icons.person_outline_rounded,
                      text: proveedor.contactoNombre!,
                    ),
                  if (proveedor.contactoEmail != null)
                    _InfoRow(
                      icon: Icons.mail_outline_rounded,
                      text: proveedor.contactoEmail!,
                    ),
                ],
              ),
            ),

            // Flecha
            Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Icon(Icons.chevron_right_rounded,
                  color: AppTheme.textLight, size: 20),
            ),
          ],
        ),
      ),
    );
  }

  Widget _iconPlaceholder() {
    return Icon(Icons.storefront_outlined,
        color: _categoryColor(), size: 26);
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        children: [
          Icon(icon, size: 12, color: AppTheme.textLight),
          const SizedBox(width: 5),
          Expanded(
            child: Text(
              text,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Filtros Sheet ────────────────────────────────────────────────────────────
class _SupplierFiltersSheet extends StatefulWidget {
  final String? estadoActual;
  final String? categoriaActual;
  final int? maxDiasActual;
  final List<String> categoriasDisponibles;
  final void Function({
    required String? estado,
    required String? categoria,
    required int? maxDias,
  }) onApply;
  final VoidCallback onClear;

  const _SupplierFiltersSheet({
    required this.estadoActual,
    required this.categoriaActual,
    required this.maxDiasActual,
    required this.categoriasDisponibles,
    required this.onApply,
    required this.onClear,
  });

  @override
  State<_SupplierFiltersSheet> createState() => _SupplierFiltersSheetState();
}

class _SupplierFiltersSheetState extends State<_SupplierFiltersSheet> {
  String? _estado;
  String? _categoria;
  int? _maxDias;

  static const _diasOpciones = [3, 7, 15, 30];

  @override
  void initState() {
    super.initState();
    _estado = widget.estadoActual;
    _categoria = widget.categoriaActual;
    _maxDias = widget.maxDiasActual;
  }

  bool get _hasChanges =>
      _estado != widget.estadoActual ||
      _categoria != widget.categoriaActual ||
      _maxDias != widget.maxDiasActual;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(
          24, 20, 24, MediaQuery.of(context).viewInsets.bottom + 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.surfaceVariant,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  fontFamily: 'Noto Serif',
                ),
              ),
              if (widget.estadoActual != null ||
                  widget.categoriaActual != null ||
                  widget.maxDiasActual != null)
                TextButton(
                  onPressed: () {
                    widget.onClear();
                    Navigator.pop(context);
                  },
                  child: Text(
                    'Limpiar todo',
                    style: TextStyle(
                      color: AppTheme.error,
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 24),

          // ── Estado ──────────────────────────────────────────────
          _buildSectionLabel('ESTADO'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Todos',
                isSelected: _estado == null,
                onTap: () => setState(() => _estado = null),
              ),
              _FilterChip(
                label: 'Activo',
                isSelected: _estado == 'ACTIVO',
                onTap: () => setState(
                    () => _estado = _estado == 'ACTIVO' ? null : 'ACTIVO'),
                activeColor: AppTheme.tertiary,
              ),
              _FilterChip(
                label: 'En revisión',
                isSelected: _estado == 'EN_REVISION',
                onTap: () => setState(() =>
                    _estado = _estado == 'EN_REVISION' ? null : 'EN_REVISION'),
                activeColor: AppTheme.warning,
              ),
            ],
          ),
          const SizedBox(height: 20),

          // ── Categoría ────────────────────────────────────────────
          if (widget.categoriasDisponibles.isNotEmpty) ...[
            _buildSectionLabel('CATEGORÍA'),
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _FilterChip(
                  label: 'Todas',
                  isSelected: _categoria == null,
                  onTap: () => setState(() => _categoria = null),
                ),
                ...widget.categoriasDisponibles.map((cat) => _FilterChip(
                      label: cat,
                      isSelected: _categoria == cat,
                      onTap: () => setState(
                          () => _categoria = _categoria == cat ? null : cat),
                    )),
              ],
            ),
            const SizedBox(height: 20),
          ],

          // ── Días de entrega ──────────────────────────────────────
          _buildSectionLabel('DÍAS DE ENTREGA'),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            children: [
              _FilterChip(
                label: 'Cualquiera',
                isSelected: _maxDias == null,
                onTap: () => setState(() => _maxDias = null),
              ),
              ..._diasOpciones.map((d) => _FilterChip(
                    label: '≤ $d días',
                    isSelected: _maxDias == d,
                    onTap: () =>
                        setState(() => _maxDias = _maxDias == d ? null : d),
                  )),
            ],
          ),
          const SizedBox(height: 28),

          // ── Botón aplicar ────────────────────────────────────────
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(
                  estado: _estado,
                  categoria: _categoria,
                  maxDias: _maxDias,
                );
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                elevation: 0,
              ),
              child: Text(
                _hasChanges ? 'Aplicar filtros' : 'Cerrar',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w700,
          color: AppTheme.textLight,
          letterSpacing: 1.2,
        ),
      );
}

// ─── Filter Chip ──────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  final Color? activeColor;

  const _FilterChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppTheme.primaryDark;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color : AppTheme.surfaceVariant,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? color : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? Colors.white : AppTheme.textMedium,
          ),
        ),
      ),
    );
  }
}

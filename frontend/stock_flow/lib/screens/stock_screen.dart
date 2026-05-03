import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/stock_provider.dart';
import '../services/stock_service.dart';
import '../utilities/msg_util.dart';
import 'catalog_screen.dart';
import 'product_detail_screen.dart';
import 'suppliers_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int _selectedFilterIndex = 0;

  // Mapa chip → estado_stock (null = Todo), 'EXPIRA_PRONTO' se filtra por expiraProto
  final List<String?> _chipEstados = [null, 'STOCK_BAJO', 'AGOTADO', 'EXCESO', 'EXPIRA_PRONTO'];
  final List<String> _chipLabels = ['Todo', 'Stock Bajo', 'Agotado', 'Exceso', 'Expira Pronto'];

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<StockProvider>();
      provider.loadStock();
      provider.loadCategorias();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StockProvider>(
      builder: (context, provider, _) {
        // Mostrar error si hubo uno
        if (provider.error != null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) {
              MsgtUtil.showError(context, provider.error!);
            }
          });
        }

        final items = provider.filtered;

        return Scaffold(
          backgroundColor: AppTheme.neutral,
          body: SafeArea(
            child: RefreshIndicator(
              color: AppTheme.primaryDark,
              onRefresh: provider.refresh,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 10),

                    // ── Top Action Cards ──────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const SuppliersScreen()),
                            ),
                            child: _buildActionCard(
                              icon: Icons.local_shipping_outlined,
                              title: 'Gestión de\nProveedores',
                              subtitle: 'DIRECTORIOS',
                              color: AppTheme.surfaceVariant,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => const CatalogScreen()),
                            ),
                            child: _buildActionCard(
                              icon: Icons.category_outlined,
                              title: 'Catálogo de\nProductos',
                              subtitle: 'ORGANIZAR',
                              color: AppTheme.secondaryLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // ── Buscador y Filtros Avanzados ──────────────────
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: TextField(
                              controller: _searchController,
                              onChanged: (value) =>
                                  provider.setSearch(value),
                              decoration: InputDecoration(
                                hintText: 'Buscar por nombre o SKU...',
                                hintStyle: TextStyle(
                                  fontSize: 14,
                                  color: AppTheme.textLight,
                                ),
                                prefixIcon: Icon(Icons.search,
                                    color: AppTheme.textLight),
                                suffixIcon: provider.searchQuery != null
                                    ? IconButton(
                                        icon: Icon(Icons.close,
                                            color: AppTheme.textLight,
                                            size: 18),
                                        onPressed: () {
                                          _searchController.clear();
                                          provider.setSearch(null);
                                        },
                                      )
                                    : null,
                                border: InputBorder.none,
                                enabledBorder: InputBorder.none,
                                focusedBorder: InputBorder.none,
                                contentPadding:
                                    const EdgeInsets.symmetric(vertical: 14),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        GestureDetector(
                          onTap: () => _showAdvancedFilters(provider),
                          child: Stack(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryDark,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(
                                  Icons.tune_rounded,
                                  color: Colors.white,
                                ),
                              ),
                              if (provider.hasAdvancedFilters)
                                Positioned(
                                  right: 6,
                                  top: 6,
                                  child: Container(
                                    width: 8,
                                    height: 8,
                                    decoration: const BoxDecoration(
                                      color: AppTheme.tertiary,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Chips de Filtro Rápido ────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(_chipLabels.length, (index) {
                          final isSelected = _selectedFilterIndex == index;
                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: GestureDetector(
                              onTap: () {
                                setState(() => _selectedFilterIndex = index);
                                provider.setEstadoFiltro(_chipEstados[index]);
                              },
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryDark
                                      : AppTheme.surfaceVariant
                                          .withValues(alpha: 0.3),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                ),
                                child: Text(
                                  _chipLabels[index],
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w500,
                                    color: isSelected
                                        ? Colors.white
                                        : AppTheme.textDark,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                    const SizedBox(height: 32),

                    // ── Header de Lista ───────────────────────────────
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          'Existencias',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.textDark,
                            fontFamily: 'Noto Serif',
                          ),
                        ),
                        provider.isLoading
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppTheme.primaryDark,
                                ),
                              )
                            : Text(
                                '${items.length} ITEMS',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.primaryDark,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // ── Estado: Cargando ──────────────────────────────
                    if (provider.isLoading)
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: 48),
                          child: CircularProgressIndicator(),
                        ),
                      )

                    // ── Estado: Sin resultados ────────────────────────
                    else if (items.isEmpty)
                      _buildEmptyState()

                    // ── Lista de Productos ────────────────────────────
                    else
                      ...items.map((item) => _buildProductItem(item)),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // WIDGETS INTERNOS
  // ═══════════════════════════════════════════════════════════════

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 48),
        child: Column(
          children: [
            Icon(Icons.inventory_2_outlined,
                size: 56, color: AppTheme.textLight),
            const SizedBox(height: 16),
            Text(
              'Sin resultados',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Intenta con otros filtros o\nagrega productos al catálogo.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: AppTheme.textMedium),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppTheme.primaryDark, size: 28),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              height: 1.2,
              fontFamily: 'Noto Serif',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textMedium,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductItem(StockItem item) {
    final statusStyle = _resolveStatusStyle(item.estadoStock);

    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ProductDetailScreen(productoId: item.id),
        ),
      ),
      child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen placeholder con color de categoría
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: _parseCategoryColor(item.categoriaColor),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.inventory_2_outlined,
                color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        item.nombre,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          fontFamily: 'Noto Serif',
                          height: 1.2,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Column(
                        children: [
                          Text('SKU:',
                              style: TextStyle(
                                  fontSize: 8, color: AppTheme.textMedium)),
                          Text(item.sku,
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: AppTheme.textDark)),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  item.categoriaNombre != null
                      ? 'Categoría: ${item.categoriaNombre}'
                      : 'Sin categoría',
                  style: TextStyle(
                      fontSize: 12, color: AppTheme.textMedium, height: 1.3),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '${item.stockTotal}',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: statusStyle.qtyColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(item.unidadMedida,
                            style: TextStyle(
                                fontSize: 12, color: statusStyle.qtyColor)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: statusStyle.bgColor,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            statusStyle.label,
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w700,
                              color: statusStyle.textColor,
                            ),
                          ),
                        ),
                        if (item.expiraProto == true) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF59E0B).withValues(alpha: 0.15),
                              borderRadius:
                                  BorderRadius.circular(AppTheme.radiusFull),
                            ),
                            child: Text(
                              item.proximaCaducidad != null
                                  ? '⚠ Vence ${_formatDate(item.proximaCaducidad!)}'
                                  : '⚠ EXPIRA PRONTO',
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFD97706),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    ),
    );
  }

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════

  _StockStatusStyle _resolveStatusStyle(String estadoStock) {
    switch (estadoStock) {
      case 'AGOTADO':
        return _StockStatusStyle(
          label: 'AGOTADO',
          bgColor: AppTheme.error.withValues(alpha: 0.12),
          textColor: AppTheme.error,
          qtyColor: AppTheme.error,
        );
      case 'STOCK_BAJO':
        return _StockStatusStyle(
          label: 'STOCK BAJO',
          bgColor: AppTheme.primaryLight.withValues(alpha: 0.3),
          textColor: AppTheme.error,
          qtyColor: AppTheme.error,
        );
      case 'EXCESO':
        return _StockStatusStyle(
          label: 'EXCESO',
          bgColor: AppTheme.secondaryLight.withValues(alpha: 0.3),
          textColor: AppTheme.primaryDark,
          qtyColor: AppTheme.primaryDark,
        );
      default: // SUFICIENTE
        return _StockStatusStyle(
          label: 'SUFICIENTE',
          bgColor: AppTheme.surfaceVariant,
          textColor: AppTheme.textDark,
          qtyColor: AppTheme.primaryDark,
        );
    }
  }

  Color _parseCategoryColor(String? hex) {
    if (hex == null || hex.isEmpty) return AppTheme.surfaceVariant;
    try {
      final cleaned = hex.replaceAll('#', '');
      return Color(int.parse('FF$cleaned', radix: 16));
    } catch (_) {
      return AppTheme.surfaceVariant;
    }
  }

  String _formatDate(String isoDate) {
    try {
      final parts = isoDate.split('-');
      if (parts.length >= 3) return '${parts[2]}/${parts[1]}';
    } catch (_) {}
    return isoDate;
  }

  // ═══════════════════════════════════════════════════════════════
  // BOTTOM SHEET DE FILTROS AVANZADOS
  // ═══════════════════════════════════════════════════════════════
  void _showAdvancedFilters(StockProvider provider) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AdvancedFiltersSheet(provider: provider),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Data class para estilos de estado
// ─────────────────────────────────────────────────────────────────────────────
class _StockStatusStyle {
  final String label;
  final Color bgColor;
  final Color textColor;
  final Color qtyColor;

  const _StockStatusStyle({
    required this.label,
    required this.bgColor,
    required this.textColor,
    required this.qtyColor,
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// BOTTOM SHEET
// ─────────────────────────────────────────────────────────────────────────────
class _AdvancedFiltersSheet extends StatefulWidget {
  final StockProvider provider;
  const _AdvancedFiltersSheet({required this.provider});

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  String? _selectedEstado;
  int? _selectedCategoriaId;
  String? _selectedSort;
  RangeValues? _precioRango;
  Set<String> _selectedUnidades = {};

  final List<String?> _estados = [null, 'AGOTADO', 'STOCK_BAJO', 'SUFICIENTE', 'EXCESO'];
  final List<String> _estadoLabels = ['Todos', 'Agotado', 'Stock Bajo', 'Suficiente', 'Exceso'];

  @override
  void initState() {
    super.initState();
    _selectedEstado = widget.provider.estadoFiltro;
    _selectedCategoriaId = widget.provider.categoriaFiltroId;
    _selectedSort = widget.provider.sortOrder;
    _selectedUnidades = Set.from(widget.provider.unidadesFiltro);
    final min = widget.provider.precioMin;
    final max = widget.provider.precioMax;
    _precioRango = widget.provider.precioRango ??
        (min < max ? RangeValues(min, max) : null);
  }

  @override
  Widget build(BuildContext context) {
    final categorias = widget.provider.categorias;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.neutral,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppTheme.divider,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Título
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Filtros Avanzados',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                  fontFamily: 'Noto Serif',
                ),
              ),
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 32),

          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Ordenar por
                  _buildSectionTitle('Ordenar por'),
                  const SizedBox(height: 16),
                  _buildSortChips(),
                  const SizedBox(height: 32),

                  // Rango de precio
                  _buildSectionTitle('Rango de precio'),
                  const SizedBox(height: 16),
                  _buildPriceRangeSlider(),
                  const SizedBox(height: 32),

                  // Unidad de medida (dinámica)
                  Builder(builder: (context) {
                    final unidades = widget.provider.unidadesDisponibles;
                    if (unidades.isEmpty) return const SizedBox.shrink();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSectionTitle('Unidad de medida'),
                        const SizedBox(height: 16),
                        Wrap(
                          spacing: 8,
                          runSpacing: 10,
                          children: unidades.map((u) {
                            final isSelected = _selectedUnidades.contains(u);
                            return GestureDetector(
                              onTap: () => setState(() {
                                _selectedUnidades = isSelected
                                    ? (Set.from(_selectedUnidades)..remove(u))
                                    : (Set.from(_selectedUnidades)..add(u));
                              }),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 16, vertical: 10),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? AppTheme.primaryDark
                                      : AppTheme.surfaceVariant
                                          .withValues(alpha: 0.5),
                                  borderRadius: BorderRadius.circular(
                                      AppTheme.radiusFull),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      u,
                                      style: TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                        color: isSelected
                                            ? Colors.white
                                            : AppTheme.textDark,
                                      ),
                                    ),
                                    if (isSelected) ...[
                                      const SizedBox(width: 8),
                                      const Icon(Icons.check,
                                          size: 14, color: Colors.white),
                                    ],
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                        const SizedBox(height: 32),
                      ],
                    );
                  }),

                  // Estado de Stock
                  _buildSectionTitle('Estado de Stock'),
                  const SizedBox(height: 16),
                  _buildGridButtons(
                    items: _estadoLabels,
                    selectedIndex: _estados.indexOf(_selectedEstado),
                    onSelect: (i) =>
                        setState(() => _selectedEstado = _estados[i]),
                  ),
                  const SizedBox(height: 32),

                  // Categoría (dinámica)
                  if (categorias.isNotEmpty) ...[
                    _buildSectionTitle('Categoría'),
                    const SizedBox(height: 16),
                    Wrap(
                      spacing: 8,
                      runSpacing: 12,
                      children: categorias
                          .map((c) => _buildCategoryChip(c))
                          .toList(),
                    ),
                    const SizedBox(height: 32),
                  ],
                ],
              ),
            ),
          ),

          // Botones de acción
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    widget.provider.clearFiltros();
                    Navigator.pop(context);
                  },
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    side: BorderSide(color: AppTheme.divider),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: Text('Limpiar',
                      style: TextStyle(color: AppTheme.textDark)),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    final globalMin = widget.provider.precioMin;
                    final globalMax = widget.provider.precioMax;
                    final isFullRange = _precioRango == null ||
                        (_precioRango!.start <= globalMin &&
                            _precioRango!.end >= globalMax);
                    widget.provider.applyFiltros(
                      estado: _selectedEstado,
                      categoriaId: _selectedCategoriaId,
                      sortOrder: _selectedSort,
                      precioRango: isFullRange ? null : _precioRango,
                      unidades: _selectedUnidades,
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryDark,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                  child: const Text('Aplicar',
                      style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
        fontFamily: 'Noto Serif',
      ),
    );
  }

  Widget _buildGridButtons({
    required List<String> items,
    required int selectedIndex,
    required Function(int) onSelect,
  }) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (context, index) {
        final isSelected = index == selectedIndex;
        return GestureDetector(
          onTap: () => onSelect(index),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.surfaceVariant.withValues(alpha: 0.5)
                  : Colors.transparent,
              border: Border.all(
                color: isSelected ? AppTheme.primaryDark : AppTheme.divider,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight:
                    isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? AppTheme.primaryDark
                    : AppTheme.textMedium,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSortChips() {
    final options = [
      ('newest', 'Más reciente'),
      ('name_asc', 'Nombre A→Z'),
      ('price_asc', 'Precio ↑'),
      ('price_desc', 'Precio ↓'),
      ('stock_asc', 'Stock ↑'),
      ('stock_desc', 'Stock ↓'),
    ];
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: options.map((opt) {
        final isSelected = _selectedSort == opt.$1;
        return GestureDetector(
          onTap: () =>
              setState(() => _selectedSort = isSelected ? null : opt.$1),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? AppTheme.primaryDark
                  : AppTheme.surfaceVariant.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  opt.$2,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color:
                        isSelected ? Colors.white : AppTheme.textDark,
                  ),
                ),
                if (isSelected) ...[
                  const SizedBox(width: 8),
                  const Icon(Icons.check, size: 14, color: Colors.white),
                ],
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildPriceRangeSlider() {
    final globalMin = widget.provider.precioMin;
    final globalMax = widget.provider.precioMax;
    final hasRange = globalMax > globalMin;

    if (!hasRange) {
      return Text(
        'Todos los productos tienen el mismo precio',
        style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
      );
    }

    final current = _precioRango ?? RangeValues(globalMin, globalMax);

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              '\$${current.start.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
            Text(
              '\$${current.end.toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        SliderTheme(
          data: SliderTheme.of(context).copyWith(
            activeTrackColor: AppTheme.primaryDark,
            inactiveTrackColor: AppTheme.surfaceVariant,
            thumbColor: AppTheme.primaryDark,
            overlayColor: AppTheme.primaryDark.withValues(alpha: 0.12),
            trackHeight: 4,
          ),
          child: RangeSlider(
            values: current,
            min: globalMin,
            max: globalMax,
            divisions: 20,
            onChanged: (values) => setState(() => _precioRango = values),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChip(StockCategoriaItem c) {
    final isSelected = _selectedCategoriaId == c.id;
    return GestureDetector(
      onTap: () => setState(() =>
          _selectedCategoriaId = isSelected ? null : c.id),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryDark
              : AppTheme.surfaceVariant.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              c.nombre,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: isSelected ? Colors.white : AppTheme.textDark,
              ),
            ),
            if (isSelected) ...[
              const SizedBox(width: 8),
              const Icon(Icons.check, size: 14, color: Colors.white),
            ],
          ],
        ),
      ),
    );
  }
}

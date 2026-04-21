import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import '../utilities/msg_util.dart';
import 'product_detail_screen.dart';
import 'edit_product_screen.dart';

class CatalogScreen extends StatefulWidget {
  const CatalogScreen({super.key});

  @override
  State<CatalogScreen> createState() => _CatalogScreenState();
}

class _CatalogScreenState extends State<CatalogScreen> {
  final TextEditingController _searchCtrl = TextEditingController();
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<ProductProvider>();
      provider.loadCategorias();
      provider.loadCatalogo(resetPage: true);
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
      context.read<ProductProvider>().setSearch(value);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          final added = await Navigator.push<bool>(
            context,
            MaterialPageRoute(builder: (_) => const EditProductScreen()),
          );
          if (added == true && context.mounted) {
            MsgtUtil.showSuccess(context, 'Producto creado correctamente');
            context.read<ProductProvider>().loadCatalogo(resetPage: true);
          }
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
      appBar: AppBar(
        backgroundColor: AppTheme.neutral,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Catálogo de Productos',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
          ),
        ),
        centerTitle: true,
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
                child: Column(
                  children: [
                    _buildSearchBar(provider),
                    const SizedBox(height: 12),
                    _buildCategoryChips(provider),
                    const SizedBox(height: 12),
                    _buildResultsHeader(provider),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
              Expanded(
                child: _buildProductList(provider),
              ),
              if (provider.totalPages > 1)
                _buildPaginationBar(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(ProductProvider provider) {
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
                hintText: 'Buscar por nombre o SKU...',
                hintStyle: TextStyle(fontSize: 14, color: AppTheme.textLight),
                prefixIcon: Icon(Icons.search, color: AppTheme.textLight),
                suffixIcon: _searchCtrl.text.isNotEmpty
                    ? IconButton(
                        icon: Icon(Icons.close, color: AppTheme.textLight, size: 18),
                        onPressed: () {
                          _searchCtrl.clear();
                          context.read<ProductProvider>().setSearch(null);
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
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppTheme.primaryDark,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: const Icon(Icons.tune_rounded, color: Colors.white),
          ),
        ),
      ],
    );
  }

  Widget _buildCategoryChips(ProductProvider provider) {
    return SizedBox(
      height: 36,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          _CategoryChip(
            label: 'Todas',
            isSelected: provider.selectedCategoriaId == null,
            onTap: () => provider.setCategoria(null),
          ),
          ...provider.categorias.map((cat) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: _CategoryChip(
                  label: cat.nombre,
                  isSelected: provider.selectedCategoriaId == cat.id,
                  onTap: () => provider.setCategoria(cat.id),
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildResultsHeader(ProductProvider provider) {
    final sortLabels = {
      'newest': 'Más Reciente',
      'price_desc': 'Precio: Mayor a Menor',
      'price_asc': 'Precio: Menor a Mayor',
    };
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          '${provider.totalItems} productos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textMedium,
          ),
        ),
        PopupMenuButton<String>(
          initialValue: provider.sort,
          onSelected: provider.setSort,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd)),
          child: Row(
            children: [
              Text(
                sortLabels[provider.sort] ?? 'Ordenar',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.primaryDark,
                ),
              ),
              Icon(Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.primaryDark, size: 18),
            ],
          ),
          itemBuilder: (_) => sortLabels.entries
              .map((e) => PopupMenuItem(
                    value: e.key,
                    child: Text(e.value,
                        style: TextStyle(
                            fontSize: 14, color: AppTheme.textDark)),
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildProductList(ProductProvider provider) {
    if (provider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryDark),
      );
    }
    if (provider.error != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 40),
            const SizedBox(height: 12),
            Text('Error al cargar productos',
                style: TextStyle(color: AppTheme.textMedium)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => provider.loadCatalogo(resetPage: true),
              child: Text('Reintentar',
                  style: TextStyle(color: AppTheme.primaryDark)),
            ),
          ],
        ),
      );
    }
    if (provider.productos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.inventory_2_outlined,
                color: AppTheme.textLight, size: 56),
            const SizedBox(height: 16),
            Text(
              'No hay productos',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.textMedium,
                fontFamily: 'Noto Serif',
              ),
            ),
          ],
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      itemCount: provider.productos.length,
      itemBuilder: (context, i) => _ProductCard(
        producto: provider.productos[i],
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
              builder: (_) =>
                  ProductDetailScreen(productoId: provider.productos[i].id)),
        ),
      ),
    );
  }

  Widget _buildPaginationBar(ProductProvider provider) {
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

  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _CatalogFiltersSheet(
        onApply: (estadoStock) {
          // mapeamos estado_stock a filtro de búsqueda
          final queryMap = {
            0: 'AGOTADO',
            1: 'STOCK_BAJO',
            2: 'SUFICIENTE',
            3: 'EXCESO',
          };
          if (estadoStock != null && queryMap.containsKey(estadoStock)) {
            _searchCtrl.text = queryMap[estadoStock]!;
            context.read<ProductProvider>().setSearch(queryMap[estadoStock]);
          }
        },
      ),
    );
  }
}

class _CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _CategoryChip({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primaryDark
              : AppTheme.surfaceVariant.withValues(alpha: 0.4),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: isSelected ? Colors.white : AppTheme.textDark,
          ),
        ),
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final CatalogoProducto producto;
  final VoidCallback onTap;

  const _ProductCard({required this.producto, required this.onTap});

  Color get _badgeColor {
    switch (producto.estadoStock) {
      case 'AGOTADO':
        return AppTheme.error;
      case 'STOCK_BAJO':
        return const Color(0xFFE67E22);
      default:
        return AppTheme.tertiary;
    }
  }

  String get _badgeLabel {
    switch (producto.estadoStock) {
      case 'AGOTADO':
        return 'AGOTADO';
      case 'STOCK_BAJO':
        return 'STOCK BAJO';
      case 'EXCESO':
        return 'EXCESO';
      default:
        return 'EN STOCK';
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusXl),
          boxShadow: AppTheme.cardShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.vertical(
                      top: Radius.circular(AppTheme.radiusXl)),
                  child: producto.imagenUrl != null
                      ? Image.network(
                          producto.imagenUrl!,
                          height: 200,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => _imagePlaceholder(),
                        )
                      : _imagePlaceholder(),
                ),
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: _badgeColor,
                      borderRadius:
                          BorderRadius.circular(AppTheme.radiusFull),
                    ),
                    child: Text(
                      _badgeLabel,
                      style: const TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          producto.nombre,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.textDark,
                            fontFamily: 'Noto Serif',
                            height: 1.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${producto.precioUnitario.toStringAsFixed(0)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SKU: ${producto.sku}',
                    style:
                        TextStyle(fontSize: 12, color: AppTheme.textMedium),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'STOCK ACTUAL',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.textLight,
                              letterSpacing: 0.8,
                            ),
                          ),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.baseline,
                            textBaseline: TextBaseline.alphabetic,
                            children: [
                              Text(
                                '${producto.stockTotal}',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  color: AppTheme.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                producto.unidadMedida,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: AppTheme.textMedium,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryDark.withValues(alpha: 0.1),
                          borderRadius:
                              BorderRadius.circular(AppTheme.radiusMd),
                        ),
                        child: Icon(
                          Icons.arrow_forward_ios_rounded,
                          color: AppTheme.primaryDark,
                          size: 16,
                        ),
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

  Widget _imagePlaceholder() {
    return Container(
      height: 200,
      width: double.infinity,
      color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
      child: Center(
        child: Icon(
          Icons.inventory_2_outlined,
          color: AppTheme.textLight,
          size: 48,
        ),
      ),
    );
  }
}

class _CatalogFiltersSheet extends StatefulWidget {
  final void Function(int? estadoStock) onApply;

  const _CatalogFiltersSheet({required this.onApply});

  @override
  State<_CatalogFiltersSheet> createState() => _CatalogFiltersSheetState();
}

class _CatalogFiltersSheetState extends State<_CatalogFiltersSheet> {
  int? _selectedStockState;

  @override
  Widget build(BuildContext context) {
    final estados = ['Agotado', 'Stock Bajo', 'Suficiente', 'Exceso'];
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: AppTheme.neutral,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
              IconButton(
                onPressed: () => Navigator.pop(context),
                icon: Icon(Icons.close, color: AppTheme.textDark),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            'Estado de Stock',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppTheme.textDark,
            ),
          ),
          const SizedBox(height: 12),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              childAspectRatio: 3.5,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: estados.length,
            itemBuilder: (context, i) {
              final isSelected = _selectedStockState == i;
              return GestureDetector(
                onTap: () =>
                    setState(() => _selectedStockState = isSelected ? null : i),
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppTheme.primaryDark
                        : AppTheme.surfaceVariant.withValues(alpha: 0.4),
                    borderRadius:
                        BorderRadius.circular(AppTheme.radiusFull),
                    border: Border.all(
                      color: isSelected
                          ? AppTheme.primaryDark
                          : AppTheme.divider,
                    ),
                  ),
                  child: Text(
                    estados[i],
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : AppTheme.textMedium,
                    ),
                  ),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                widget.onApply(_selectedStockState);
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryDark,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
              ),
              child: const Text(
                'Aplicar Filtros',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

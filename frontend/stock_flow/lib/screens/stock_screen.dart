import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';
import 'catalog_screen.dart';

class StockScreen extends StatefulWidget {
  const StockScreen({super.key});

  @override
  State<StockScreen> createState() => _StockScreenState();
}

class _StockScreenState extends State<StockScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _chipFilters = ['Todo', 'Stock Bajo', 'Agotado', 'Nuevo'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),

              // ── Top Action Cards ──────────────────────────────────────
              Row(
                children: [
                  Expanded(
                    child: _buildActionCard(
                      icon: Icons.local_shipping_outlined,
                      title: 'Gestión de\nProveedores',
                      subtitle: 'DIRECTORIOS',
                      color: AppTheme.surfaceVariant,
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

              // ── Buscador y Filtros Avanzados ──────────────────────────
              Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: TextField(
                        decoration: InputDecoration(
                          hintText: 'Buscar productos por nombre o SKU...',
                          hintStyle: TextStyle(
                            fontSize: 14,
                            color: AppTheme.textLight,
                          ),
                          prefixIcon:
                              Icon(Icons.search, color: AppTheme.textLight),
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
                    onTap: _showAdvancedFilters,
                    child: Container(
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
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // ── Chips de Filtro Rápido ───────────────────────────────
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: List.generate(_chipFilters.length, (index) {
                    final isSelected = _selectedFilterIndex == index;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedFilterIndex = index;
                          });
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
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusFull),
                          ),
                          child: Text(
                            _chipFilters[index],
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w600
                                  : FontWeight.w500,
                              color:
                                  isSelected ? Colors.white : AppTheme.textDark,
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
              ),
              const SizedBox(height: 32),

              // ── Header de Lista ──────────────────────────────────────
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
                  Text(
                    '124 ITEMS',
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

              // ── Lista de Productos ───────────────────────────────────
              _buildProductItem(
                imageColor: const Color(0xFF1C1A1A),
                imageIcon: Icons.art_track,
                title: 'The Modern Art Archive',
                sku: 'ART-001',
                category: 'Ediciones de Lujo',
                qty: '45',
                qtyColor: AppTheme.primaryDark,
                status: 'SUFICIENTE',
                statusBgColor: AppTheme.surfaceVariant,
                statusTextColor: AppTheme.textDark,
              ),

              _buildProductItem(
                imageColor: const Color(0xFFE5802C),
                imageIcon: Icons.book,
                title: 'Cuaderno de Piel Siena',
                sku: 'NOT-442',
                category: 'Papelería',
                qty: '08',
                qtyColor: AppTheme.primaryDark,
                status: 'STOCK BAJO',
                statusBgColor: AppTheme.primaryLight.withValues(alpha: 0.3),
                statusTextColor: AppTheme.error,
              ),

              _buildProductItem(
                imageColor: const Color(0xFF4DB6AC),
                imageIcon: Icons.edit,
                title: 'Set de Caligrafía Pro',
                sku: 'PEN-091',
                category: 'Papelería',
                qty: '20',
                qtyColor: AppTheme.primaryDark,
                status: 'SUFICIENTE',
                statusBgColor: AppTheme.surfaceVariant,
                statusTextColor: AppTheme.textDark,
              ),

              const SizedBox(height: 100), // Espacio para FAB
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // WIDGETS INTERNOS
  // ═══════════════════════════════════════════════════════════════════════
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

  Widget _buildProductItem({
    required Color imageColor,
    required IconData imageIcon,
    required String title,
    required String sku,
    required String category,
    required String qty,
    required Color qtyColor,
    required String status,
    required Color statusBgColor,
    required Color statusTextColor,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Imagen Placeholder
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: imageColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(imageIcon, color: Colors.white, size: 32),
          ),
          const SizedBox(width: 16),
          // Contenido
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
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
                          Text(sku,
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
                  'Categoría: $category\nExistencias',
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
                          qty,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: qtyColor,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text('unidades',
                            style: TextStyle(fontSize: 12, color: qtyColor)),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: statusBgColor,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: statusTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // BOTTOM SHEET DE FILTROS AVANZADOS (Imagen 2)
  // ═══════════════════════════════════════════════════════════════════════
  void _showAdvancedFilters() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const _AdvancedFiltersSheet(),
    );
  }
}

class _AdvancedFiltersSheet extends StatefulWidget {
  const _AdvancedFiltersSheet();

  @override
  State<_AdvancedFiltersSheet> createState() => _AdvancedFiltersSheetState();
}

class _AdvancedFiltersSheetState extends State<_AdvancedFiltersSheet> {
  int _selectedStockState = 1; // 0=Agotado, 1=Bajo, 2=Suficiente, 3=Exceso
  List<int> _selectedCategories = [1]; // 0=Mobiliario, 1=Papelería...

  @override
  Widget build(BuildContext context) {
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
          // Handle grabber
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

          // Título y Close Button
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
                  // Estado de Stock
                  _buildSectionTitle('Estado de Stock'),
                  const SizedBox(height: 16),
                  _buildGridButtons(
                    items: ['Agotado', 'Bajo', 'Suficiente', 'Exceso'],
                    selectedIndex: _selectedStockState,
                    onSelect: (index) =>
                        setState(() => _selectedStockState = index),
                  ),
                  const SizedBox(height: 32),

                  // Categoría
                  _buildSectionTitle('Categoría'),
                  const SizedBox(height: 16),
                  Wrap(
                    spacing: 8,
                    runSpacing: 12,
                    children: [
                      _buildCategoryChip('Mobiliario', 0),
                      _buildCategoryChip('Papelería', 1),
                      _buildCategoryChip('Arte', 2),
                      _buildCategoryChip('Ediciones de Lujo', 3),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Rango de Precio
                  _buildSectionTitle('Rango de Precio'),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(child: _buildPriceInput('Min')),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text('-',
                            style: TextStyle(color: AppTheme.textMedium)),
                      ),
                      Expanded(child: _buildPriceInput('Max')),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Fecha de Ingreso
                  _buildSectionTitle('Fecha de Ingreso'),
                  const SizedBox(height: 16),
                  Row(children: [
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.divider),
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Center(
                          child: Text('Desde',
                              style: TextStyle(color: AppTheme.textMedium))),
                    )),
                    const SizedBox(width: 12),
                    Expanded(
                        child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryDark,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      ),
                      child: Center(
                          child: Text('Hasta',
                              style: TextStyle(color: Colors.white))),
                    )),
                  ]),
                  const SizedBox(height: 48),
                ],
              ),
            ),
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
                width: 1,
              ),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              items[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected ? AppTheme.primaryDark : AppTheme.textMedium,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildCategoryChip(String label, int index) {
    final isSelected = _selectedCategories.contains(index);
    return GestureDetector(
      onTap: () {
        setState(() {
          if (isSelected) {
            _selectedCategories.remove(index);
          } else {
            _selectedCategories.add(index);
          }
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.w500 : FontWeight.w500,
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

  Widget _buildPriceInput(String hint) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: TextField(
        keyboardType: TextInputType.number,
        decoration: InputDecoration(
          prefixIcon: Padding(
            padding: const EdgeInsets.all(14),
            child: Text('\$',
                style: TextStyle(color: AppTheme.textMedium, fontSize: 14)),
          ),
          hintText: hint,
          hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';

class DataScreen extends StatefulWidget {
  const DataScreen({super.key});

  @override
  State<DataScreen> createState() => _DataScreenState();
}

class _DataScreenState extends State<DataScreen> {
  int _selectedFilterIndex = 0;
  final List<String> _filters = ['7 días', '30 días', '3 meses', 'Personalizado'];

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

              // ── Título Principal ─────────────────────────────────────
              Text(
                'Reportes',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.textDark,
                  fontFamily: 'Noto Serif',
                ),
              ),
              const SizedBox(height: 20),

              // ── Filtros de Tiempo ────────────────────────────────────
              _buildTimeFilters(),
              const SizedBox(height: 24),

              // ── Gráfica: Flujo de Stock ─────────────────────────────
              _buildFlujoStockCard(),
              const SizedBox(height: 24),

              // ── Tarjetas de Resumen ──────────────────────────────────
              _buildSummaryCards(),
              const SizedBox(height: 32),

              // ── Productos Top ────────────────────────────────────────
              _buildProductosTopSection(),

              const SizedBox(height: 100), // Espacio para el FAB
            ],
          ),
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // FILTROS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildTimeFilters() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(_filters.length, (index) {
          final isSelected = _selectedFilterIndex == index;
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  _selectedFilterIndex = index;
                });
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primaryDark : Colors.white,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                  boxShadow: isSelected
                      ? [
                          BoxShadow(
                            color: AppTheme.primaryDark.withValues(alpha: 0.2),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          )
                        ]
                      : [],
                ),
                child: Text(
                  _filters[index],
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected ? Colors.white : AppTheme.textMedium,
                  ),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GRÁFICA FLUJO DE STOCK
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildFlujoStockCard() {
    final entradasColor = AppTheme.primaryLight;
    final salidasColor = AppTheme.primaryDark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.04),
            blurRadius: 24,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Título y Leyenda
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Flujo de Stock',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                        fontFamily: 'Noto Serif',
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Movimientos\nsemanales',
                      style: TextStyle(
                        fontSize: 13,
                        color: AppTheme.textMedium,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Leyenda
              Row(
                children: [
                  _buildLegendItem(color: entradasColor, label: 'ENTRADAS'),
                  const SizedBox(width: 12),
                  _buildLegendItem(color: salidasColor, label: 'SALIDAS'),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),

          // Gráfica simulada (Barras dobles)
          _buildDoubleBarChart(entradasColor, salidasColor),
        ],
      ),
    );
  }

  Widget _buildLegendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildDoubleBarChart(Color entradasColor, Color salidasColor) {
    // Datos simulados (altura relativa 0.0 a 1.0)
    final List<Map<String, dynamic>> data = [
      {'day': 'L', 'in': 0.65, 'out': 0.40},
      {'day': 'M', 'in': 0.50, 'out': 0.60},
      {'day': 'M', 'in': 0.85, 'out': 0.30},
      {'day': 'J', 'in': 0.45, 'out': 0.70},
      {'day': 'V', 'in': 0.60, 'out': 0.50},
      {'day': 'S', 'in': 0.25, 'out': 0.20},
      {'day': 'D', 'in': 0.15, 'out': 0.10},
    ];

    const double maxHeight = 120;

    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: data.map((item) {
            return Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Barra Entradas
                Container(
                  width: 12,
                  height: maxHeight * (item['in'] as double),
                  decoration: BoxDecoration(
                    color: entradasColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(width: 2),
                // Barra Salidas
                Container(
                  width: 12,
                  height: maxHeight * (item['out'] as double),
                  decoration: BoxDecoration(
                    color: salidasColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
        const SizedBox(height: 16),
        // Etiquetas Eje X
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: data.map((item) {
            return SizedBox(
              width: 26,
              child: Text(
                item['day'] as String,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.textDark,
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // TARJETAS DE RESUMEN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSummaryCards() {
    return Row(
      children: [
        Expanded(
          child: _buildSummaryItem(
            label: 'TOTAL\nENTRADAS',
            value: '1,240',
            valueColor: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryItem(
            label: 'TOTAL\nSALIDAS',
            value: '892',
            valueColor: AppTheme.primaryDark,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildSummaryItem(
            label: 'VALOR\nESTIMADO',
            value: '\$14.2k',
            valueColor: AppTheme.textDark,
          ),
        ),
      ],
    );
  }

  Widget _buildSummaryItem({
    required String label,
    required String value,
    required Color valueColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 9,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              letterSpacing: 1.0,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: valueColor,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // PRODUCTOS TOP
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildProductosTopSection() {
    final List<Map<String, dynamic>> topProducts = [
      {'name': 'Sillón Editorial Velvet', 'qty': '420', 'progress': 0.90},
      {'name': 'Lámpara Estudio Minimal', 'qty': '315', 'progress': 0.75},
      {'name': 'Mesa de Roble Curada', 'qty': '280', 'progress': 0.65},
      {'name': 'Estantería Modular Pro', 'qty': '195', 'progress': 0.50},
      {'name': 'Set Cerámica Studio', 'qty': '150', 'progress': 0.35},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Encabezado
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Productos Top',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppTheme.textDark,
                fontFamily: 'Noto Serif',
              ),
            ),
            Text(
              'Ver todos',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w700,
                color: AppTheme.primaryDark,
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),

        // Lista de productos
        ...List.generate(topProducts.length, (index) {
          final product = topProducts[index];
          return _buildTopProductItem(
            rank: index + 1,
            name: product['name'] as String,
            qty: product['qty'] as String,
            progress: product['progress'] as double,
          );
        }),
      ],
    );
  }

  Widget _buildTopProductItem({
    required int rank,
    required String name,
    required String qty,
    required double progress,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Rank Badge
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppTheme.surfaceVariant.withValues(alpha: 0.6),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Info y Barra
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      name,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                      ),
                    ),
                    Text(
                      '$qty unidades',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textDark,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                // Barra de progreso estilizada
                Container(
                  height: 6,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: progress,
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(3),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

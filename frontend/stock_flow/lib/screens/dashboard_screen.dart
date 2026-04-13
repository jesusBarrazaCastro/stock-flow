import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';
import 'manual_registration_screen.dart';
import 'stock_screen.dart';
import 'data_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

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
              const SizedBox(height: 16),

              // ── Card: Inventario Total ─────────────────────────────
              _buildInventarioTotalCard(),

              const SizedBox(height: 12),

              // ── Card: Estado Crítico ───────────────────────────────
              _buildEstadoCriticoCard(),

              const SizedBox(height: 24),

              // ── Card: Smart Insights ───────────────────────────────
              _buildSmartInsightsCard(),

              const SizedBox(height: 28),

              // ── Sección: Gestión de Almacén ────────────────────────
              _buildGestionAlmacenSection(context),

              const SizedBox(height: 28),

              // ── Sección: Actividad Reciente ────────────────────────
              _buildActividadRecienteSection(),

              const SizedBox(height: 100), // espacio para el FAB
            ],
          ),
        ),
      ),
    );
  }
  // ═══════════════════════════════════════════════════════════════════════
  // INVENTARIO TOTAL
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildInventarioTotalCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // Contenido izquierdo
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'INVENTARIO TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '148',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'unidades',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                // Barra de progreso
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: 0.75,
                        minHeight: 6,
                        backgroundColor: AppTheme.surfaceVariant,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '📦 75% Capacidad',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Icono derecho
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.inventory_2_rounded,
              color: AppTheme.primary,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ESTADO CRÍTICO
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildEstadoCriticoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'ESTADO CRÍTICO',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.baseline,
                  textBaseline: TextBaseline.alphabetic,
                  children: [
                    Text(
                      '3',
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'alertas',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  '⚡ Acción requerida inmediata',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.warning,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: AppTheme.warning.withOpacity(0.12),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.warning_amber_rounded,
              color: AppTheme.warning,
              size: 28,
            ),
          ),
        ],
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // SMART INSIGHTS
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSmartInsightsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Encabezado: badge + porcentaje
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Badge Smart Insights
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.auto_awesome,
                      color: AppTheme.tertiary,
                      size: 16,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'SMART INSIGHTS',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.tertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              // Porcentaje
              Text(
                '+14%',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.tertiary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Título y subtítulo
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proyecciones: Lámpara Nórdica',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.textDark,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Basado en actividad de los últimos 30 días',
                      style: TextStyle(
                        fontSize: 12,
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'Demanda',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                  Text(
                    'estimada',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Gráfica de barras (mock)
          _buildBarChart(),

          const SizedBox(height: 12),

          // Labels de días
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM']
                .map((day) {
              final bool isHighlighted = day == 'SAB';
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: isHighlighted
                    ? BoxDecoration(
                        color: AppTheme.textDark,
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusFull),
                      )
                    : null,
                child: Text(
                  day,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight:
                        isHighlighted ? FontWeight.w700 : FontWeight.w500,
                    color: isHighlighted
                        ? Colors.white
                        : AppTheme.textLight,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// Mock de barras para Smart Insights
  Widget _buildBarChart() {
    final List<double> heights = [0.35, 0.45, 0.5, 0.7, 0.6, 0.85, 0.55];
    final List<Color> colors = [
      AppTheme.tertiary.withOpacity(0.3),
      AppTheme.tertiary.withOpacity(0.4),
      AppTheme.tertiary.withOpacity(0.45),
      AppTheme.tertiary.withOpacity(0.6),
      AppTheme.tertiary.withOpacity(0.5),
      AppTheme.tertiary, // SAB destacado
      AppTheme.tertiary.withOpacity(0.4),
    ];

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(7, (index) {
          final value = (heights[index] * 50).toInt(); // Escala simulada
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '$value',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: index == 5 ? AppTheme.tertiary : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: 70 * heights[index],
                decoration: BoxDecoration(
                  color: colors[index],
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // GESTIÓN DE ALMACÉN
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildGestionAlmacenSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GESTIÓN DE ALMACÉN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 16),
        // Grid 2x2
        Row(
          children: [
            Expanded(
              child: _buildAlmacenActionCard(
                icon: Icons.add_circle_outline_rounded,
                label: 'Registrar\nentrada',
                color: AppTheme.primary,
                isFilled: true,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ManualRegistrationScreen(initialIsEntry: true),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlmacenActionCard(
                icon: Icons.remove_circle_outline_rounded,
                label: 'Registrar salida',
                color: AppTheme.primary,
                isFilled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const ManualRegistrationScreen(initialIsEntry: false),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildAlmacenActionCard(
                icon: Icons.search_rounded,
                label: 'Consultar stock',
                color: AppTheme.textMedium,
                isFilled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const StockScreen(),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlmacenActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'Ver reportes',
                color: AppTheme.textMedium,
                isFilled: false,
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const DataScreen(),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildAlmacenActionCard({
    required IconData icon,
    required String label,
    required Color color,
    required bool isFilled,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: isFilled ? AppTheme.primary : Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          boxShadow: [
            BoxShadow(
              color: (isFilled ? AppTheme.primary : AppTheme.primary)
                  .withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isFilled
                    ? Colors.white.withOpacity(0.2)
                    : color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: isFilled ? Colors.white : color,
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isFilled ? Colors.white : AppTheme.textDark,
                height: 1.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // ACTIVIDAD RECIENTE
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildActividadRecienteSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header con "Ver todo"
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Actividad Reciente',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppTheme.textDark,
              ),
            ),
            Row(
              children: [
                Text(
                  'Ver todo',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.tertiary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_forward_rounded,
                  color: AppTheme.tertiary,
                  size: 16,
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Item: Entrada
        _buildActividadItem(
          icon: Icons.arrow_upward_rounded,
          iconColor: AppTheme.tertiary,
          iconBgColor: AppTheme.tertiary.withOpacity(0.1),
          title: 'Lámpara Nórdica Roble',
          subtitle: 'ENTRADA DE STOCK',
          amount: '+24',
          amountColor: AppTheme.tertiary,
          time: 'HACE 2H',
        ),
        const SizedBox(height: 12),

        // Item: Salida
        _buildActividadItem(
          icon: Icons.arrow_downward_rounded,
          iconColor: AppTheme.textLight,
          iconBgColor: AppTheme.surfaceVariant,
          title: 'Silla Velvet Coral',
          subtitle: 'SALIDA DE STOCK',
          amount: '-5',
          amountColor: AppTheme.error,
          time: 'HACE 4H',
        ),
      ],
    );
  }

  Widget _buildActividadItem({
    required IconData icon,
    required Color iconColor,
    required Color iconBgColor,
    required String title,
    required String subtitle,
    required String amount,
    required Color amountColor,
    required String time,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Icono
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: iconBgColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          // Texto
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                    letterSpacing: 0.8,
                  ),
                ),
              ],
            ),
          ),
          // Monto + tiempo
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                amount,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: amountColor,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                time,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.textLight,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

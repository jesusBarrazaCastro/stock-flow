import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/dashboard_provider.dart';
import '../services/dashboard_service.dart';
import '../utilities/msg_util.dart';
import 'manual_registration_screen.dart';

class DashboardScreen extends StatefulWidget {
  final void Function(int index)? onNavigateToTab;

  const DashboardScreen({super.key, this.onNavigateToTab});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = context.read<DashboardProvider>();
      provider.loadAll().then((_) {
        if (mounted && provider.error != null) {
          MsgtUtil.showError(context, provider.error!);
        }
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Consumer<DashboardProvider>(
        builder: (context, dash, _) {
          return SafeArea(
            child: RefreshIndicator(
              onRefresh: () => dash.refresh(),
              color: AppTheme.primary,
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 16),

                    // ── Card: Inventario Total ─────────────────────────────
                    _buildInventarioTotalCard(dash),

                    const SizedBox(height: 12),

                    // ── Card: Estado Crítico ───────────────────────────────
                    _buildEstadoCriticoCard(dash),

                    const SizedBox(height: 24),

                    // ── Card: Smart Insights ───────────────────────────────
                    _buildSmartInsightsCard(dash),

                    const SizedBox(height: 28),

                    // ── Sección: Gestión de Almacén ────────────────────────
                    _buildGestionAlmacenSection(context),

                    const SizedBox(height: 28),

                    // ── Sección: Actividad Reciente ────────────────────────
                    _buildActividadRecienteSection(dash),

                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  // ═══════════════════════════════════════════════════════════════════════
  // INVENTARIO TOTAL
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildInventarioTotalCard(DashboardProvider dash) {
    final kpis = dash.kpis;
    final unidades = kpis?.inventarioTotalUnidades ?? 0;
    final productos = kpis?.totalProductos ?? 0;
    final almacenes = kpis?.totalAlmacenes ?? 0;

    double capacidadRatio = 0.0;
    String capacidadLabel = '';
    if (kpis != null && kpis.capacidadTotal > 0) {
      capacidadRatio =
          (unidades / kpis.capacidadTotal).clamp(0.0, 1.0);
      final pct = (capacidadRatio * 100).round();
      capacidadLabel = '📦 $pct% Capacidad';
    }

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
                  'INVENTARIO TOTAL',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textLight,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 8),

                dash.isLoading
                    ? _buildSkeletonBox(width: 120, height: 44)
                    : Row(
                        crossAxisAlignment: CrossAxisAlignment.baseline,
                        textBaseline: TextBaseline.alphabetic,
                        children: [
                          Text(
                            '$unidades',
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

                if (!dash.isLoading && kpis != null &&
                    kpis.capacidadTotal > 0) ...[
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: capacidadRatio,
                      minHeight: 6,
                      backgroundColor: AppTheme.surfaceVariant,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.primary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    capacidadLabel,
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                if (!dash.isLoading && kpis != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    '$productos productos · $almacenes almacenes',
                    style: TextStyle(
                      fontSize: 12,
                      color: AppTheme.textLight,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 16),
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
  Widget _buildEstadoCriticoCard(DashboardProvider dash) {
    final kpis = dash.kpis;
    final alertasStock = kpis?.alertasStock ?? 0;
    final proximosCaducar = kpis?.proximosCaducar ?? 0;
    final totalAlertas = alertasStock + proximosCaducar;

    String sublineText;
    if (dash.isLoading || kpis == null) {
      sublineText = '⚡ Cargando...';
    } else if (totalAlertas == 0) {
      sublineText = '✓ Sin alertas activas';
    } else {
      final parts = <String>[];
      if (alertasStock > 0) parts.add('$alertasStock stock crítico');
      if (proximosCaducar > 0) parts.add('$proximosCaducar próximos a vencer');
      sublineText = '⚡ ${parts.join(' · ')}';
    }

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
                    dash.isLoading
                        ? const SizedBox(
                            width: 28,
                            height: 28,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(
                            '$totalAlertas',
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
                  sublineText,
                  style: TextStyle(
                    fontSize: 12,
                    color: totalAlertas > 0
                        ? AppTheme.warning
                        : AppTheme.tertiary,
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
  Widget _buildSmartInsightsCard(DashboardProvider dash) {
    final insights = dash.insights;
    final sinDatos = insights == null || insights.sinDatos;

    if (dash.isLoading || sinDatos) {
      return _buildInsightsPlaceholder(isLoading: dash.isLoading);
    }

    final pct = insights.pctCambio ?? 0.0;
    final pctStr =
        pct >= 0 ? '+${pct.toStringAsFixed(1)}%' : '${pct.toStringAsFixed(1)}%';
    final pctColor = pct >= 0 ? AppTheme.tertiary : AppTheme.error;

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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
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
              Text(
                pctStr,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w800,
                  color: pctColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Proyecciones: ${insights.productoNombre ?? ''}',
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

          _buildBarChartReal(insights.dias),

          const SizedBox(height: 12),

          _buildDayLabels(insights.dias),
        ],
      ),
    );
  }

  Widget _buildInsightsPlaceholder({required bool isLoading}) {
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
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.tertiary.withOpacity(0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome, color: AppTheme.tertiary, size: 16),
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
          const SizedBox(height: 20),
          if (isLoading) ...[
            _buildSkeletonBox(width: double.infinity, height: 24),
            const SizedBox(height: 12),
            _buildSkeletonBox(width: double.infinity, height: 80),
          ] else ...[
            Center(
              child: Column(
                children: [
                  Icon(
                    Icons.bar_chart_rounded,
                    size: 48,
                    color: AppTheme.textLight.withOpacity(0.4),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Sin actividad reciente',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textMedium,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Registra movimientos para ver proyecciones',
                    style: TextStyle(
                      fontSize: 13,
                      color: AppTheme.textLight,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildBarChartReal(List<InsightsDia> dias) {
    if (dias.isEmpty) return const SizedBox(height: 100);

    final maxTotal =
        dias.map((d) => d.total).reduce((a, b) => a > b ? a : b);
    final maxVal = maxTotal > 0 ? maxTotal.toDouble() : 1.0;

    int maxIndex = 0;
    for (int i = 0; i < dias.length; i++) {
      if (dias[i].total > dias[maxIndex].total) maxIndex = i;
    }

    return SizedBox(
      height: 100,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: List.generate(dias.length, (index) {
          final dia = dias[index];
          final ratio = dia.total / maxVal;
          final isHighlighted = index == maxIndex && dia.total > 0;
          final barColor = isHighlighted
              ? AppTheme.tertiary
              : AppTheme.tertiary.withOpacity(0.35 + ratio * 0.3);

          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                '${dia.total}',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  color: isHighlighted
                      ? AppTheme.tertiary
                      : AppTheme.textLight,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                width: 24,
                height: ratio > 0 ? (70 * ratio).clamp(6.0, 70.0) : 6.0,
                decoration: BoxDecoration(
                  color: barColor,
                  borderRadius: BorderRadius.circular(6),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildDayLabels(List<InsightsDia> dias) {
    const dayNames = ['LUN', 'MAR', 'MIE', 'JUE', 'VIE', 'SAB', 'DOM'];

    int maxIndex = 0;
    if (dias.isNotEmpty) {
      for (int i = 0; i < dias.length; i++) {
        if (dias[i].total > dias[maxIndex].total) maxIndex = i;
      }
    }

    final labels = dias.map((d) {
      final dt = DateTime.tryParse(d.fecha);
      if (dt == null) return '---';
      return dayNames[(dt.weekday - 1) % 7];
    }).toList();

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: List.generate(labels.length, (index) {
        final isHighlighted =
            index == maxIndex && dias[index].total > 0;
        return Container(
          padding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: isHighlighted
              ? BoxDecoration(
                  color: AppTheme.textDark,
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                )
              : null,
          child: Text(
            labels[index],
            style: TextStyle(
              fontSize: 10,
              fontWeight:
                  isHighlighted ? FontWeight.w700 : FontWeight.w500,
              color: isHighlighted ? Colors.white : AppTheme.textLight,
              letterSpacing: 0.5,
            ),
          ),
        );
      }),
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
                onTap: () => widget.onNavigateToTab?.call(1),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildAlmacenActionCard(
                icon: Icons.bar_chart_rounded,
                label: 'Ver reportes',
                color: AppTheme.textMedium,
                isFilled: false,
                onTap: () => widget.onNavigateToTab?.call(2),
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
  Widget _buildActividadRecienteSection(DashboardProvider dash) {
    final items = dash.actividad;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
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

        if (dash.isLoading) ...[
          _buildSkeletonBox(width: double.infinity, height: 72),
          const SizedBox(height: 12),
          _buildSkeletonBox(width: double.infinity, height: 72),
        ] else if (items.isEmpty)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Column(
              children: [
                Icon(
                  Icons.inbox_rounded,
                  size: 40,
                  color: AppTheme.textLight.withOpacity(0.5),
                ),
                const SizedBox(height: 8),
                Text(
                  'Sin actividad reciente',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppTheme.textMedium,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          )
        else
          ...items.asMap().entries.map((entry) {
            final i = entry.key;
            final item = entry.value;
            final isEntrada = item.tipoMovimiento == 'ENTRADA';

            return Column(
              children: [
                if (i > 0) const SizedBox(height: 12),
                _buildActividadItem(
                  icon: isEntrada
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  iconColor:
                      isEntrada ? AppTheme.tertiary : AppTheme.textLight,
                  iconBgColor: isEntrada
                      ? AppTheme.tertiary.withOpacity(0.1)
                      : AppTheme.surfaceVariant,
                  title: item.productoNombre ?? 'Producto',
                  subtitle:
                      isEntrada ? 'ENTRADA DE STOCK' : 'SALIDA DE STOCK',
                  amount: isEntrada
                      ? '+${item.cantidad}'
                      : '-${item.cantidad}',
                  amountColor:
                      isEntrada ? AppTheme.tertiary : AppTheme.error,
                  time: item.timeAgo,
                ),
              ],
            );
          }),
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

  // ═══════════════════════════════════════════════════════════════════════
  // HELPER
  // ═══════════════════════════════════════════════════════════════════════
  Widget _buildSkeletonBox({required double width, required double height}) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
    );
  }
}

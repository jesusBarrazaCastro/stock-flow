import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/supplier_provider.dart';
import '../services/supplier_service.dart';
import '../utilities/msg_util.dart';
import 'edit_supplier_screen.dart';

class SupplierDetailScreen extends StatefulWidget {
  final int proveedorId;

  const SupplierDetailScreen({super.key, required this.proveedorId});

  @override
  State<SupplierDetailScreen> createState() => _SupplierDetailScreenState();
}

class _SupplierDetailScreenState extends State<SupplierDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SupplierProvider>().loadDetalle(widget.proveedorId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      body: Consumer<SupplierProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Scaffold(
              backgroundColor: AppTheme.neutral,
              body: Center(
                child: CircularProgressIndicator(color: AppTheme.primaryDark),
              ),
            );
          }
          final p = provider.selectedProveedor;
          if (p == null) {
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
              ),
              body: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                    const SizedBox(height: 12),
                    Text('Proveedor no encontrado',
                        style: TextStyle(color: AppTheme.textMedium)),
                  ],
                ),
              ),
            );
          }

          return Scaffold(
            backgroundColor: AppTheme.neutral,
            body: CustomScrollView(
              slivers: [
                _buildSliverAppBar(context, p, provider),
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 40),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Card info principal
                        _buildInfoCard(p),
                        const SizedBox(height: 20),

                        // Productos Suministrados
                        if (p.productosSuministrados.isNotEmpty) ...[
                          _buildSectionTitle('Productos Suministrados'),
                          const SizedBox(height: 12),
                          _buildProductosGrid(p.productosSuministrados),
                          const SizedBox(height: 24),
                        ],

                        // KPIs
                        _buildKpisSection(p),
                        const SizedBox(height: 24),

                        // Historial de Pedidos
                        _buildHistorialHeader(context, p),
                        const SizedBox(height: 12),
                        _buildHistorialList(p.historialPedidos),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(BuildContext context, ProveedorDetalle p,
      SupplierProvider provider) {
    return SliverAppBar(
      backgroundColor: AppTheme.neutral,
      elevation: 0,
      pinned: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back_ios_new_rounded,
            color: AppTheme.textDark, size: 20),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.edit_outlined, color: AppTheme.primary),
          onPressed: () async {
            final updated = await Navigator.push<bool>(
              context,
              MaterialPageRoute(
                builder: (_) =>
                    EditSupplierScreen(proveedorId: p.id),
              ),
            );
            if (updated == true && context.mounted) {
              MsgtUtil.showSuccess(context, 'Proveedor actualizado correctamente');
              context
                  .read<SupplierProvider>()
                  .loadDetalle(widget.proveedorId);
            }
          },
        ),
      ],
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Breadcrumb
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Proveedores',
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textLight,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Icon(Icons.chevron_right, size: 14, color: AppTheme.textLight),
              Text(
                p.nombre,
                style: TextStyle(
                  fontSize: 12,
                  color: AppTheme.textMedium,
                  fontWeight: FontWeight.w600,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
          Text(
            'Detalle de Proveedor',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppTheme.textDark,
              fontFamily: 'Noto Serif',
            ),
          ),
        ],
      ),
      centerTitle: true,
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Row(
            children: [
              Expanded(
                child: _ActionButton(
                  icon: Icons.mail_outline_rounded,
                  label: 'Email',
                  onTap: () {},
                  isOutlined: true,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _ActionButton(
                  icon: Icons.phone_rounded,
                  label: 'Llamar',
                  onTap: () {},
                  isOutlined: false,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(ProveedorDetalle p) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          // Logo + nombre
          Row(
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: p.logoUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd - 1),
                        child: Image.network(p.logoUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => _logoPlaceholder()),
                      )
                    : _logoPlaceholder(),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      p.nombre,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.textDark,
                        fontFamily: 'Noto Serif',
                        height: 1.2,
                      ),
                    ),
                    if (p.calificacion != null && p.calificacion! > 0) ...[
                      const SizedBox(height: 4),
                      _buildRatingStars(p.calificacion!),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),

          // Detalles
          if (p.direccion != null)
            _DetailInfoRow(
              icon: Icons.location_on_outlined,
              text: p.direccion!,
            ),
          if (p.certificadoDesde != null)
            _DetailInfoRow(
              icon: Icons.verified_outlined,
              text: 'Proveedor Certificado desde ${p.certificadoDesde}',
            ),
          if (p.categoria != null)
            _DetailInfoRow(
              icon: Icons.category_outlined,
              text: p.categoria!,
              isLast: true,
            ),
        ],
      ),
    );
  }

  Widget _buildRatingStars(double rating) {
    const maxStars = 5;
    return Row(
      children: [
        ...List.generate(maxStars, (i) {
          if (i < rating.floor()) {
            return Icon(Icons.star_rounded, color: AppTheme.warning, size: 16);
          } else if (i < rating) {
            return Icon(Icons.star_half_rounded,
                color: AppTheme.warning, size: 16);
          }
          return Icon(Icons.star_border_rounded,
              color: AppTheme.textLight, size: 16);
        }),
        const SizedBox(width: 6),
        Text(
          '(${rating.toStringAsFixed(1)} / 5.0)',
          style: TextStyle(fontSize: 11, color: AppTheme.textMedium),
        ),
      ],
    );
  }

  Widget _buildProductosGrid(List<ProductoSuministrado> productos) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.85,
      ),
      itemCount: productos.length,
      itemBuilder: (context, i) {
        final prod = productos[i];
        return Column(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppTheme.surfaceVariant.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: prod.imagenUrl != null
                    ? ClipRRect(
                        borderRadius:
                            BorderRadius.circular(AppTheme.radiusMd - 1),
                        child: Image.network(prod.imagenUrl!, fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Icon(
                                Icons.inventory_2_outlined,
                                color: AppTheme.textLight,
                                size: 24)),
                      )
                    : Center(
                        child: Icon(Icons.inventory_2_outlined,
                            color: AppTheme.textLight, size: 24),
                      ),
              ),
            ),
            const SizedBox(height: 4),
            Text(
              prod.sku,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppTheme.textMedium,
                letterSpacing: 0.5,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildKpisSection(ProveedorDetalle p) {
    return Column(
      children: [
        _KpiRow(
          label: 'PEDIDOS TOTALES',
          value: '${p.pedidosTotal}',
          suffix: '+12%',
          suffixColor: AppTheme.tertiary,
        ),
        const SizedBox(height: 16),
        _KpiRow(
          label: 'CUMPLIMIENTO',
          value: '${p.cumplimiento.toStringAsFixed(0)}%',
          suffix: 'Óptimo',
          suffixColor: AppTheme.tertiary,
        ),
        const SizedBox(height: 16),
        _KpiRow(
          label: 'TIEMPO ENTREGA',
          value: p.tiempoEntrega.toStringAsFixed(1),
          suffix: 'días avg',
          suffixColor: AppTheme.textMedium,
        ),
      ],
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w700,
        color: AppTheme.textDark,
        fontFamily: 'Noto Serif',
      ),
    );
  }

  Widget _buildHistorialHeader(BuildContext context, ProveedorDetalle p) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildSectionTitle('Historial de Pedidos'),
        if (p.historialPedidos.isNotEmpty)
          TextButton.icon(
            onPressed: () {},
            icon: Text('Ver todo',
                style: TextStyle(
                    fontSize: 12,
                    color: AppTheme.primary,
                    fontWeight: FontWeight.w600)),
            label: Icon(Icons.arrow_forward_rounded,
                size: 14, color: AppTheme.primary),
          ),
      ],
    );
  }

  Widget _buildHistorialList(List<PedidoHistorial> historial) {
    if (historial.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        ),
        child: Center(
          child: Text(
            'Sin historial de pedidos',
            style: TextStyle(color: AppTheme.textLight, fontSize: 14),
          ),
        ),
      );
    }
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: historial.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (_, i) => _PedidoTile(pedido: historial[i]),
    );
  }

  Widget _logoPlaceholder() {
    return const Center(
      child: Icon(Icons.storefront_outlined,
          color: AppTheme.textLight, size: 28),
    );
  }
}

// ─── Action Button ────────────────────────────────────────────────────────────
class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isOutlined;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.isOutlined,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: isOutlined ? Colors.transparent : AppTheme.primaryDark,
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isOutlined ? AppTheme.divider : AppTheme.primaryDark,
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon,
                size: 16,
                color: isOutlined ? AppTheme.textDark : Colors.white),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isOutlined ? AppTheme.textDark : Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Detail Info Row ──────────────────────────────────────────────────────────
class _DetailInfoRow extends StatelessWidget {
  final IconData icon;
  final String text;
  final bool isLast;

  const _DetailInfoRow(
      {required this.icon, required this.text, this.isLast = false});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: AppTheme.textLight),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                text,
                style: TextStyle(fontSize: 13, color: AppTheme.textMedium),
              ),
            ),
          ],
        ),
        if (!isLast) ...[
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

// ─── KPI Row ─────────────────────────────────────────────────────────────────
class _KpiRow extends StatelessWidget {
  final String label;
  final String value;
  final String suffix;
  final Color suffixColor;

  const _KpiRow({
    required this.label,
    required this.value,
    required this.suffix,
    required this.suffixColor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppTheme.textLight,
            letterSpacing: 1.0,
          ),
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w800,
                color: AppTheme.textDark,
                fontFamily: 'Noto Serif',
                height: 1.0,
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: suffixColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              ),
              child: Text(
                suffix,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: suffixColor,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Divider(color: AppTheme.divider, height: 1),
      ],
    );
  }
}

// ─── Pedido Tile ──────────────────────────────────────────────────────────────
class _PedidoTile extends StatelessWidget {
  final PedidoHistorial pedido;

  const _PedidoTile({required this.pedido});

  Color get _estadoColor {
    switch (pedido.estadoPedido) {
      case 'EN_TRANSITO':
        return AppTheme.warning;
      case 'COMPLETADO':
        return AppTheme.tertiary;
      default:
        return AppTheme.textMedium;
    }
  }

  String get _estadoLabel {
    switch (pedido.estadoPedido) {
      case 'EN_TRANSITO':
        return 'EN TRÁNSITO';
      case 'COMPLETADO':
        return 'COMPLETADO';
      default:
        return pedido.estadoPedido;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Row(
        children: [
          // Ícono
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(Icons.shopping_bag_outlined,
                color: AppTheme.primaryDark, size: 20),
          ),
          const SizedBox(width: 12),

          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pedido.numeroPedido,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.textDark,
                  ),
                ),
                if (pedido.fecha != null)
                  Text(
                    pedido.fecha!,
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textLight),
                  ),
              ],
            ),
          ),

          // Monto + estado
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '\$${pedido.montoTotal.toStringAsFixed(2)}',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 7, vertical: 3),
                decoration: BoxDecoration(
                  color: _estadoColor.withValues(alpha: 0.12),
                  borderRadius:
                      BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: Text(
                  _estadoLabel,
                  style: TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    color: _estadoColor,
                    letterSpacing: 0.3,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

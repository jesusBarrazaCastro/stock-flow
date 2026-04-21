import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stock_flow/app_theme.dart';
import '../providers/product_provider.dart';
import '../services/product_service.dart';
import 'edit_product_screen.dart';

class ProductDetailScreen extends StatefulWidget {
  final int productoId;

  const ProductDetailScreen({super.key, required this.productoId});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ProductProvider>().loadDetalle(widget.productoId);
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
          'Detalles del Producto',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
          ),
        ),
        centerTitle: true,
        actions: [
          Consumer<ProductProvider>(
            builder: (_, provider, __) {
              final producto = provider.selectedProducto;
              return IconButton(
                icon: Icon(Icons.edit_outlined, color: AppTheme.primary),
                onPressed: producto == null
                    ? null
                    : () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                EditProductScreen(producto: producto),
                          ),
                        ),
              );
            },
          ),
        ],
      ),
      body: Consumer<ProductProvider>(
        builder: (context, provider, _) {
          if (provider.isLoadingDetail) {
            return const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryDark),
            );
          }
          final p = provider.selectedProducto;
          if (p == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, color: AppTheme.error, size: 40),
                  const SizedBox(height: 12),
                  Text('Producto no encontrado',
                      style: TextStyle(color: AppTheme.textMedium)),
                ],
              ),
            );
          }
          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _HeroImage(imagenUrl: p.imagenUrl, estadoStock: p.estadoStock),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        p.nombre,
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          fontFamily: 'Noto Serif',
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (p.categoriaNombre != null)
                        _CategoriaLabel(
                          nombre: p.categoriaNombre!,
                          colorHex: p.categoriaColor,
                        ),
                      const SizedBox(height: 6),
                      Text(
                        'SKU: ${p.sku}',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppTheme.textMedium,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        children: [
                          Expanded(
                            child: _InfoCard(
                              label: 'STOCK ACTUAL',
                              value: '${p.stockTotal}',
                              suffix: p.unidadMedida,
                              icon: Icons.inventory_2_outlined,
                              valueColor: AppTheme.primaryDark,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: _InfoCard(
                              label: 'PRECIO UNITARIO',
                              value:
                                  '\$${p.precioUnitario.toStringAsFixed(2)}',
                              icon: Icons.attach_money_rounded,
                              valueColor: AppTheme.textDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _DetailsCard(producto: p),
                      const SizedBox(height: 28),
                      Text(
                        'Movimientos Recientes',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textDark,
                          fontFamily: 'Noto Serif',
                        ),
                      ),
                      const SizedBox(height: 12),
                      if (p.movimientosRecientes.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius:
                                BorderRadius.circular(AppTheme.radiusLg),
                          ),
                          child: Center(
                            child: Text(
                              'Sin movimientos registrados',
                              style: TextStyle(
                                  color: AppTheme.textLight, fontSize: 14),
                            ),
                          ),
                        )
                      else
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: p.movimientosRecientes.length,
                          separatorBuilder: (_, __) =>
                              const SizedBox(height: 8),
                          itemBuilder: (_, i) =>
                              _MovimientoTile(movimiento: p.movimientosRecientes[i]),
                        ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _HeroImage extends StatelessWidget {
  final String? imagenUrl;
  final String estadoStock;

  const _HeroImage({this.imagenUrl, required this.estadoStock});

  Color get _badgeColor {
    switch (estadoStock) {
      case 'AGOTADO':
        return AppTheme.error;
      case 'STOCK_BAJO':
        return const Color(0xFFE67E22);
      default:
        return AppTheme.tertiary;
    }
  }

  String get _badgeLabel {
    switch (estadoStock) {
      case 'AGOTADO':
        return 'AGOTADO';
      case 'STOCK_BAJO':
        return 'STOCK BAJO';
      case 'EXCESO':
        return 'EXCESO';
      default:
        return 'STOCK ÓPTIMO';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SizedBox(
          height: 280,
          width: double.infinity,
          child: imagenUrl != null
              ? Image.network(
                  imagenUrl!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => _placeholder(),
                )
              : _placeholder(),
        ),
        Positioned(
          top: 16,
          right: 16,
          child: Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: _badgeColor,
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              _badgeLabel,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _placeholder() {
    return Container(
      color: AppTheme.surfaceVariant.withValues(alpha: 0.4),
      child: Center(
        child: Icon(Icons.inventory_2_outlined,
            color: AppTheme.textLight, size: 64),
      ),
    );
  }
}

class _CategoriaLabel extends StatelessWidget {
  final String nombre;
  final String? colorHex;

  const _CategoriaLabel({required this.nombre, this.colorHex});

  Color _parseColor() {
    if (colorHex == null) return AppTheme.primaryDark;
    try {
      final hex = colorHex!.replaceAll('#', '');
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return AppTheme.primaryDark;
    }
  }

  @override
  Widget build(BuildContext context) {
    final color = _parseColor();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Text(
        nombre.toUpperCase(),
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: color,
          letterSpacing: 1.0,
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final String label;
  final String value;
  final String? suffix;
  final IconData icon;
  final Color valueColor;

  const _InfoCard({
    required this.label,
    required this.value,
    this.suffix,
    required this.icon,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
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
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: AppTheme.textLight,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w800,
              color: valueColor,
              fontFamily: 'Noto Serif',
            ),
          ),
          if (suffix != null)
            Text(
              suffix!,
              style: TextStyle(fontSize: 12, color: AppTheme.textMedium),
            ),
        ],
      ),
    );
  }
}

class _DetailsCard extends StatelessWidget {
  final ProductoDetalle producto;

  const _DetailsCard({required this.producto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        children: [
          if (producto.proveedorNombre != null)
            _DetailRow(
              label: 'PROVEEDOR',
              value: producto.proveedorNombre!,
              icon: Icons.storefront_outlined,
            ),
          if (producto.ubicacionFisica != null || producto.almacenNombre != null)
            _DetailRow(
              label: 'UBICACIÓN',
              value: [
                if (producto.almacenNombre != null) producto.almacenNombre!,
                if (producto.ubicacionFisica != null) producto.ubicacionFisica!,
              ].join(' / '),
              icon: Icons.location_on_outlined,
            ),
          _DetailRow(
            label: 'FECHA DE REGISTRO',
            value: producto.registroFecha ?? '—',
            icon: Icons.calendar_today_outlined,
          ),
          _DetailRow(
            label: 'UNIDAD DE MEDIDA',
            value: producto.unidadMedida,
            icon: Icons.straighten_outlined,
            isLast: true,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isLast;

  const _DetailRow({
    required this.label,
    required this.value,
    required this.icon,
    this.isLast = false,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 16, color: AppTheme.textLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textLight,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.textDark,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        if (!isLast)
          Divider(
            color: AppTheme.divider,
            height: 24,
          ),
      ],
    );
  }
}

class _MovimientoTile extends StatelessWidget {
  final MovimientoReciente movimiento;

  const _MovimientoTile({required this.movimiento});

  bool get _isEntrada => movimiento.tipoMovimiento == 'ENTRADA';

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
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: (_isEntrada ? AppTheme.tertiary : AppTheme.error)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            ),
            child: Icon(
              _isEntrada
                  ? Icons.arrow_downward_rounded
                  : Icons.arrow_upward_rounded,
              color: _isEntrada ? AppTheme.tertiary : AppTheme.error,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_isEntrada ? "Entrada" : "Salida"} de Stock',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textDark,
                  ),
                ),
                if (movimiento.notas != null)
                  Text(
                    movimiento.notas!,
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textMedium),
                  ),
                if (movimiento.fechaMovimiento != null)
                  Text(
                    movimiento.fechaMovimiento!,
                    style:
                        TextStyle(fontSize: 11, color: AppTheme.textLight),
                  ),
              ],
            ),
          ),
          Text(
            '${_isEntrada ? "+" : "-"}${movimiento.cantidad}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: _isEntrada ? AppTheme.tertiary : AppTheme.error,
            ),
          ),
        ],
      ),
    );
  }
}

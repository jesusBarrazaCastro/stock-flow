import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';

class CompanyDetailsScreen extends StatelessWidget {
  const CompanyDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
            flexibleSpace: FlexibleSpaceBar(
              title: const Text(
                'Perfil de Empresa',
                style: TextStyle(
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
                    child: Icon(
                      Icons.domain,
                      size: 200,
                      color: Colors.white.withOpacity(0.1),
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingLg),
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
                          image: NetworkImage(
                              'https://ui-avatars.com/api/?name=TL&background=34B19B&color=fff&size=200'), // Mock logo
                          fit: BoxFit.cover,
                        ),
                        border: Border.all(color: AppTheme.neutral, width: 4),
                      ),
                    ),
                  ),
                  
                  _buildSectionTitle('Información General'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.business, 'Razón Social', 'Tech Logistics S.A. de C.V.'),
                    _buildDivider(),
                    _buildInfoRow(Icons.badge_outlined, 'RFC / Tax ID', 'TLG-840921-XX1'),
                    _buildDivider(),
                    _buildInfoRow(Icons.calendar_today_outlined, 'Fecha de Registro', '15 Mar 2018'),
                  ]),
                  
                  const SizedBox(height: AppTheme.spacingXl),
                  
                  _buildSectionTitle('Contacto y Ubicación'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.email_outlined, 'Correo Electrónico', 'contacto@techlogistics.com'),
                    _buildDivider(),
                    _buildInfoRow(Icons.phone_outlined, 'Teléfono Principal', '+52 55 1234 5678'),
                    _buildDivider(),
                    _buildInfoRow(
                      Icons.location_on_outlined, 
                      'Dirección Fiscal', 
                      'Av. Insurgentes Sur 1000, Col. del Valle, Benito Juárez, 03100, CDMX, México',
                      isMultiline: true,
                    ),
                  ]),
                  
                  const SizedBox(height: AppTheme.spacingXl),
                  
                  _buildSectionTitle('Suscripción y Límites'),
                  _buildInfoCard([
                    _buildInfoRow(Icons.star_outline, 'Plan Actual', 'PRO (Facturación anual)'),
                    _buildDivider(),
                    _buildInfoRow(Icons.inventory_2_outlined, 'Límite de Almacenes', 'Ilimitado (3 activos)'),
                  ]),

                  const SizedBox(height: AppTheme.spacingXl * 2), // Padding inferior
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd, left: 4),
      child: Text(
        title,
        style: const TextStyle(
          color: AppTheme.textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildInfoCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: children,
      ),
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
                Text(
                  label,
                  style: const TextStyle(
                    color: AppTheme.textLight,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.textDark,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  softWrap: isMultiline,
                  maxLines: isMultiline ? null : 1,
                  overflow: isMultiline ? null : TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider() {
    return const Divider(
      height: 1,
      thickness: 1,
      color: AppTheme.divider,
      indent: AppTheme.spacingMd * 2 + 22,
    );
  }
}

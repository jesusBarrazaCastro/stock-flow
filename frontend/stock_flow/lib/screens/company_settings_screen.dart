import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';
import 'dart:ui';
import 'users_management_screen.dart';
import 'company_details_screen.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});

  @override
  State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
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
                'Panel de Empresa',
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
                      Icons.business,
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
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatCards(),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildSectionLabel('Ajustes Generales'),
                  _buildActionCard(
                    icon: Icons.info_outline,
                    title: 'Información de la Empresa',
                    subtitle: 'Razón social, RFC, Dirección',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanyDetailsScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.storefront_outlined,
                    title: 'Sucursales y Almacenes',
                    subtitle: 'Gestionar las 3 sucursales activas',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildSectionLabel('Gestión y Accesos'),
                  _buildActionCard(
                    icon: Icons.people_outline,
                    title: 'Usuarios y Roles',
                    subtitle: '12 usuarios • 2 administradores',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const UsersManagementScreen(),
                        ),
                      );
                    },
                  ),
                  _buildActionCard(
                    icon: Icons.api_rounded,
                    title: 'Integraciones y API',
                    subtitle: 'Webhooks y conexiones externas',
                  ),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildSectionLabel('Suscripción'),
                  _buildSubscriptionCard(),
                  const SizedBox(height: 50),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCards() {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            title: 'Usuarios',
            value: '12',
            icon: Icons.group,
            color: AppTheme.tertiary,
          ),
        ),
        const SizedBox(width: AppTheme.spacingMd),
        Expanded(
          child: _StatCard(
            title: 'Almacenes',
            value: '3',
            icon: Icons.warehouse,
            color: AppTheme.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildSectionLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingMd, left: 4),
      child: Text(
        text,
        style: const TextStyle(
          color: AppTheme.textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.02),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppTheme.neutral,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Icon(icon, color: AppTheme.textDark, size: 24),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          color: AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: const TextStyle(
                          color: AppTheme.textLight,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(
                  Icons.chevron_right,
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSubscriptionCard() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.tertiary,
            AppTheme.tertiaryDark,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: const Text(
                  'PLAN PRO',
                  style: TextStyle(
                    color: AppTheme.textOnPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                    letterSpacing: 1,
                  ),
                ),
              ),
              const Icon(Icons.star, color: Colors.amber, size: 24),
            ],
          ),
          const SizedBox(height: AppTheme.spacingMd),
          const Text(
            'Tu empresa tiene acceso a todas las funcionalidades avanzadas e ilimitadas.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          OutlinedButton(
            onPressed: () {},
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: const BorderSide(color: Colors.white, width: 1.5),
            ),
            child: const Text('Ver Detalles de Facturación'),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(color: AppTheme.divider, width: 1),
        boxShadow: AppTheme.cardShadow,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 28),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            value,
            style: TextStyle(
              color: AppTheme.textDark,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            title,
            style: TextStyle(
              color: AppTheme.textLight,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:stock_flow/app_theme.dart';
import 'company_settings_screen.dart';
import 'company_details_screen.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen>
    with SingleTickerProviderStateMixin {
  String _userName = 'Cargando...';
  String _email = '...';
  bool _isAdmin = true; // Para pruebas
  late AnimationController _animController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fadeAnimation = CurvedAnimation(
        parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadUser();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final user = Supabase.instance.client.auth.currentUser;
    setState(() {
      _userName = prefs.getString('user_name') ?? 'Usuario de Stock Flow';
      _email = user?.email ?? 'usuario@ejemplo.com';
      // _isAdmin = ... tu logica real
    });
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingLg),
        children: [
          _buildProfileCard(),
          const SizedBox(height: AppTheme.spacingLg),

          _buildSectionTitle('Ajustes de Perfil'),
          _buildSettingTile(
            icon: Icons.person_outline,
            title: 'Editar Perfil',
            subtitle: 'Actualiza tu nombre y foto',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const EditProfileScreen(),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.lock_outline,
            title: 'Seguridad',
            subtitle: 'Contraseña y autenticación',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.notifications_none_outlined,
            title: 'Notificaciones',
            subtitle: 'Alertas de stock y reportes',
            onTap: () {},
          ),

          const SizedBox(height: AppTheme.spacingXl),

          _buildSectionTitle('Empresa'),
          
          _buildSettingTile(
            icon: Icons.business_outlined,
            title: 'Tech Logistics S.A.',
            subtitle: 'Ver detalles de la empresa a la que perteneces',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const CompanyDetailsScreen(),
                ),
              );
            },
          ),
          
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            child: _isAdmin 
                ? _buildSettingTile(
                    icon: Icons.admin_panel_settings_outlined,
                    title: 'Configuración Avanzada',
                    subtitle: 'Gestionar empresa, almacenes y usuarios',
                    isSpecial: true,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const CompanySettingsScreen(),
                        ),
                      );
                    },
                  )
                : const SizedBox.shrink(),
          ),

          const SizedBox(height: AppTheme.spacingXl),
          
          // Otros
          _buildSectionTitle('Soporte y Acerca de'),
          _buildSettingTile(
            icon: Icons.help_outline,
            title: 'Centro de Ayuda',
            onTap: () {},
          ),
          _buildSettingTile(
            icon: Icons.info_outline,
            title: 'Sobre Stock Flow',
            subtitle: 'Versión 1.0.0',
            onTap: () {},
          ),

          const SizedBox(height: AppTheme.spacingXl),

          ElevatedButton.icon(
            onPressed: () async {
              try {
                await Supabase.instance.client.auth.signOut();
                if (context.mounted) {
                  context.go('/');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Error al cerrar sesión')),
                  );
                }
              }
            },
            icon: const Icon(Icons.logout),
            label: const Text('Cerrar Sesión'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.surface,
              foregroundColor: AppTheme.error,
              elevation: 0,
              side: const BorderSide(color: AppTheme.error, width: 1.5),
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
          const SizedBox(height: 100), // Espacio para el nav bar
        ],
      ),
    );
  }

  Widget _buildProfileCard() {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppTheme.primary, AppTheme.primaryDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppTheme.radiusXl),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -20,
            top: -20,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingLg),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                    image: const DecorationImage(
                      image: NetworkImage('https://i.pravatar.cc/150?u=a042581f4e29026704d'), // Mock avatar
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _userName,
                        style: const TextStyle(
                          color: AppTheme.textOnPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _email,
                        style: TextStyle(
                          color: AppTheme.textOnPrimary.withOpacity(0.8),
                          fontSize: 14,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          _isAdmin ? 'Administrador' : 'Empleado',
                          style: const TextStyle(
                            color: AppTheme.textOnPrimary,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
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

  Widget _buildSettingTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    bool isSpecial = false,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: isSpecial ? AppTheme.tertiary.withOpacity(0.05) : AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: isSpecial ? AppTheme.tertiary.withOpacity(0.3) : AppTheme.divider, 
          width: 1
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingMd,
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isSpecial ? AppTheme.tertiary.withOpacity(0.1) : AppTheme.neutral,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon, 
                    color: isSpecial ? AppTheme.tertiary : AppTheme.textDark, 
                    size: 20
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: isSpecial ? AppTheme.tertiaryDark : AppTheme.textDark,
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            color: AppTheme.textLight,
                            fontSize: 13,
                          ),
                        ),
                      ]
                    ],
                  ),
                ),
                Icon(
                  Icons.chevron_right,
                  color: isSpecial ? AppTheme.tertiary : AppTheme.textLight,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

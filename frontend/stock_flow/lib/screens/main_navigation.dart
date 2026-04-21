import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:stock_flow/app_theme.dart';
import 'dashboard_screen.dart';
import 'stock_screen.dart';
import 'data_screen.dart';
import 'profile_screen.dart';
import 'register_selection_screen.dart';

/// Shell principal de la app.
/// Contiene el BottomNavigationBar con 4 tabs y un FloatingActionButton
/// persistente en todas las pantallas.
class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation>
    with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _previousIndex = 0;

  // Animación del indicador deslizante
  late AnimationController _slideController;
  late Animation<double> _slideAnimation;

  // Animación de escala/bounce del ícono activo
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;

  // Animación de fade para la transición de pantallas
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  late final List<Widget> _screens = [
    DashboardScreen(onNavigateToTab: _onTabSelected),
    const StockScreen(),
    const DataScreen(),
    const ProfileScreen(),
  ];

  // Datos de los nav items
  final List<_NavItemData> _navItems = const [
    _NavItemData(Icons.home_outlined, Icons.home_rounded, 'INICIO'),
    _NavItemData(
        Icons.inventory_2_outlined, Icons.inventory_2_rounded, 'STOCK'),
    _NavItemData(Icons.insert_chart_outlined_rounded,
        Icons.insert_chart_rounded, 'DATOS'),
    _NavItemData(Icons.settings_outlined, Icons.settings_rounded, 'AJUSTES'),
  ];

  @override
  void initState() {
    super.initState();

    // Slide del indicador (burbuja de fondo)
    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _slideAnimation = Tween<double>(
      begin: 0,
      end: 0,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    // Bounce del ícono
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _bounceAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.75), weight: 15),
      TweenSequenceItem(tween: Tween(begin: 0.75, end: 1.2), weight: 35),
      TweenSequenceItem(tween: Tween(begin: 1.2, end: 0.95), weight: 25),
      TweenSequenceItem(tween: Tween(begin: 0.95, end: 1.0), weight: 25),
    ]).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.easeOut,
    ));

    // Fade de la pantalla
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _fadeAnimation = Tween<double>(begin: 1.0, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _slideController.dispose();
    _bounceController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _onTabSelected(int index) {
    if (index == _currentIndex) return;

    // Feedback háptico
    HapticFeedback.lightImpact();

    setState(() {
      _previousIndex = _currentIndex;
      _currentIndex = index;
    });

    // 1. Anima el slide del indicador
    _slideAnimation = Tween<double>(
      begin: _previousIndex.toDouble(),
      end: _currentIndex.toDouble(),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));
    _slideController.forward(from: 0);

    // 2. Bounce del ícono seleccionado
    _bounceController.forward(from: 0);

    // 3. Fade out → in de la pantalla
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: Tween(begin: 1.0, end: 0.0), weight: 40),
      TweenSequenceItem(tween: Tween(begin: 0.0, end: 1.0), weight: 60),
    ]).animate(CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeInOut,
    ));
    _fadeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Avatar
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: AppTheme.tertiary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: AppTheme.tertiary, width: 2),
              ),
              child: const Icon(
                Icons.person,
                color: AppTheme.tertiary,
                size: 24,
              ),
            ),
            // Título
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'Stock',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.textDark,
                      letterSpacing: -0.3,
                    ),
                  ),
                  TextSpan(
                    text: 'Flow',
                    style: GoogleFonts.playfairDisplay(
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary,
                      letterSpacing: -0.3,
                    ),
                  ),
                ],
              ),
            ),
            // Notificación
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.notifications_none_rounded,
                color: AppTheme.textDark,
                size: 22,
              ),
            ),
          ],
        ),
      ),
      body: AnimatedBuilder(
        animation: _fadeController,
        builder: (context, child) {
          return Opacity(
            opacity: _fadeAnimation.value.clamp(0.0, 1.0),
            child: Transform.translate(
              offset: Offset(0, (1 - _fadeAnimation.value.clamp(0.0, 1.0)) * 8),
              child: IndexedStack(
                index: _currentIndex,
                children: _screens,
              ),
            ),
          );
        },
      ),

      // ── FloatingActionButton ────────────────────────────────────────
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const RegisterSelectionScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        foregroundColor: AppTheme.textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.add, size: 28),
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────────
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: AppTheme.primary.withValues(alpha: 0.06),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 8),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final itemWidth = constraints.maxWidth / _navItems.length;
                return Stack(
                  children: [
                    // ── Indicador animado (burbuja deslizante) ──────
                    AnimatedBuilder(
                      animation: _slideController,
                      builder: (context, _) {
                        final pos = _slideController.isAnimating
                            ? _slideAnimation.value
                            : _currentIndex.toDouble();
                        return Positioned(
                          left: pos * itemWidth + itemWidth * 0.1,
                          top: 0,
                          bottom: 0,
                          width: itemWidth * 0.8,
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withValues(alpha: 0.10),
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusFull,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                    // ── Items de navegación ─────────────────────────
                    Row(
                      children: List.generate(_navItems.length, (index) {
                        return Expanded(
                          child: _NavItem(
                            data: _navItems[index],
                            isSelected: _currentIndex == index,
                            bounceAnimation: _currentIndex == index
                                ? _bounceAnimation
                                : null,
                            bounceController: _currentIndex == index
                                ? _bounceController
                                : null,
                            onTap: () => _onTabSelected(index),
                          ),
                        );
                      }),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

// ═════════════════════════════════════════════════════════════════════════
// NAV ITEM DATA
// ═════════════════════════════════════════════════════════════════════════
class _NavItemData {
  final IconData icon;
  final IconData activeIcon;
  final String label;

  const _NavItemData(this.icon, this.activeIcon, this.label);
}

// ═════════════════════════════════════════════════════════════════════════
// NAV ITEM WIDGET (con animaciones)
// ═════════════════════════════════════════════════════════════════════════
class _NavItem extends StatelessWidget {
  final _NavItemData data;
  final bool isSelected;
  final Animation<double>? bounceAnimation;
  final AnimationController? bounceController;
  final VoidCallback onTap;

  const _NavItem({
    required this.data,
    required this.isSelected,
    this.bounceAnimation,
    this.bounceController,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 6),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Ícono con bounce
            _buildIcon(),
            const SizedBox(height: 4),
            // Label con fade de color
            AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                color: isSelected ? AppTheme.primary : AppTheme.textLight,
                letterSpacing: 0.5,
              ),
              child: Text(data.label),
            ),
            // Dot indicator debajo del label activo
            const SizedBox(height: 4),
            AnimatedContainer(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              width: isSelected ? 5 : 0,
              height: isSelected ? 5 : 0,
              decoration: const BoxDecoration(
                color: AppTheme.primary,
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildIcon() {
    final icon = Icon(
      isSelected ? data.activeIcon : data.icon,
      color: isSelected ? AppTheme.primary : AppTheme.textLight,
      size: 24,
    );

    if (bounceAnimation != null && bounceController != null) {
      return AnimatedBuilder(
        animation: bounceController!,
        builder: (context, child) {
          return Transform.scale(
            scale: bounceAnimation!.value,
            child: child,
          );
        },
        child: icon,
      );
    }

    // Transición suave cuando se deselecciona
    return AnimatedScale(
      scale: isSelected ? 1.0 : 0.9,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
      child: icon,
    );
  }
}

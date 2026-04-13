import 'package:flutter/material.dart';
import 'package:stock_flow/app_theme.dart';
import 'package:stock_flow/screens/voice_registration_screen.dart';
import 'package:stock_flow/screens/camera_registration_screen.dart';
import 'package:stock_flow/screens/manual_registration_screen.dart';

class RegisterSelectionScreen extends StatelessWidget {
  const RegisterSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.neutral,
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: AppTheme.textDark, size: 20),
        ),
        title: Text(
          'Nuevo registro',
          style: TextStyle(
            fontFamily: 'Noto Serif',
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            fontSize: 20,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppTheme.neutral,
              AppTheme.surfaceVariant.withValues(alpha: 0.3),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 16),
                        _buildScreenHeader(),
                        const SizedBox(height: 24),
                        _buildInfoCard(),
                        const SizedBox(height: 32),
                        const Spacer(),

                        // ── Sección Inteligente ───────────────────
                        _buildSectionLabel('MÉTODOS INTELIGENTES',
                            AppTheme.tertiary, Icons.auto_awesome_rounded),
                        const SizedBox(height: 16),
                        _buildSelectionCard(
                          icon: Icons.camera_alt_rounded,
                          title: 'Fotografiar factura',
                          description: 'Escaneo automático con IA.',
                          buttonText: 'ESCANEAR',
                          isSmart: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const CameraRegistrationScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 16),
                        _buildSelectionCard(
                          icon: Icons.mic_rounded,
                          title: 'Nota de voz',
                          description: 'Dictado inteligente asistido.',
                          buttonText: 'DICTAR',
                          isSmart: true,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const VoiceRegistrationScreen(),
                              ),
                            );
                          },
                        ),

                        const SizedBox(height: 32),

                        // ── Sección Tradicional ───────────────────────
                        _buildSectionLabel('MÉTODOS TRADICIONALES',
                            AppTheme.textLight, Icons.edit_note_rounded),
                        const SizedBox(height: 16),
                        _buildSelectionCard(
                          icon: Icons.text_snippet_rounded,
                          title: 'Registro manual',
                          description: 'Ingreso manual paso a paso.',
                          buttonText: 'INGRESAR',
                          isSmart: false,
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const ManualRegistrationScreen(),
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 48),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildScreenHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'REGISTRO DE INVENTARIO',
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppTheme.primary,
            letterSpacing: 2.0,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Selecciona el método de captura',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w800,
            color: AppTheme.textDark,
            fontFamily: 'Noto Serif',
            height: 1.1,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(
            color: AppTheme.textDark.withValues(alpha: 0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.tertiary.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppTheme.tertiary,
                  size: 18,
                ),
              ),
              const SizedBox(width: 14),
              const Text(
                'Optimiza tu tiempo',
                style: TextStyle(
                  fontSize: 15,
                  color: AppTheme.textDark,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Los métodos inteligentes utilizan IA para procesar tus existencias en segundos, reduciendo errores humanos.',
            style: TextStyle(
              fontSize: 13,
              color: AppTheme.textMedium.withValues(alpha: 0.8),
              fontWeight: FontWeight.w500,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionLabel(String label, Color color, IconData icon) {
    return Row(
      children: [
        Icon(icon, size: 14, color: color.withValues(alpha: 0.8)),
        const SizedBox(width: 10),
        Text(
          label,
          style: TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w900,
            color: color.withValues(alpha: 0.8),
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }

  Widget _buildSelectionCard({
    required IconData icon,
    required String title,
    required String description,
    required String buttonText,
    required bool isSmart,
    required VoidCallback onTap,
  }) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(28),
          child: Container(
            width: double.infinity,
            height: isSmart ? 140 : 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(28),
              boxShadow: [
                BoxShadow(
                  color: (isSmart ? AppTheme.tertiary : AppTheme.textDark)
                      .withValues(alpha: 0.06),
                  blurRadius: 24,
                  offset: const Offset(0, 12),
                ),
              ],
              border: Border.all(
                color: isSmart
                    ? AppTheme.tertiary.withValues(alpha: 0.2)
                    : Colors.white,
                width: 1.5,
              ),
            ),
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                if (isSmart)
                  Positioned(
                    top: -10,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [AppTheme.tertiary, AppTheme.tertiaryDark],
                        ),
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: AppTheme.tertiary.withValues(alpha: 0.3),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.auto_awesome,
                              size: 12, color: Colors.white),
                          const SizedBox(width: 6),
                          const Text(
                            'SMART IA',
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: 0.8,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      _buildCardIcon(icon, isSmart),
                      const SizedBox(width: 18),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              title,
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.textDark,
                                fontFamily: 'Noto Serif',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              description,
                              style: TextStyle(
                                fontSize: 12,
                                color:
                                    AppTheme.textMedium.withValues(alpha: 0.7),
                                height: 1.3,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      _buildActionIndicator(buttonText, isSmart),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildCardIcon(IconData icon, bool isSmart) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isSmart
              ? [
                  AppTheme.tertiary.withValues(alpha: 0.1),
                  AppTheme.tertiary.withValues(alpha: 0.2)
                ]
              : [
                  AppTheme.surfaceVariant.withValues(alpha: 0.2),
                  AppTheme.surfaceVariant.withValues(alpha: 0.4)
                ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        icon,
        color: isSmart ? AppTheme.tertiary : AppTheme.textDark,
        size: 24,
      ),
    );
  }

  Widget _buildActionIndicator(String text, bool isSmart) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isSmart
            ? AppTheme.tertiary
            : AppTheme.surfaceVariant.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        boxShadow: isSmart
            ? [
                BoxShadow(
                  color: AppTheme.tertiary.withValues(alpha: 0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ]
            : [],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            text,
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w900,
              color: isSmart ? Colors.white : AppTheme.textDark,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            Icons.arrow_forward_ios_rounded,
            size: 10,
            color: isSmart ? Colors.white : AppTheme.textDark,
          ),
        ],
      ),
    );
  }
}

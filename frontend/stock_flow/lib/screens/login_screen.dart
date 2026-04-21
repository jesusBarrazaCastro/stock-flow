import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../utilities/msg_util.dart';

const _bg = Color(0xFFFAF0EC);
const _card = Color(0xFFFFFFFF);
const _inputFill = Color(0xFFF2E4DF);
const _accent = Color(0xFFB55A42);
const _darkText = Color(0xFF2D1B17);
const _mutedText = Color(0xFF8A6A62);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint) => InputDecoration(
        filled: true,
        fillColor: _inputFill,
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: _mutedText, fontSize: 14),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: _accent, width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCF4040), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFCF4040), width: 1.5),
        ),
      );

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) return;
    final error = await context.read<AuthProvider>().login(
          _emailCtrl.text.trim(),
          _passCtrl.text,
        );
    if (!mounted) return;
    if (error != null) {
      MsgtUtil.showError(context, error);
    }
    // On success the root Consumer in main.dart rebuilds and shows MainNavigation.
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          MsgtUtil.showWarning(context, 'Soporte próximamente');
        },
        backgroundColor: _accent,
        mini: true,
        elevation: 2,
        child: const Icon(Icons.help_outline_rounded, color: Colors.white, size: 20),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Logo
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: _inputFill,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.archive_rounded,
                    size: 36, color: _accent),
              ),
              const SizedBox(height: 12),
              Text(
                'Stock Flow',
                style: GoogleFonts.notoSerif(
                  fontSize: 26,
                  fontStyle: FontStyle.italic,
                  fontWeight: FontWeight.w600,
                  color: _accent,
                ),
              ),
              const SizedBox(height: 32),

              // Card
              Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _card,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.07),
                      blurRadius: 24,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(28),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Bienvenido\nde vuelta',
                        style: GoogleFonts.notoSerif(
                          fontSize: 30,
                          fontWeight: FontWeight.w700,
                          color: _darkText,
                          height: 1.25,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Gestiona tus activos con precisión editorial.',
                        style:
                            GoogleFonts.manrope(fontSize: 14, color: _mutedText),
                      ),
                      const SizedBox(height: 28),

                      // Email
                      Text(
                        'Email',
                        style: GoogleFonts.manrope(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _darkText),
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration: _fieldDecoration('nombre@empresa.com'),
                        validator: (v) =>
                            (v == null || !v.contains('@'))
                                ? 'Ingresa un email válido'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Password label row
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Password',
                            style: GoogleFonts.manrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: _darkText),
                          ),
                          GestureDetector(
                            onTap: () {
                              MsgtUtil.showWarning(context, 'Recuperación de contraseña próximamente');
                            },
                            child: Text(
                              '¿OLVIDASTE LA CLAVE?',
                              style: GoogleFonts.manrope(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: _accent,
                                letterSpacing: 0.4,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: true,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleLogin(),
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration: _fieldDecoration('••••••••'),
                        validator: (v) =>
                            (v == null || v.isEmpty)
                                ? 'Ingresa tu contraseña'
                                : null,
                      ),
                      const SizedBox(height: 24),

                      // Login button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleLogin,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _accent,
                            disabledBackgroundColor:
                                _accent.withValues(alpha: 0.55),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                            elevation: 0,
                          ),
                          child: isLoading
                              ? const SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: CircularProgressIndicator(
                                      color: Colors.white, strokeWidth: 2.5),
                                )
                              : Text(
                                  'Iniciar sesión',
                                  style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 28),

              // Register link
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/register'),
                child: RichText(
                  text: TextSpan(
                    text: '¿No tienes cuenta?  ',
                    style:
                        GoogleFonts.manrope(fontSize: 14, color: _mutedText),
                    children: [
                      TextSpan(
                        text: 'Regístrate',
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _accent),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}

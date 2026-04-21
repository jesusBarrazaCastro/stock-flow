import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import 'main_navigation.dart';

const _bg = Color(0xFFFAF0EC);
const _card = Color(0xFFFFFFFF);
const _inputFill = Color(0xFFF2E4DF);
const _accent = Color(0xFFB55A42);
const _darkText = Color(0xFF2D1B17);
const _mutedText = Color(0xFF8A6A62);

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _businessCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _obscurePass = true;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _businessCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  InputDecoration _fieldDecoration(String hint, {Widget? suffixIcon}) =>
      InputDecoration(
        filled: true,
        fillColor: _inputFill,
        hintText: hint,
        hintStyle: GoogleFonts.manrope(color: _mutedText, fontSize: 14),
        suffixIcon: suffixIcon,
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
          borderSide:
              const BorderSide(color: Color(0xFFCF4040), width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide:
              const BorderSide(color: Color(0xFFCF4040), width: 1.5),
        ),
      );

  Widget _label(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(
          text,
          style: GoogleFonts.manrope(
              fontSize: 13, fontWeight: FontWeight.w600, color: _darkText),
        ),
      );

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;
    final auth = context.read<AuthProvider>();

    // Step 1: create account
    final registerError = await auth.register(
      _nameCtrl.text.trim(),
      _businessCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (registerError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(registerError, style: GoogleFonts.manrope()),
          backgroundColor: const Color(0xFFCF4040),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Step 2: auto-login
    final loginError = await auth.login(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );

    if (!mounted) return;
    if (loginError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(loginError, style: GoogleFonts.manrope()),
          backgroundColor: const Color(0xFFCF4040),
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    // Success — clear the stack and go to the main app
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isLoading = context.watch<AuthProvider>().isLoading;

    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top logo row (left-aligned per mockup)
              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: const BoxDecoration(
                      color: _inputFill,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.archive_rounded,
                        size: 20, color: _accent),
                  ),
                  const SizedBox(width: 10),
                  Text(
                    'Stock Flow',
                    style: GoogleFonts.notoSerif(
                      fontSize: 20,
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.w600,
                      color: _accent,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 28),

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
                        'Comienza ahora',
                        style: GoogleFonts.notoSerif(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: _darkText,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Crea tu cuenta de Stock Flow hoy mismo.',
                        style: GoogleFonts.manrope(
                            fontSize: 14, color: _mutedText),
                      ),
                      const SizedBox(height: 28),

                      // Nombre
                      _label('Nombre'),
                      TextFormField(
                        controller: _nameCtrl,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration:
                            _fieldDecoration('Tu nombre completo'),
                        validator: (v) => (v == null || v.trim().isEmpty)
                            ? 'El nombre es requerido'
                            : null,
                      ),
                      const SizedBox(height: 16),

                      // Nombre del negocio
                      _label('Nombre del negocio'),
                      TextFormField(
                        controller: _businessCtrl,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration: _fieldDecoration(
                            'Ej. Estudio Creativo S.A.'),
                      ),
                      const SizedBox(height: 16),

                      // Correo electrónico
                      _label('Correo electrónico'),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration:
                            _fieldDecoration('correo@ejemplo.com'),
                        validator: (v) =>
                            (v == null || !v.contains('@'))
                                ? 'Ingresa un email válido'
                                : null,
                      ),
                      const SizedBox(height: 16),

                      // Contraseña
                      _label('Contraseña'),
                      TextFormField(
                        controller: _passCtrl,
                        obscureText: _obscurePass,
                        textInputAction: TextInputAction.done,
                        onFieldSubmitted: (_) => _handleRegister(),
                        style: GoogleFonts.manrope(
                            color: _darkText, fontSize: 14),
                        decoration: _fieldDecoration(
                          '••••••••',
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscurePass
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                              color: _mutedText,
                              size: 20,
                            ),
                            onPressed: () =>
                                setState(() => _obscurePass = !_obscurePass),
                          ),
                        ),
                        validator: (v) => (v == null || v.length < 6)
                            ? 'Mínimo 6 caracteres'
                            : null,
                      ),
                      const SizedBox(height: 24),

                      // Submit button
                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: ElevatedButton(
                          onPressed: isLoading ? null : _handleRegister,
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
                                      color: Colors.white,
                                      strokeWidth: 2.5),
                                )
                              : Text(
                                  'Crear cuenta',
                                  style: GoogleFonts.manrope(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                ),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Login link
                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.pop(context),
                          child: RichText(
                            text: TextSpan(
                              text: '¿Ya tienes una cuenta?  ',
                              style: GoogleFonts.manrope(
                                  fontSize: 14, color: _mutedText),
                              children: [
                                TextSpan(
                                  text: 'Inicia sesión aquí',
                                  style: GoogleFonts.manrope(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w700,
                                      color: _accent),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Footer
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'EST. 2024 — STOCK FLOW SYSTEMS',
                    style: GoogleFonts.manrope(
                        fontSize: 10,
                        color: _mutedText,
                        letterSpacing: 0.5),
                  ),
                  Text(
                    '●  ▲  ■',
                    style: GoogleFonts.manrope(
                        fontSize: 10, color: _mutedText),
                  ),
                ],
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

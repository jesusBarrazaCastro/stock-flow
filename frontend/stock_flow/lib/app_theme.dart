import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const coral     = Color(0xFFE8836A);
  static const coralSuave = Color(0xFFF2A98B);
  static const fondoCalido = Color(0xFFFAF0EC);
  static const textoDark  = Color(0xFF2D2D2D);
  static const textoGris  = Color(0xFF8A8A8A);

  static ThemeData get light => tema;

  static ThemeData get tema => ThemeData(
    colorScheme: ColorScheme.fromSeed(seedColor: coral),
    scaffoldBackgroundColor: fondoCalido,
    appBarTheme: const AppBarTheme(
      backgroundColor: coral,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    textTheme: GoogleFonts.dmSansTextTheme().copyWith(
      displayLarge: GoogleFonts.lora(color: textoDark),
      displayMedium: GoogleFonts.lora(color: textoDark),
      displaySmall: GoogleFonts.lora(color: textoDark),
      headlineMedium: GoogleFonts.lora(color: textoDark),
      headlineSmall: GoogleFonts.lora(color: textoDark),
      titleLarge: GoogleFonts.lora(color: textoDark, fontWeight: FontWeight.bold),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: coral, width: 2),
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: coral,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
  );
}

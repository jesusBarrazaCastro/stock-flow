import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Design system principal de Stock Flow.
///
/// Colores extraídos del design system:
///   Primary   → #E8836A  (coral cálido)
///   Secondary → #F2A98B  (melocotón suave)
///   Tertiary  → #34B19B  (teal vibrante)
///   Neutral   → #FAF0EC  (beige cálido)
///
/// Tipografías:
///   Headline → Noto Serif
///   Body     → Manrope
///   Label    → Manrope
class AppTheme {
  AppTheme._(); // No instanciar

  // ── Paleta principal ──────────────────────────────────────────────
  static const Color primary       = Color(0xFFE8836A);
  static const Color primaryDark   = Color(0xFFD06A52);
  static const Color primaryLight  = Color(0xFFF0A08D);

  static const Color secondary     = Color(0xFFF2A98B);
  static const Color secondaryDark = Color(0xFFDA8E6F);
  static const Color secondaryLight= Color(0xFFF8C8B3);

  static const Color tertiary      = Color(0xFF34B19B);
  static const Color tertiaryDark  = Color(0xFF279480);
  static const Color tertiaryLight = Color(0xFF5CC8B5);

  // ── Neutrales ─────────────────────────────────────────────────────
  static const Color neutral       = Color(0xFFFAF0EC);
  static const Color surface       = Color(0xFFFFF8F5);
  static const Color surfaceVariant= Color(0xFFF0E0D8);
  static const Color cardColor     = Color(0xFFFAF0EC);

  // ── Texto ─────────────────────────────────────────────────────────
  static const Color textDark      = Color(0xFF3B2218);
  static const Color textMedium    = Color(0xFF6B4F43);
  static const Color textLight     = Color(0xFF8A7A72);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Semánticos ────────────────────────────────────────────────────
  static const Color success       = Color(0xFF34B19B);
  static const Color warning       = Color(0xFFE8A84A);
  static const Color error         = Color(0xFFCF4040);
  static const Color info          = Color(0xFF5A8FBF);

  // ── Bordes / Dividers ─────────────────────────────────────────────
  static const Color border        = Color(0xFFDBC8BD);
  static const Color divider       = Color(0xFFE8D5CB);

  // ── Sombras ───────────────────────────────────────────────────────
  static List<BoxShadow> get cardShadow => [
    BoxShadow(
      color: primary.withOpacity(0.06),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> get elevatedShadow => [
    BoxShadow(
      color: primary.withOpacity(0.10),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
  ];

  // ── Radii ─────────────────────────────────────────────────────────
  static const double radiusSm  = 8;
  static const double radiusMd  = 12;
  static const double radiusLg  = 16;
  static const double radiusXl  = 24;
  static const double radiusFull= 100;

  // ── Spacing ───────────────────────────────────────────────────────
  static const double spacingXs  = 4;
  static const double spacingSm  = 8;
  static const double spacingMd  = 16;
  static const double spacingLg  = 24;
  static const double spacingXl  = 32;

  // ── Alias de acceso ───────────────────────────────────────────────
  // Para compatibilidad hacia atrás con código que use AppTheme.light
  static ThemeData get light => tema;

  // ── Alias colores previos (compatibilidad) ────────────────────────
  static const Color coral       = primary;
  static const Color coralSuave  = secondary;
  static const Color fondoCalido = neutral;
  static const Color textoDark   = textDark;
  static const Color textoGris   = textLight;

  // ═══════════════════════════════════════════════════════════════════
  // TEMA PRINCIPAL
  // ═══════════════════════════════════════════════════════════════════
  static ThemeData get tema {
    final baseTextTheme = GoogleFonts.manropeTextTheme();

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,

      // ── Color Scheme ────────────────────────────────────────────
      colorScheme: ColorScheme(
        brightness: Brightness.light,
        primary:           primary,
        onPrimary:         textOnPrimary,
        primaryContainer:  secondaryLight,
        onPrimaryContainer:textDark,
        secondary:         secondary,
        onSecondary:       textDark,
        secondaryContainer:secondaryLight,
        onSecondaryContainer: textDark,
        tertiary:          tertiary,
        onTertiary:        textOnPrimary,
        tertiaryContainer: tertiaryLight,
        onTertiaryContainer: textDark,
        error:             error,
        onError:           textOnPrimary,
        surface:           surface,
        onSurface:         textDark,
        surfaceContainerHighest: surfaceVariant,
        outline:           border,
        outlineVariant:    divider,
      ),

      scaffoldBackgroundColor: neutral,
      cardColor: cardColor,
      dividerColor: divider,
      splashColor: primary.withOpacity(0.08),
      highlightColor: primary.withOpacity(0.05),

      // ── Typography ──────────────────────────────────────────────
      textTheme: baseTextTheme.copyWith(
        // Headlines → Noto Serif
        displayLarge:  GoogleFonts.notoSerif(
          color: textDark, fontSize: 57, fontWeight: FontWeight.w400,
        ),
        displayMedium: GoogleFonts.notoSerif(
          color: textDark, fontSize: 45, fontWeight: FontWeight.w400,
        ),
        displaySmall:  GoogleFonts.notoSerif(
          color: textDark, fontSize: 36, fontWeight: FontWeight.w400,
        ),
        headlineLarge: GoogleFonts.notoSerif(
          color: textDark, fontSize: 32, fontWeight: FontWeight.w600,
        ),
        headlineMedium: GoogleFonts.notoSerif(
          color: textDark, fontSize: 28, fontWeight: FontWeight.w600,
        ),
        headlineSmall: GoogleFonts.notoSerif(
          color: textDark, fontSize: 24, fontWeight: FontWeight.w600,
        ),
        // Titles → Manrope bold
        titleLarge: GoogleFonts.manrope(
          color: textDark, fontSize: 22, fontWeight: FontWeight.w700,
        ),
        titleMedium: GoogleFonts.manrope(
          color: textDark, fontSize: 16, fontWeight: FontWeight.w600,
        ),
        titleSmall: GoogleFonts.manrope(
          color: textDark, fontSize: 14, fontWeight: FontWeight.w600,
        ),
        // Body → Manrope
        bodyLarge: GoogleFonts.manrope(
          color: textDark, fontSize: 16, fontWeight: FontWeight.w400,
        ),
        bodyMedium: GoogleFonts.manrope(
          color: textMedium, fontSize: 14, fontWeight: FontWeight.w400,
        ),
        bodySmall: GoogleFonts.manrope(
          color: textLight, fontSize: 12, fontWeight: FontWeight.w400,
        ),
        // Labels → Manrope
        labelLarge: GoogleFonts.manrope(
          color: textDark, fontSize: 14, fontWeight: FontWeight.w600,
        ),
        labelMedium: GoogleFonts.manrope(
          color: textMedium, fontSize: 12, fontWeight: FontWeight.w500,
        ),
        labelSmall: GoogleFonts.manrope(
          color: textLight, fontSize: 11, fontWeight: FontWeight.w500,
        ),
      ),

      // ── AppBar ──────────────────────────────────────────────────
      appBarTheme: AppBarTheme(
        backgroundColor: neutral,
        foregroundColor: textDark,
        elevation: 0,
        scrolledUnderElevation: 1,
        surfaceTintColor: Colors.transparent,
        centerTitle: true,
        titleTextStyle: GoogleFonts.notoSerif(
          color: textDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: textDark, size: 24),
      ),

      // ── Cards ───────────────────────────────────────────────────
      cardTheme: CardThemeData(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLg),
          side: BorderSide(color: divider, width: 1),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingSm,
        ),
      ),

      // ── ElevatedButton (Primary) ────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: textOnPrimary,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── OutlinedButton (Outlined) ───────────────────────────────
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: textDark,
          side: BorderSide(color: border, width: 1.5),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── TextButton ──────────────────────────────────────────────
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FilledButton (Inverted / Secondary) ─────────────────────
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: textDark,
          foregroundColor: textOnPrimary,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusFull),
          ),
          textStyle: GoogleFonts.manrope(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),

      // ── FAB ─────────────────────────────────────────────────────
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: tertiary,
        foregroundColor: textOnPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
      ),

      // ── Input / TextField ───────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        hintStyle: GoogleFonts.manrope(
          color: textLight,
          fontSize: 14,
        ),
        labelStyle: GoogleFonts.manrope(
          color: textMedium,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: BorderSide(color: border, width: 1.5),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMd),
          borderSide: const BorderSide(color: error, width: 2),
        ),
        prefixIconColor: textLight,
        suffixIconColor: textLight,
      ),

      // ── Chips ───────────────────────────────────────────────────
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary,
        disabledColor: surfaceVariant.withOpacity(0.5),
        labelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textDark,
        ),
        secondaryLabelStyle: GoogleFonts.manrope(
          fontSize: 13,
          fontWeight: FontWeight.w500,
          color: textOnPrimary,
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusFull),
        ),
        side: BorderSide.none,
      ),

      // ── Bottom Navigation Bar ───────────────────────────────────
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: neutral,
        selectedItemColor: primary,
        unselectedItemColor: textLight,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        selectedLabelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 12,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── Navigation Bar (Material 3) ────────────────────────────
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: neutral,
        indicatorColor: primary.withOpacity(0.15),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return GoogleFonts.manrope(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: primary,
            );
          }
          return GoogleFonts.manrope(
            fontSize: 12,
            fontWeight: FontWeight.w400,
            color: textLight,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return const IconThemeData(color: primary, size: 24);
          }
          return const IconThemeData(color: textLight, size: 24);
        }),
      ),

      // ── Divider ─────────────────────────────────────────────────
      dividerTheme: const DividerThemeData(
        color: divider,
        thickness: 1,
        space: 1,
      ),

      // ── SnackBar ────────────────────────────────────────────────
      snackBarTheme: SnackBarThemeData(
        backgroundColor: textDark,
        contentTextStyle: GoogleFonts.manrope(
          color: textOnPrimary,
          fontSize: 14,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        behavior: SnackBarBehavior.floating,
      ),

      // ── Dialog ──────────────────────────────────────────────────
      dialogTheme: DialogThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
        titleTextStyle: GoogleFonts.notoSerif(
          color: textDark,
          fontSize: 22,
          fontWeight: FontWeight.w600,
        ),
        contentTextStyle: GoogleFonts.manrope(
          color: textMedium,
          fontSize: 14,
        ),
      ),

      // ── BottomSheet ─────────────────────────────────────────────
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(radiusXl),
          ),
        ),
      ),

      // ── TabBar ──────────────────────────────────────────────────
      tabBarTheme: TabBarThemeData(
        labelColor: primary,
        unselectedLabelColor: textLight,
        indicatorColor: primary,
        indicatorSize: TabBarIndicatorSize.label,
        labelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
        unselectedLabelStyle: GoogleFonts.manrope(
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),
      ),

      // ── PopupMenu ───────────────────────────────────────────────
      popupMenuTheme: PopupMenuThemeData(
        color: surface,
        surfaceTintColor: Colors.transparent,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        textStyle: GoogleFonts.manrope(
          color: textDark,
          fontSize: 14,
        ),
      ),

      // ── Tooltip ─────────────────────────────────────────────────
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: textDark,
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        textStyle: GoogleFonts.manrope(
          color: textOnPrimary,
          fontSize: 12,
        ),
      ),

      // ── Switch / Checkbox / Radio ───────────────────────────────
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textLight;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primaryLight;
          return surfaceVariant;
        }),
      ),

      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return Colors.transparent;
        }),
        checkColor: WidgetStateProperty.all(textOnPrimary),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(4),
        ),
        side: BorderSide(color: border, width: 1.5),
      ),

      radioTheme: RadioThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) return primary;
          return textLight;
        }),
      ),

      // ── Progress Indicators ─────────────────────────────────────
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: primary,
        linearTrackColor: surfaceVariant,
        circularTrackColor: surfaceVariant,
      ),

      // ── Icon Theme ──────────────────────────────────────────────
      iconTheme: const IconThemeData(
        color: textDark,
        size: 24,
      ),

      // ── ListTile ────────────────────────────────────────────────
      listTileTheme: ListTileThemeData(
        tileColor: Colors.transparent,
        selectedTileColor: primary.withOpacity(0.08),
        iconColor: textMedium,
        textColor: textDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMd),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMd,
          vertical: spacingXs,
        ),
      ),

      // ── Drawer ──────────────────────────────────────────────────
      drawerTheme: const DrawerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ── Date Picker ─────────────────────────────────────────────
      datePickerTheme: DatePickerThemeData(
        backgroundColor: surface,
        surfaceTintColor: Colors.transparent,
        headerBackgroundColor: primary,
        headerForegroundColor: textOnPrimary,
        dayStyle: GoogleFonts.manrope(fontSize: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusXl),
        ),
      ),
    );
  }
}

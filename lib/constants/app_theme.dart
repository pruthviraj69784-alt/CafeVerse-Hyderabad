import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primaryColor     = Color(0xFF452B19);
  static const Color secondaryColor   = Color(0xFFD4A843);
  static const Color backgroundColor  = Color(0xFFF7F3EE);
  static const Color surfaceColor     = Color(0xFFFFFFFF);
  static const Color _darkText        = Color(0xFF2B1A0F);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: _darkText,
      error: Color(0xFFC62828),
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,

    // ── Typography (Google Fonts: Inter) ────────────────────────
    textTheme: GoogleFonts.interTextTheme().copyWith(
      displayLarge: GoogleFonts.inter(
        fontSize: 40, fontWeight: FontWeight.w800, color: _darkText,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 34, fontWeight: FontWeight.w700, color: _darkText,
      ),
      headlineLarge: GoogleFonts.inter(
        fontSize: 30, fontWeight: FontWeight.bold, color: _darkText,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 26, fontWeight: FontWeight.bold, color: _darkText,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 22, fontWeight: FontWeight.bold, color: _darkText,
      ),
      titleLarge: GoogleFonts.inter(
        fontSize: 20, fontWeight: FontWeight.w700, color: _darkText,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w600, color: _darkText,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: _darkText,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16, fontWeight: FontWeight.w400, color: _darkText,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w400, color: _darkText,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w400, color: Color(0xFF8D6E63),
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 14, fontWeight: FontWeight.w600, color: _darkText,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12, fontWeight: FontWeight.w500, color: Color(0xFF8D6E63),
      ),
    ),

    // ── AppBar ─────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: primaryColor),
      titleTextStyle: GoogleFonts.inter(
        color: primaryColor,
        fontSize: 18,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.2,
      ),
    ),

    // ── Cards ──────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),

    // ── Elevated Buttons ───────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
        elevation: 0,
      ),
    ),

    // ── Text Buttons ───────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryColor,
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Outlined Buttons ───────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryColor,
        side: const BorderSide(color: Color(0xFFD7C4B0), width: 1.5),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    ),

    // ── Input Decoration ───────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFAF7F3),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0D5C8)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFE0D5C8)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFC62828)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: Color(0xFFC62828), width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        color: const Color(0xFF8D6E63),
        fontWeight: FontWeight.w500,
        fontSize: 14,
      ),
      hintStyle: GoogleFonts.inter(
        color: const Color(0xFFBCAA9A),
        fontSize: 14,
      ),
      prefixIconColor: const Color(0xFF8D6E63),
    ),

    // ── Chip Theme ─────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryColor,
      disabledColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      side: const BorderSide(color: Color(0xFFD7C4B0)),
      labelStyle: GoogleFonts.inter(
        color: primaryColor,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      secondaryLabelStyle: GoogleFonts.inter(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
    ),

    // ── Divider ────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: Color(0xFFF0E8DC),
      thickness: 1,
      space: 1,
    ),

    // ── FloatingActionButton ───────────────────────────────────
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: primaryColor,
      foregroundColor: Colors.white,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(16)),
      ),
    ),

    // ── SnackBar ───────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: const Color(0xFF2B1A0F),
      contentTextStyle: GoogleFonts.inter(
        color: Colors.white,
        fontSize: 13,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // ── Dialog ─────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: _darkText,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        color: Color(0xFF5C4033),
      ),
    ),
  );
}

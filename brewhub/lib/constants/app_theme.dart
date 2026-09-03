import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryColor = Color(0xFF452B19);
  static const Color secondaryColor = Color(0xFFD2B48C);
  static const Color backgroundColor = Color(0xFFF5EFE7);
  static const Color surfaceColor = Color(0xFFFFFFFF);

  static final ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ).copyWith(
      primary: primaryColor,
      secondary: secondaryColor,
      surface: surfaceColor,
      onSurface: Colors.black87,
      error: Colors.red,
      onError: Colors.white,
    ),
    scaffoldBackgroundColor: backgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: primaryColor,
      elevation: 0,
      centerTitle: true,
      iconTheme: IconThemeData(color: primaryColor),
      titleTextStyle: TextStyle(
        color: primaryColor,
        fontSize: 20,
        fontWeight: FontWeight.bold,
      ),
    ),
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 6,
      shadowColor: Colors.black12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        elevation: 4,
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color.fromRGBO(255, 255, 255, 0.95),
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: primaryColor, width: 2),
      ),
      labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600),
      hintStyle: TextStyle(color: Colors.grey.shade500),
    ),
    textTheme: const TextTheme(
      headlineSmall: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.black87),
      titleLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87),
      bodyMedium: TextStyle(fontSize: 16, color: Colors.black87),
      bodySmall: TextStyle(fontSize: 14, color: Colors.black54),
    ),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceColor,
      selectedItemColor: primaryColor,
      unselectedItemColor: Colors.grey.shade600,
      elevation: 12,
      showUnselectedLabels: true,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: Colors.white,
      selectedColor: primaryColor,
      disabledColor: Colors.grey.shade200,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      side: BorderSide(color: primaryColor.withAlpha(38)),
      labelStyle: const TextStyle(color: primaryColor, fontWeight: FontWeight.w600),
      secondaryLabelStyle: const TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
    ),
  );
}

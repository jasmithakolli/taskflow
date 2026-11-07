import 'package:flutter/material.dart';

class AppTheme {
  static const purple = Color(0xFF8067E8);
  static const purpleSoft = Color(0xFFB6A8FF);
  static const mint = Color(0xFF6FD6B0);
  static const coral = Color(0xFFFF887D);
  static const amber = Color(0xFFF4BD68);

  static ThemeData get dark => _build(Brightness.dark);
  static ThemeData get light => _build(Brightness.light);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: purple,
      brightness: brightness,
      surface: dark ? const Color(0xFF1B1B29) : Colors.white,
    );
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor:
          dark ? const Color(0xFF101018) : const Color(0xFFF5F4FA),
      cardColor: dark ? const Color(0xFF1B1B29) : Colors.white,
      dividerColor: dark ? Colors.white10 : const Color(0xFFE9E6F0),
      appBarTheme: AppBarTheme(
        backgroundColor: dark ? const Color(0xFF101018) : const Color(0xFFF5F4FA),
        foregroundColor: dark ? Colors.white : const Color(0xFF242235),
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      textTheme: ThemeData(brightness: brightness).textTheme.apply(
        bodyColor: dark ? const Color(0xFFF4F1FA) : const Color(0xFF28263A),
        displayColor: dark ? const Color(0xFFF4F1FA) : const Color(0xFF28263A),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? const Color(0xFF252437) : const Color(0xFFF1EFF7),
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
          borderSide: const BorderSide(color: purple, width: 1.4),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: purple,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }
}

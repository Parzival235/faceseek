import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  static const Color primary = Color(0xFF6C63FF);
  static const Color background = Color(0xFF0D0D0D);
  static const Color surface = Color(0xFF1A1A1A);
  static const Color surfaceVariant = Color(0xFF252525);
  static const Color onSurface = Color(0xFFE8E8E8);
  static const Color onSurfaceMuted = Color(0xFF8A8A8A);
  static const Color accent = Color(0xFF00D4AA);
  static const Color error = Color(0xFFFF4D4D);

  static ThemeData dark() {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        surface: surface,
        error: error,
      ),
      textTheme: GoogleFonts.interTextTheme(
        const TextTheme(
          displayLarge: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
          displayMedium: TextStyle(color: onSurface, fontWeight: FontWeight.bold),
          headlineLarge: TextStyle(color: onSurface, fontWeight: FontWeight.w700),
          headlineMedium: TextStyle(color: onSurface, fontWeight: FontWeight.w600),
          bodyLarge: TextStyle(color: onSurface),
          bodyMedium: TextStyle(color: onSurfaceMuted),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      cardTheme: CardTheme(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }
}

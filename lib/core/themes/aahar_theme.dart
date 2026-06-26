import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AaharTheme {
  static const Color brandPrimary = Color(0xFF1E2A4A);
  static const Color brandLime = Color(0xFFCAFF3D);
  static const Color brandOrange = Color(0xFFE07B00);

  static const Color nutrientProtein = Color(0xFF1D9E75);
  static const Color nutrientCarbs = Color(0xFF378ADD);
  static const Color nutrientFat = Color(0xFFE07B00);
  static const Color nutrientIron = Color(0xFFD4537E);

  // Light surface
  static const Color surface = Color(0xFFFAFAF9);
  static const Color surfaceSecondary = Color(0xFFF0EEE8);

  // Dark surface
  static const Color darkBg = Color(0xFF0F0F0F);
  static const Color darkSurface = Color(0xFF1A1A1A);
  static const Color darkSurfaceSecondary = Color(0xFF252525);

  static TextTheme _textTheme(Color color) =>
      GoogleFonts.dmSansTextTheme().apply(bodyColor: color, displayColor: color);

  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.dark(
      primary: brandLime,
      onPrimary: darkBg,
      secondary: brandLime,
      onSecondary: darkBg,
      surface: darkSurface,
      onSurface: Colors.white,
      error: const Color(0xFFCF6679),
    );
    final textTheme = _textTheme(Colors.white);
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: darkBg,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: darkSurface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandLime,
          foregroundColor: darkBg,
          minimumSize: const Size.fromHeight(52),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          textStyle: textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: brandPrimary,
      brightness: Brightness.light,
      surface: surface,
    ).copyWith(
      primary: brandPrimary,
      secondary: brandOrange,
      surface: surface,
      onSurface: const Color(0xFF1A1A1A),
    );
    final textTheme = _textTheme(const Color(0xFF1A1A1A));
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: surface,
      textTheme: textTheme,
      primaryTextTheme: textTheme,
      cardTheme: CardThemeData(
        color: surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: brandPrimary,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(38),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          textStyle: textTheme.labelLarge,
        ),
      ),
    );
  }
}

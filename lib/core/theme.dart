// lib/core/theme.dart

import 'package:flutter/material.dart';

class AppTheme {
  // Vibrant crimson for buttons and headers
  static const Color primaryRed = Color(0xFFD32F2F);
  // Near-black dark red for the main app background
  static const Color darkRedBackground = Color(0xFF160303);
  // Slightly lighter dark red for cards and popups to create contrast
  static const Color darkRedSurface = Color(0xFF280606);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkRedBackground,
      colorScheme: const ColorScheme.dark(
        primary: primaryRed,
        surface: darkRedBackground,
        onPrimary: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 4,
        titleTextStyle: TextStyle(
          fontFamily: 'RacingSansOne',
          fontSize: 28,
          color: Colors.white,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: const CardThemeData(
        color: darkRedSurface,
        elevation: 4.0,
        margin: EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(16)),
        ),
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryRed,
        foregroundColor: Colors.white,
        elevation: 6,
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return primaryRed;
          }
          return null;
        }),
      ),
    );
  }
}

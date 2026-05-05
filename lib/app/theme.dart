// SmartChat - App Theme
//
// Defines light and dark theme data using Material 3 design.
// Uses a custom color scheme with the SmartChat brand colors.

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  AppTheme._(); // Prevent instantiation

  // ─── Light Mode Colors ────────────────────────────────
  static const Color _lightPrimary = Color(0xFF2563EB);
  static const Color _lightAccent = Color(0xFF14B8A6);
  static const Color _lightBackground = Color(0xFFF8FAFC);
  static const Color _lightChatBackground = Color(0xFFF1F5F9);
  static const Color _lightSurface = Color(0xFFFFFFFF);
  static const Color _lightText = Color(0xFF0F172A);
  static const Color _lightSecondaryText = Color(0xFF64748B);
  static const Color _lightBorder = Color(0xFFE2E8F0);
  static const Color _lightSuccess = Color(0xFF22C55E);
  static const Color _lightError = Color(0xFFEF4444);

  // ─── Dark Mode Colors ─────────────────────────────────
  static const Color _darkPrimary = Color(0xFF3B82F6);
  static const Color _darkAccent = Color(0xFF22D3EE);
  static const Color _darkBackground = Color(0xFF0F172A);
  static const Color _darkChatBackground = Color(0xFF111827);
  static const Color _darkSurface = Color(0xFF1E293B);
  static const Color _darkText = Color(0xFFF8FAFC);
  static const Color _darkSecondaryText = Color(0xFF94A3B8);
  static const Color _darkBorder = Color(0xFF334155);

  // Expose colors for use throughout the app
  static Color chatBackground(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _darkChatBackground
        : _lightChatBackground;
  }

  static Color successColor(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? _lightSuccess
        : _lightSuccess;
  }

  // ─── Light Theme ──────────────────────────────────────

  static ThemeData get lightTheme {
    const colorScheme = ColorScheme.light(
      primary: _lightPrimary,
      onPrimary: Colors.white,
      secondary: _lightAccent,
      onSecondary: Colors.white,
      surface: _lightSurface,
      onSurface: _lightText,
      onSurfaceVariant: _lightSecondaryText,
      error: _lightError,
      onError: Colors.white,
      outline: _lightBorder,
      outlineVariant: _lightBorder,
      surfaceContainerHighest: _lightChatBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _lightBackground,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.light().textTheme,
      ).apply(bodyColor: _lightText, displayColor: _lightText),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _lightSurface,
        foregroundColor: _lightText,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        backgroundColor: _lightSurface,
        indicatorColor: _lightPrimary.withValues(alpha: 0.2),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _lightChatBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _lightPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _lightPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _lightPrimary,
          side: const BorderSide(color: _lightPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _lightBorder.withValues(alpha: 0.5),
        space: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _lightSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _lightBorder),
        ),
      ),
    );
  }

  // ─── Dark Theme ───────────────────────────────────────

  static ThemeData get darkTheme {
    const colorScheme = ColorScheme.dark(
      primary: _darkPrimary,
      onPrimary: Colors.white,
      secondary: _darkAccent,
      onSecondary: _darkBackground,
      surface: _darkSurface,
      onSurface: _darkText,
      onSurfaceVariant: _darkSecondaryText,
      error: _lightError,
      onError: Colors.white,
      outline: _darkBorder,
      outlineVariant: _darkBorder,
      surfaceContainerHighest: _darkChatBackground,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _darkBackground,
      textTheme: GoogleFonts.poppinsTextTheme(
        ThemeData.dark().textTheme,
      ).apply(bodyColor: _darkText, displayColor: _darkText),
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        elevation: 0,
        scrolledUnderElevation: 1,
        backgroundColor: _darkSurface,
        foregroundColor: _darkText,
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 1,
        backgroundColor: _darkSurface,
        indicatorColor: _darkPrimary.withValues(alpha: 0.3),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _darkChatBackground,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: _darkPrimary, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: _darkPrimary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _darkPrimary,
          side: const BorderSide(color: _darkPrimary),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: _darkBorder.withValues(alpha: 0.5),
        space: 1,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: _darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: const BorderSide(color: _darkBorder),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Available theme options for the app
enum AppThemeMode {
  warmCalming('Warm & Calming', 'อบอุ่นและสงบ'),
  brightCheerful('Bright & Cheerful', 'สดใสและร่าเริง'),
  classicProfessional('Classic & Professional', 'คลาสสิกและมืออาชีพ'),
  earthyNatural('Earthy & Natural', 'โทนดินและธรรมชาติ');

  final String nameEn;
  final String nameTh;

  const AppThemeMode(this.nameEn, this.nameTh);
}

/// App theme configurations
class AppThemes {
  /// Warm & Calming Theme (Default) - Soft Teal, Sage Green, Terracotta
  static ThemeData warmCalmingTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF2E7D8C), // Soft Teal
        primaryContainer: const Color(0xFFB8E3E8),
        secondary: const Color(0xFF6B9B7D), // Sage Green
        secondaryContainer: const Color(0xFFD4E8DC),
        tertiary: const Color(0xFFD97D54), // Warm Terracotta
        tertiaryContainer: const Color(0xFFFADFD0),
        surface: const Color(0xFFFAFBFC),
        surfaceContainerHighest: const Color(0xFFF0F4F5),
        error: const Color(0xFFD84848),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF2C3E50),
        onSurfaceVariant: const Color(0xFF5A6A7A),
        outline: const Color(0xFFD0D8E0),
      ),
      useMaterial3: true,
      fontFamily: 'Sarabun',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: 28, color: Colors.white),
        actionsIconTheme: IconThemeData(size: 28, color: Colors.white),
      ),
    );
  }

  /// Bright & Cheerful Theme - Coral, Soft Yellow, Light Blue
  static ThemeData brightCheerfulTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFFF6B6B), // Coral Red
        primaryContainer: const Color(0xFFFFE0E0),
        secondary: const Color(0xFFFFA726), // Soft Orange
        secondaryContainer: const Color(0xFFFFE4CC),
        tertiary: const Color(0xFF42A5F5), // Sky Blue
        tertiaryContainer: const Color(0xFFD4E9FF),
        surface: const Color(0xFFFFFBF5),
        surfaceContainerHighest: const Color(0xFFFFF4E6),
        error: const Color(0xFFE53935),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF1A1A1A),
        onSurfaceVariant: const Color(0xFF616161),
        outline: const Color(0xFFE0E0E0),
      ),
      useMaterial3: true,
      fontFamily: 'Sarabun',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: 28, color: Colors.white),
        actionsIconTheme: IconThemeData(size: 28, color: Colors.white),
      ),
    );
  }

  /// Classic & Professional Theme - Navy Blue, Gold, Off-White
  static ThemeData classicProfessionalTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFF1A237E), // Navy Blue
        primaryContainer: const Color(0xFFC5CAE9),
        secondary: const Color(0xFFD4AF37), // Gold
        secondaryContainer: const Color(0xFFFFF9E6),
        tertiary: const Color(0xFF5C6BC0), // Indigo
        tertiaryContainer: const Color(0xFFE8EAF6),
        surface: const Color(0xFFFAFAFA),
        surfaceContainerHighest: const Color(0xFFF5F5F5),
        error: const Color(0xFFC62828),
        onPrimary: Colors.white,
        onSecondary: const Color(0xFF1A1A1A),
        onSurface: const Color(0xFF212121),
        onSurfaceVariant: const Color(0xFF757575),
        outline: const Color(0xFFBDBDBD),
      ),
      useMaterial3: true,
      fontFamily: 'Sarabun',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: 28, color: Colors.white),
        actionsIconTheme: IconThemeData(size: 28, color: Colors.white),
      ),
    );
  }

  /// Earthy & Natural Theme - Terracotta, Olive Green, Sand Beige
  static ThemeData earthyNaturalTheme() {
    return ThemeData(
      colorScheme: ColorScheme.light(
        primary: const Color(0xFFB85C38), // Terracotta
        primaryContainer: const Color(0xFFFFE4D6),
        secondary: const Color(0xFF8B9D77), // Olive Green
        secondaryContainer: const Color(0xFFE8F0E0),
        tertiary: const Color(0xFFD4A574), // Sand Brown
        tertiaryContainer: const Color(0xFFF5EAD9),
        surface: const Color(0xFFFAF7F2),
        surfaceContainerHighest: const Color(0xFFF0EBE3),
        error: const Color(0xFFD84848),
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: const Color(0xFF3E2723),
        onSurfaceVariant: const Color(0xFF6D4C41),
        outline: const Color(0xFFD7CCC8),
      ),
      useMaterial3: true,
      fontFamily: 'Sarabun',
      cardTheme: CardThemeData(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          elevation: 2,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(size: 28, color: Colors.white),
        actionsIconTheme: IconThemeData(size: 28, color: Colors.white),
      ),
    );
  }

  /// Get theme data based on mode
  static ThemeData getTheme(AppThemeMode mode) {
    switch (mode) {
      case AppThemeMode.warmCalming:
        return warmCalmingTheme();
      case AppThemeMode.brightCheerful:
        return brightCheerfulTheme();
      case AppThemeMode.classicProfessional:
        return classicProfessionalTheme();
      case AppThemeMode.earthyNatural:
        return earthyNaturalTheme();
    }
  }
}

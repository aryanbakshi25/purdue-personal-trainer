import 'package:flutter/material.dart';

/// Purdue-inspired Material 3 theme.
///
/// Primary: Purdue Gold (#CEB888)
/// Secondary: Purdue Black (#000000)
/// See: https://brand.purdue.edu/visual-identity/color.html
class AppTheme {
  AppTheme._();

  // Purdue brand colors
  static const Color _purdueGold = Color(0xFFCEB888);
  static const Color _purdueBlack = Color(0xFF000000);
  static const Color _purdueFieldGold = Color(0xFFDDB945);
  static const Color _purdueRailwayGray = Color(0xFF9D968D);

  static final ThemeData light = ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _purdueGold,
      primary: _purdueFieldGold,
      onPrimary: _purdueBlack,
      secondary: _purdueBlack,
      onSecondary: _purdueGold,
      surface: Colors.white,
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _purdueBlack,
      foregroundColor: _purdueGold,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _purdueGold.withAlpha(77),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _purdueFieldGold,
      foregroundColor: _purdueBlack,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );

  static final ThemeData dark = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: _purdueGold,
      primary: _purdueGold,
      onPrimary: _purdueBlack,
      secondary: _purdueRailwayGray,
      onSecondary: _purdueBlack,
      surface: const Color(0xFF121212),
      onSurface: Colors.white,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 0,
      backgroundColor: _purdueBlack,
      foregroundColor: _purdueGold,
    ),
    navigationBarTheme: NavigationBarThemeData(
      indicatorColor: _purdueGold.withAlpha(77),
      backgroundColor: _purdueBlack,
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: Colors.white),
      ),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: _purdueGold,
      foregroundColor: _purdueBlack,
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      filled: true,
      fillColor: const Color(0xFF1E1E1E),
    ),
    cardTheme: CardThemeData(
      elevation: 1,
      color: const Color(0xFF1E1E1E),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),
  );
}

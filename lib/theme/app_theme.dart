import 'package:flutter/material.dart';

class AppTheme {
  // Primary Colors
  static const Color purple = Color(0xFF8B5CF6);
  static const Color coral = Color(0xFFFF6B6B);
  static const Color turquoise = Color(0xFF2DD4BF);
  static const Color yellow = Color(0xFFFBBF24);
  
  // Background Colors
  static const Color darkBg = Color(0xFF1A1A2E);
  static const Color darkCard = Color(0xFF252542);
  static const Color darkCardLocked = Color(0xFF1E1E38);
  
  // Text Colors
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF9CA3AF);
  
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      colorScheme: const ColorScheme.dark(
        primary: purple,
        secondary: turquoise,
        surface: darkCard,
        onPrimary: textPrimary,
        onSecondary: textPrimary,
        onSurface: textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: darkBg,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      cardTheme: CardThemeData(
        color: darkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: darkCard,
        selectedItemColor: purple,
        unselectedItemColor: textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
    );
  }
  
  static Color getCategoryColor(String colorName) {
    switch (colorName) {
      case 'purple':
        return purple;
      case 'coral':
        return coral;
      case 'turquoise':
        return turquoise;
      case 'yellow':
        return yellow;
      default:
        return purple;
    }
  }
}

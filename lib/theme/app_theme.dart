import 'package:flutter/material.dart';

class AppTheme {
  static const primary = Color(0xFF0A84FF);
  static const secondary = Color(0xFF5E5CE6);
  static const amber = Color(0xFFFFD60A);
  static const green = Color(0xFF30D158);
  static const red = Color(0xFFFF453A);
  static const tertiary = Color(0xFFBF5AF2);

  static ThemeData get dark => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: const Color(0xFF0F1115),
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: Color(0xFF0F1115),
      surfaceTintColor: Colors.transparent,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF0F1115),
      indicatorColor: primary.withValues(alpha: 0.15),
    ),
  );
}

class LN {
  // Colors
  static const Color primary = Color(0xFF2563EB);
  static const Color secondary = Color(0xFF5E5CE6);
  static const Color surface = Color(0xFF0F1115);
  static const Color surface2 = Color(0xFF1B1F27);
  static const Color bg = Color(0xFF0F1115);
  static const Color label3 = Color(0xFF6B7280);
  static const Color label2 = Color(0xFF9CA3AF);
  static const Color success = Color(0xFF30D158);
  static const Color highlight = Color(0xFFFFD60A);
  static const Color amber = Color(0xFFFFD60A);
  static const Color red = Color(0xFFFF453A);
  static const Color green = Color(0xFF30D158);
  
  // Text styles
  static TextStyle get h2 => const TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
    color: Colors.white,
  );
  
  static TextStyle get h3 => const TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: Colors.white,
  );
  
  static TextStyle get body => const TextStyle(
    fontSize: 14,
    color: label2,
  );
  
  static TextStyle get bodySmall => const TextStyle(
    fontSize: 12,
    color: label3,
  );
  
  static TextStyle get label => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    color: primary,
    letterSpacing: 0.5,
  );

  static TextStyle get label1 => TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: label3,
  );

  static TextStyle get h1 => const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: Colors.white,
  );

  static TextStyle get info => TextStyle(
    fontSize: 14,
    color: label2,
  );

  // Border radius
  static BorderRadius r12 = BorderRadius.circular(12);
  static BorderRadius r16 = BorderRadius.circular(16);
  static BorderRadius r24 = BorderRadius.circular(24);

  // Shadow - function to create box shadows with optional color
  static List<BoxShadow> shadow([Color? color]) {
    return [
      BoxShadow(
        color: (color ?? Colors.black).withValues(alpha: 0.2),
        blurRadius: 10,
        offset: const Offset(0, 4),
      ),
    ];
  }

  // Helpers for Life Events
  static Color colorForEvent(dynamic type) {
    final typeStr = type.toString().split('.').last;
    switch (typeStr) {
      case 'move': return primary;
      case 'newJob': return secondary;
      case 'buyCar': return amber;
      case 'taxYear': return success;
      case 'study': return const Color(0xFFBF5AF2);
      case 'family': return red;
      default: return primary;
    }
  }

  static IconData iconForEvent(dynamic type) {
    final typeStr = type.toString().split('.').last;
    switch (typeStr) {
      case 'move': return Icons.home_rounded;
      case 'newJob': return Icons.work_rounded;
      case 'buyCar': return Icons.directions_car_rounded;
      case 'taxYear': return Icons.receipt_long_rounded;
      case 'study': return Icons.school_rounded;
      case 'family': return Icons.family_restroom_rounded;
      default: return Icons.event_rounded;
    }
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.light,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );

  static ThemeData get darkTheme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF2563EB),
      brightness: Brightness.dark,
    ),
    appBarTheme: const AppBarTheme(centerTitle: true),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: Color(0xFF2563EB),
      foregroundColor: Colors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    ),
  );
}
import 'package:flutter/material.dart';
import '../models/life_models.dart';

/// LifeNav Design System
class LN {
  static const Color primary   = Color(0xFF0A84FF);
  static const Color success   = Color(0xFF30D158);
  static const Color highlight = Color(0xFFFF9F0A);
  static const Color danger    = Color(0xFFFF453A);
  static const Color info      = Color(0xFF64D2FF);
  static const Color purple    = Color(0xFFBF5AF2);

  static const Color bg        = Color(0xFF000000);
  static const Color surface   = Color(0xFF1C1C1E);
  static const Color surface2  = Color(0xFF2C2C2E);
  static const Color surface3  = Color(0xFF3A3A3C);
  static const Color divider   = Color(0xFF38383A);

  static const Color label1    = Colors.white;
  static const Color label2    = Color(0xFFAEAEB2);
  static const Color label3    = Color(0xFF636366);

  static const TextStyle h1 = TextStyle(color: label1, fontSize: 34, fontWeight: FontWeight.w800, letterSpacing: -1.0);
  static const TextStyle h2 = TextStyle(color: label1, fontSize: 24, fontWeight: FontWeight.w700, letterSpacing: -0.5);
  static const TextStyle h3 = TextStyle(color: label1, fontSize: 20, fontWeight: FontWeight.w700);
  static const TextStyle body = TextStyle(color: label1, fontSize: 16, fontWeight: FontWeight.w400, height: 1.4);
  static const TextStyle bodySmall = TextStyle(color: label2, fontSize: 14, fontWeight: FontWeight.w400);
  static const TextStyle label = TextStyle(color: label3, fontSize: 12, fontWeight: FontWeight.w600, letterSpacing: 0.5);
  static const TextStyle captionBold = TextStyle(color: label3, fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8);

  static const double radiusVal = 24.0;
  static BorderRadius get r24 => BorderRadius.circular(radiusVal);
  static BorderRadius get r16 => BorderRadius.circular(16.0);

  static List<BoxShadow> shadow([Color? accent]) => [
    BoxShadow(color: (accent ?? Colors.black).withValues(alpha: accent != null ? 0.25 : 0.3), blurRadius: 20, offset: const Offset(0, 8)),
  ];

  static Color colorForEvent(LifeEventType t) {
    switch (t) {
      case LifeEventType.move:    return primary;
      case LifeEventType.newJob:  return success;
      case LifeEventType.buyCar:  return highlight;
      case LifeEventType.taxYear: return info;
      case LifeEventType.study:   return purple;
      case LifeEventType.family:  return const Color(0xFFFF375F);
    }
  }

  static IconData iconForEvent(LifeEventType t) {
    switch (t) {
      case LifeEventType.move:    return Icons.map_outlined;
      case LifeEventType.newJob:  return Icons.work_outline;
      case LifeEventType.buyCar:  return Icons.directions_car_outlined;
      case LifeEventType.taxYear: return Icons.calculate_outlined;
      case LifeEventType.study:   return Icons.school_outlined;
      case LifeEventType.family:  return Icons.favorite_outline;
    }
  }

  static const Color blue = primary;
  static const Color green = success;
  static const Color coral = danger;
  static const Color yellow = highlight;
  static const Color turquoise = info;
  static const Color textPrimary = label1;
  static const Color textSecondary = label2;
  static const Color textMuted = label3;
  static const Color bgTop = Color(0xFF141416);
  static const Color bgMid = Color(0xFF000000);
  static const Color bgBottom = Color(0xFF141416);

  static Color eventColor(LifeEventType t) => colorForEvent(t);
  static IconData eventIcon(LifeEventType? t) => t == null ? Icons.task_alt : iconForEvent(t);
  static Color priorityColor(TaskPriority p) => p == TaskPriority.urgent ? danger : p == TaskPriority.high ? highlight : primary;
  static CardColorConfig getCardConfig(String s) => const CardColorConfig(gradient: [primary, info], glow: primary, icon: Icons.description);

  static ThemeData get theme => ThemeData(
    useMaterial3: true, brightness: Brightness.dark, scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(primary: primary, secondary: highlight, surface: surface, onPrimary: Colors.white, onSurface: label1),
    appBarTheme: const AppBarTheme(backgroundColor: Colors.transparent, elevation: 0, centerTitle: false, titleTextStyle: h2),
  );
}

class LP {
  static const primary = LN.primary;
  static const success = LN.success;
  static const attention = LN.highlight;
  static const danger = LN.danger;
  static const purple = LN.purple;
  static const bg = LN.bg;
  static const surface = LN.surface;
  static const surface2 = LN.surface2;
  static const surface3 = LN.surface3;
  static const label1 = LN.label1;
  static const label2 = LN.label2;
  static const label3 = LN.label3;
  static const divider = LN.divider;
  static const captionBold = LN.captionBold;
  static final body = LN.body;
  static eventColor(LifeEventType t) => LN.eventColor(t);
  static eventIcon(LifeEventType? t) => LN.eventIcon(t);
  static priorityColor(TaskPriority p) => LN.priorityColor(p);
  static shadow([Color? c]) => LN.shadow(c);
  static final theme = LN.theme;
}

abstract class AppTheme {
  static const Color primary = LN.primary;
  static const Color success = LN.success;
  static const Color attention = LN.highlight;
  static const Color danger = LN.danger;
  static const Color purple = LN.purple;
  static const Color blue = LN.primary;
  static const Color green = LN.success;
  static const Color coral = LN.danger;
  static const Color yellow = LN.highlight;
  static const Color turquoise = LN.info;
  static const Color textPrimary = LN.label1;
  static const Color textSecondary = LN.label2;
  static const Color textMuted = LN.label3;
  static const Color bgTop = LN.bgTop;
  static const Color bgMid = LN.bgMid;
  static const Color bgBottom = LN.bgBottom;
  static CardColorConfig getCardConfig(String s) => LN.getCardConfig(s);
}

class CardColorConfig {
  final List<Color> gradient; final Color glow; final IconData icon;
  const CardColorConfig({required this.gradient, required this.glow, required this.icon});
}

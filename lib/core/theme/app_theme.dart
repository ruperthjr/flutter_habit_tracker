import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const Color bg        = Color(0xFF111827);
  static const Color surface   = Color(0xFF1A2537);
  static const Color card      = Color(0xFF1E2D40);
  static const Color cardHover = Color(0xFF243650);
  static const Color accent    = Color(0xFF4A9EFF);
  static const Color green     = Color(0xFF3DD68C);
  static const Color orange    = Color(0xFFFF6B35);
  static const Color purple    = Color(0xFFB06EFF);
  static const Color teal      = Color(0xFF00D4C8);
  static const Color gold      = Color(0xFFFFD166);
  static const Color pink      = Color(0xFFFF6B9D);
  static const Color textHigh  = Color(0xFFEFF6FF);
  static const Color textMid   = Color(0xFF7A98B8);
  static const Color textLow   = Color(0xFF3D5A73);
  static const Color divider   = Color(0xFF1E3248);

  static const List<Color> habitColors = [
    Color(0xFF4A9EFF), Color(0xFF3DD68C), Color(0xFFFF6B35),
    Color(0xFFB06EFF), Color(0xFFFFD166), Color(0xFF00D4C8),
    Color(0xFFFF6B9D), Color(0xFFFF8C42), Color(0xFF6BCB77),
    Color(0xFFFF595E),
  ];

  static const List<String> habitIcons = [
    '💧','🏃','🦷','📚','🧘','💊','🥗','😴','✍️','🎯',
    '🏋️','🎸','🧹','💻','🌿','☕','🚴','🫁','🧠','❤️',
  ];

  static ThemeData dark() => ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: bg,
    colorScheme: const ColorScheme.dark(
      primary: accent, secondary: green,
      surface: surface,
    ),
    cardColor: card,
    textTheme: const TextTheme(
      displaySmall: TextStyle(color: textHigh, fontWeight: FontWeight.bold, fontSize: 26),
      headlineMedium: TextStyle(color: textHigh, fontWeight: FontWeight.bold, fontSize: 22),
      headlineSmall: TextStyle(color: textHigh, fontWeight: FontWeight.w600, fontSize: 18),
      titleLarge: TextStyle(color: textHigh, fontWeight: FontWeight.w600, fontSize: 16),
      titleMedium: TextStyle(color: textMid, fontSize: 14),
      bodyLarge: TextStyle(color: textHigh, fontSize: 15),
      bodyMedium: TextStyle(color: textMid, fontSize: 13),
      labelLarge: TextStyle(color: textHigh, fontWeight: FontWeight.w600),
    ),
    useMaterial3: true,
  );
}
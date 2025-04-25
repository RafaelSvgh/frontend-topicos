import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color.fromARGB(255, 12, 12, 12);
  static const Color secondary = Color.fromARGB(255, 45, 45, 45);

  // Colores claros
  static const Color backgroundLight = Color(0xFFFFFFFF);
  static const Color textPrimaryLight = Color(0xFF000000);
  static const Color textSecondaryLight = Color(0xFF666666);

  // Colores oscuros
  static const Color backgroundDark = Color(0xFF070707);
  static const Color secondaryColorDark = Color(0xFF1e1e1e);
  static const Color textPrimaryDark = Color(0xFFfbfbfb);

  // Swatch
  static const MaterialColor primarySwatch = MaterialColor(
    0xFF0066FF,
    <int, Color>{
      50: Color(0xFFE0F0FF),
      100: Color(0xFFB3D9FF),
      200: Color(0xFF80C1FF),
      300: Color(0xFF4DA9FF),
      400: Color(0xFF2695FF),
      500: Color(0xFF0066FF),
      600: Color(0xFF005CE6),
      700: Color(0xFF0052CC),
      800: Color(0xFF0047B3),
      900: Color(0xFF003380),
    },
  );
}

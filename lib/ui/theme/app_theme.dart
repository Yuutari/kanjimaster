import 'package:flutter/material.dart';

/// Централизованная тема приложения KanjiMaster.
class AppTheme {
  // Основные цвета
  static const Color primary = Color(0xFF9C8CFF);
  static const Color primaryDark = Color(0xFF27273F);
  static const Color background = Color(0xFFF7F5FF);
  static const Color surface = Colors.white;
  static const Color success = Color(0xFF2E8B57);
  static const Color successLight = Color(0xFFE5F8ED);
  static const Color error = Color(0xFFE57373);
  static const Color errorLight = Color(0xFFFFE5E5);
  static const Color selectedTab = Color(0xFFEAE5FF);

  static ThemeData get lightTheme => ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        scaffoldBackgroundColor: background,
        fontFamily: 'Roboto',
      );
}

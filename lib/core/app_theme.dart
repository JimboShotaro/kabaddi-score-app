import 'package:flutter/material.dart';

/// アプリのテーマ設定
class AppTheme {
  static const Color primaryColor = Color(0xFF1E88E5);
  static const Color secondaryColor = Color(0xFFFF6F00);
  
  static const Color teamAColor = Color(0xFFE53935); // レッド
  static const Color teamBColor = Color(0xFF1E88E5); // ブルー
  
  static const Color courtColor = Color(0xFF4CAF50);
  static const Color lineColor = Colors.white;
  
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFE53935);
  
  static ThemeData get theme => ThemeData(
    colorScheme: ColorScheme.fromSeed(
      seedColor: primaryColor,
      brightness: Brightness.light,
    ),
    useMaterial3: true,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      elevation: 2,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    ),
    cardTheme: const CardThemeData(
      elevation: 2,
      margin: EdgeInsets.all(8),
    ),
  );
}

/// アプリの定数
class AppConstants {
  static const String appName = 'カバディスコア';
  static const String version = '1.0.0';
}

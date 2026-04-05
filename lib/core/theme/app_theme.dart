import 'package:agu_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

/// Uygulama yalnızca açık tema kullanır (sistem karanlık modu yok sayılır).
class AppTheme {
  static ThemeData light() {
    return ThemeData(
      brightness: Brightness.light,
      useMaterial3: true,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
      ),
      scaffoldBackgroundColor: AppColors.surfaceLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceLight,
        foregroundColor: AppColors.textLight,
        centerTitle: true,
      ),
    );
  }
}

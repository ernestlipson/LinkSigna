import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF9E1068);
  static const Color secondary = Color(0xFFFCF8F8);
  static const Color alternate = Color(0xFFD9D9D9);
  static const Color text = Color(0xFF374151);
  static const Color icon = Color(0xFF292D32);
}

class AppTheme {
  static ThemeData light() {
    final base = ThemeData.light();
    return base.copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.secondary,
      hintColor: AppColors.secondary,
      textTheme: base.textTheme.apply(
        fontFamily: 'WorkSans',
        bodyColor: AppColors.text,
        displayColor: AppColors.text,
      ),
      appBarTheme: const AppBarTheme(
        color: AppColors.secondary,
        iconTheme: IconThemeData(color: AppColors.primary),
        elevation: 0,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        surface: AppColors.alternate,
      ),
    );
  }
}

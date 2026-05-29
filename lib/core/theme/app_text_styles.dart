import 'package:flutter/material.dart';
import 'package:skill_swap/core/theme/app_colors.dart';

// Central text style values used by the app theme.
class AppTextStyles {
  const AppTextStyles._();

  static const headlineLarge = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const headlineMedium = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const titleLarge = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w800,
    color: AppColors.textDark,
  );

  static const bodyLarge = TextStyle(fontSize: 15, color: AppColors.textDark);

  static const bodyMedium = TextStyle(fontSize: 14, color: AppColors.textDark);

  static const labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    color: AppColors.textDark,
  );
}

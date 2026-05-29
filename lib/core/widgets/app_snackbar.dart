import 'package:flutter/material.dart';
import 'package:skill_swap/core/theme/app_colors.dart';

// Small helper for showing consistent success and error messages.
void showAuthMessage(
  BuildContext context,
  String message, {
  bool isError = false,
}) {
  final cleanMessage = message.replaceFirst('Exception: ', '');

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(cleanMessage),
      backgroundColor: isError ? AppColors.danger : AppColors.primaryGreen,
    ),
  );
}

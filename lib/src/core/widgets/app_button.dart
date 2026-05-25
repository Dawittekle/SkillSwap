import 'package:flutter/material.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';

enum AppButtonVariant { primary, secondary, ghost }

class AppButton extends StatelessWidget {
  const AppButton({
    required this.label,
    required this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expand = true,
    super.key,
  });

  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expand;

  @override
  Widget build(BuildContext context) {
    final button = switch (variant) {
      AppButtonVariant.primary => FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primaryGreen,
          foregroundColor: AppColors.cardWhite,
        ),
        child: _ButtonContent(label: label, icon: icon),
      ),
      AppButtonVariant.secondary => OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryDark,
          side: const BorderSide(color: AppColors.primaryGreen, width: 1.3),
        ),
        child: _ButtonContent(label: label, icon: icon),
      ),
      AppButtonVariant.ghost => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(foregroundColor: AppColors.primaryDark),
        child: _ButtonContent(label: label, icon: icon),
      ),
    };

    final themedButton = ButtonTheme(
      minWidth: expand ? double.infinity : 0,
      child: button,
    );

    return SizedBox(
      width: expand ? double.infinity : null,
      height: variant == AppButtonVariant.ghost ? 42 : 48,
      child: themedButton,
    );
  }
}

class _ButtonContent extends StatelessWidget {
  const _ButtonContent({required this.label, this.icon});

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    if (icon == null) {
      return Text(label, overflow: TextOverflow.ellipsis);
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 18),
        const SizedBox(width: 8),
        Flexible(child: Text(label, overflow: TextOverflow.ellipsis)),
      ],
    );
  }
}

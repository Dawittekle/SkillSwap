import 'package:flutter/material.dart';
import 'package:skill_swap/routing/app_routes.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';

class RequestSentPage extends StatelessWidget {
  const RequestSentPage({this.requestId = '', super.key});

  final String requestId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Request Sent')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 620),
                child: AppCard(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 58,
                        height: 58,
                        decoration: BoxDecoration(
                          color: AppColors.tealTint,
                          borderRadius: BorderRadius.circular(18),
                        ),
                        child: const Icon(
                          Icons.check_circle_outline,
                          color: AppColors.primaryDark,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Swap request sent',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'You can track this request from My Swaps.',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: AppColors.textGray,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 24),
                      AppButton(
                        label: 'Back to SkillSwap',
                        icon: Icons.home_outlined,
                        onPressed: () => Navigator.of(
                          context,
                        ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false),
                      ),
                      const SizedBox(height: 12),
                      AppButton(
                        label: 'Done',
                        icon: Icons.check,
                        variant: AppButtonVariant.secondary,
                        onPressed: () => Navigator.of(context).pop(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

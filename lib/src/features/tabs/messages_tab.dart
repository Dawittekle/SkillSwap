import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';

class MessagesTab extends StatelessWidget {
  const MessagesTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    const conversations = [
      (
        'Hana Tadesse',
        'I can share my Figma file before the session.',
        '2 min',
      ),
      ('Selamawit Kebede', 'Friday works for Python practice.', '1 hr'),
      ('Marcus Bekele', 'Bring your calculus questions.', 'Yesterday'),
    ];

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          Text('Messages', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          for (final item in conversations) ...[
            AppCard(
              padding: const EdgeInsets.all(16),
              child: InkWell(
                onTap: () => Navigator.of(context).pushNamed(AppRoutes.chat),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: AppColors.tealTint,
                      child: Text(item.$1[0]),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.$1, style: textTheme.titleMedium),
                          const SizedBox(height: 4),
                          Text(
                            item.$2,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: textTheme.bodyMedium?.copyWith(
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(item.$3, style: textTheme.labelMedium),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}

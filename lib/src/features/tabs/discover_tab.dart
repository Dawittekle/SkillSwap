import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/data/mock/mock_skills.dart';

class DiscoverTab extends StatelessWidget {
  const DiscoverTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          Text('Discover Skills', style: textTheme.headlineLarge),
          const SizedBox(height: 16),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search for Python, Guitar, French...',
            ),
          ),
          const SizedBox(height: 20),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkillChip(label: 'Academic', selected: true),
              SkillChip(label: 'Tech'),
              SkillChip(label: 'Creative'),
              SkillChip(label: 'Language'),
            ],
          ),
          const SizedBox(height: 22),
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(value: 'offered', label: Text('Skills Offered')),
              ButtonSegment(value: 'wanted', label: Text('Skills Wanted')),
            ],
            selected: const {'offered'},
            onSelectionChanged: (_) {},
          ),
          const SizedBox(height: 20),
          for (final skill in mockSkills) ...[
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const CircleAvatar(
                        backgroundColor: AppColors.tealTint,
                        child: Icon(
                          Icons.school_outlined,
                          color: AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(skill.title, style: textTheme.titleLarge),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      StatusChip(
                        label: skill.category,
                        color: AppColors.primaryGreen,
                      ),
                      StatusChip(
                        label: skill.level.name.toUpperCase(),
                        color: AppColors.warning,
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text(skill.description, style: textTheme.bodyLarge),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: AppButton(
                          label: 'Connect',
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.requestSwap),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: AppButton(
                          label: 'View Profile',
                          variant: AppButtonVariant.secondary,
                          onPressed: () => Navigator.of(
                            context,
                          ).pushNamed(AppRoutes.profileSetup),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

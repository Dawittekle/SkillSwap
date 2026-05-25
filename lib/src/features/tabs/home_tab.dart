import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/data/mock/mock_students.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Row(
            children: [
              const CircleAvatar(
                backgroundColor: AppColors.tealTint,
                child: Icon(Icons.person, color: AppColors.primaryDark),
              ),
              const SizedBox(width: 12),
              Text(
                'SkillSwap',
                style: textTheme.headlineMedium?.copyWith(
                  color: AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications_none),
                tooltip: 'Notifications',
              ),
            ],
          ),
          const SizedBox(height: 26),
          Text('Hi, Dawit', style: textTheme.headlineMedium),
          const SizedBox(height: 14),
          const TextField(
            decoration: InputDecoration(
              prefixIcon: Icon(Icons.search),
              hintText: 'Search skills or students',
            ),
          ),
          const SizedBox(height: 24),
          AppCard(
            backgroundColor: AppColors.primaryGreen,
            borderColor: AppColors.primaryGreen,
            child: Column(
              children: [
                Text(
                  'You have 3 new potential swaps',
                  textAlign: TextAlign.center,
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.cardWhite,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Students whose needs match what you teach are ready to connect.',
                  textAlign: TextAlign.center,
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.cardWhite,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton(
                  onPressed: () {},
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.cardWhite,
                    foregroundColor: AppColors.primaryDark,
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                  ),
                  child: const Text('View matches'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 26),
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
          const SizedBox(height: 28),
          Row(
            children: [
              Text('Best matches for you', style: textTheme.titleLarge),
              const Spacer(),
              TextButton(onPressed: () {}, child: const Text('See all')),
            ],
          ),
          const SizedBox(height: 12),
          for (final student in mockStudents.take(2)) ...[
            SkillMatchCard(
              name: student.name,
              school: student.school,
              teaches: student.teaches.first,
              wants: student.wantsToLearn.first,
              matchPercent: student.matchPercent,
              onRequest: () =>
                  Navigator.of(context).pushNamed(AppRoutes.requestSwap),
            ),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

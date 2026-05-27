import 'package:flutter/material.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          Text('My Profile', style: textTheme.headlineLarge),
          const SizedBox(height: 18),
          AppCard(
            child: Column(
              children: [
                const CircleAvatar(
                  radius: 38,
                  backgroundColor: AppColors.tealTint,
                  child: Icon(
                    Icons.person,
                    color: AppColors.primaryDark,
                    size: 34,
                  ),
                ),
                const SizedBox(height: 12),
                Text('Dawit Abraham', style: textTheme.titleLarge),
                Text(
                  'Computer Science - 3rd Year',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 18),
                const Wrap(
                  alignment: WrapAlignment.center,
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: '4.9 Rating',
                      color: AppColors.warning,
                      icon: Icons.star,
                    ),
                    StatusChip(
                      label: 'Available',
                      color: AppColors.success,
                      icon: Icons.check_circle_outline,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Text('I can teach', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkillChip(label: 'Python', icon: Icons.code),
              SkillChip(label: 'Git Basics', icon: Icons.merge_type),
              SkillChip(label: 'Study Planning', icon: Icons.calendar_month),
            ],
          ),
          const SizedBox(height: 22),
          Text('I want to learn', style: textTheme.titleLarge),
          const SizedBox(height: 10),
          const Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              SkillChip(label: 'UI Design'),
              SkillChip(label: 'Public Speaking'),
              SkillChip(label: 'Guitar'),
            ],
          ),
          const SizedBox(height: 26),
          AppButton(
            label: 'Edit Profile Setup',
            icon: Icons.edit_outlined,
            onPressed: () => Navigator.of(context).pushNamed(
              AppRoutes.profileSetup,
              arguments: AuthService().currentUser?.uid ?? '',
            ),
          ),
          const SizedBox(height: 12),
          AppButton(
            label: 'Logout',
            icon: Icons.logout,
            variant: AppButtonVariant.secondary,
            onPressed: () async {
              await AuthService().signOut();
              if (!context.mounted) return;
              Navigator.of(
                context,
              ).pushNamedAndRemoveUntil(AppRoutes.home, (_) => false);
            },
          ),
        ],
      ),
    );
  }
}

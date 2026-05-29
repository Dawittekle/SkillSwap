import 'package:flutter/material.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';
import 'package:skill_swap/demo/skill_card_data.dart';
import 'package:skill_swap/demo/student_card_data.dart';

class SkillCard extends StatelessWidget {
  const SkillCard({
    required this.skill,
    required this.owner,
    required this.onConnect,
    required this.onViewDetails,
    this.matchLabel,
    this.matchScore,
    super.key,
  });

  final SkillCardData skill;
  final Student owner;
  final VoidCallback onConnect;
  final VoidCallback onViewDetails;
  final String? matchLabel;
  final int? matchScore;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 24,
                backgroundColor: AppColors.tealTint,
                child: Text(
                  owner.name.characters.first,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      owner.name,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: textTheme.titleMedium,
                    ),
                    Text(
                      '${owner.rating.toStringAsFixed(1)} (${owner.reviewCount} reviews)',
                      style: textTheme.labelMedium?.copyWith(
                        color: AppColors.primaryDark,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onViewDetails,
                icon: const Icon(Icons.more_vert),
                tooltip: 'Skill details',
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Icon(
                _categoryIcon(skill.category),
                color: AppColors.primaryGreen,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  skill.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: textTheme.titleLarge,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              StatusChip(
                label: _levelLabel(skill.level),
                color: AppColors.warning,
              ),
              StatusChip(
                label: skill.category.toUpperCase(),
                color: AppColors.primaryGreen,
              ),
              StatusChip(label: skill.duration, color: AppColors.textGray),
              if (matchLabel != null && matchScore != null)
                StatusChip(
                  label: '$matchScore% $matchLabel',
                  color: AppColors.accentGold,
                  icon: Icons.auto_awesome,
                ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            skill.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge,
          ),
          const SizedBox(height: 16),
          const Divider(height: 1, color: AppColors.border),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: AppButton(label: 'Connect', onPressed: onConnect),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: 'Details',
                  variant: AppButtonVariant.secondary,
                  onPressed: onViewDetails,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

String levelLabel(SkillCardLevel level) => _levelLabel(level);

IconData categoryIcon(String category) => _categoryIcon(category);

String _levelLabel(SkillCardLevel level) {
  return switch (level) {
    SkillCardLevel.beginner => 'BEGINNER',
    SkillCardLevel.intermediate => 'INTERMEDIATE',
    SkillCardLevel.advanced => 'ADVANCED',
  };
}

IconData _categoryIcon(String category) {
  return switch (category.toLowerCase()) {
    'tech' => Icons.code,
    'creative' => Icons.brush_outlined,
    'language' => Icons.translate,
    'music' => Icons.music_note,
    _ => Icons.school_outlined,
  };
}

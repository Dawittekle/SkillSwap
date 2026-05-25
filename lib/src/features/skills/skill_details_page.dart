import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/core/widgets/skill_card.dart';
import 'package:skill_swap/src/data/mock/mock_skills.dart';
import 'package:skill_swap/src/data/mock/mock_students.dart';
import 'package:skill_swap/src/data/models/skill.dart';
import 'package:skill_swap/src/data/models/student.dart';

class SkillDetailsPage extends StatelessWidget {
  const SkillDetailsPage({required this.skillId, super.key});

  final String skillId;

  @override
  Widget build(BuildContext context) {
    final skill = _findSkill(skillId);
    final owner = _findOwner(skill.ownerId);
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Skill Details')),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
          children: [
            Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 760),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppCard(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                width: 54,
                                height: 54,
                                decoration: BoxDecoration(
                                  color: AppColors.tealTint,
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(
                                  categoryIcon(skill.category),
                                  color: AppColors.primaryDark,
                                ),
                              ),
                              const SizedBox(width: 14),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      skill.title,
                                      style: textTheme.headlineMedium,
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      'Offered by ${owner.name}',
                                      style: textTheme.bodyMedium?.copyWith(
                                        color: AppColors.textGray,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              StatusChip(
                                label: levelLabel(skill.level),
                                color: AppColors.warning,
                              ),
                              StatusChip(
                                label: skill.category.toUpperCase(),
                                color: AppColors.primaryGreen,
                              ),
                              StatusChip(
                                label: skill.duration,
                                color: AppColors.textGray,
                              ),
                            ],
                          ),
                          const SizedBox(height: 18),
                          Text(skill.description, style: textTheme.bodyLarge),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    _OwnerCard(owner: owner, skill: skill),
                    const SizedBox(height: 18),
                    _DetailsSection(
                      title: 'What you will practice',
                      children: [
                        for (final outcome in skill.outcomes)
                          _DetailBullet(label: outcome),
                      ],
                    ),
                    const SizedBox(height: 18),
                    _DetailsSection(
                      title: 'Session format',
                      children: [
                        _DetailRow(
                          icon: Icons.schedule,
                          label: 'Duration',
                          value: skill.duration,
                        ),
                        _DetailRow(
                          icon: Icons.place_outlined,
                          label: 'Format',
                          value: skill.meetingFormat,
                        ),
                        _DetailRow(
                          icon: Icons.sell_outlined,
                          label: 'Tags',
                          value: skill.tags.join(', '),
                        ),
                      ],
                    ),
                    const SizedBox(height: 22),
                    AppButton(
                      label: 'Request Swap',
                      icon: Icons.swap_horiz,
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(AppRoutes.requestSwap),
                    ),
                    const SizedBox(height: 12),
                    AppButton(
                      label: 'Message ${owner.name.split(' ').first}',
                      icon: Icons.chat_bubble_outline,
                      variant: AppButtonVariant.secondary,
                      onPressed: () =>
                          Navigator.of(context).pushNamed(AppRoutes.chat),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.owner, required this.skill});

  final Student owner;
  final Skill skill;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.tealTint,
            child: Text(
              owner.name.characters.first,
              style: const TextStyle(
                color: AppColors.primaryDark,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(owner.name, style: textTheme.titleLarge),
                const SizedBox(height: 2),
                Text(
                  '${owner.school} - ${owner.year}',
                  style: textTheme.bodyMedium?.copyWith(
                    color: AppColors.textGray,
                  ),
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    StatusChip(
                      label: '${owner.rating.toStringAsFixed(1)} rating',
                      color: AppColors.warning,
                      icon: Icons.star_border_rounded,
                    ),
                    StatusChip(
                      label: '${owner.reviewCount} reviews',
                      color: AppColors.primaryGreen,
                    ),
                  ],
                ),
              ],
            ),
          ),
          Icon(categoryIcon(skill.category), color: AppColors.primaryGreen),
        ],
      ),
    );
  }
}

class _DetailsSection extends StatelessWidget {
  const _DetailsSection({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _DetailBullet extends StatelessWidget {
  const _DetailBullet({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: AppColors.success,
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: Theme.of(context).textTheme.labelMedium),
                const SizedBox(height: 2),
                Text(value, style: Theme.of(context).textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Skill _findSkill(String id) {
  return mockSkills.firstWhere(
    (skill) => skill.id == id,
    orElse: () => mockSkills.first,
  );
}

Student _findOwner(String ownerId) {
  return mockStudents.firstWhere(
    (student) => student.id == ownerId,
    orElse: () => mockStudents.first,
  );
}

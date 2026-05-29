import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/routing/app_routes.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_button.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';
import 'package:skill_swap/features/discover/widgets/skill_card.dart';
import 'package:skill_swap/features/discover/widgets/skill_ui_adapters.dart';

class SkillDetailsPage extends StatefulWidget {
  const SkillDetailsPage({
    required this.skillId,
    this.skill,
    super.key,
    this.skillRepository,
    this.userRepository,
  });

  final String skillId;
  final firestore_skill.Skill? skill;
  final SkillRepository? skillRepository;
  final UserRepository? userRepository;

  @override
  State<SkillDetailsPage> createState() => _SkillDetailsPageState();
}

class _SkillDetailsPageState extends State<SkillDetailsPage> {
  SkillRepository get _skillRepository =>
      widget.skillRepository ?? SkillRepository();
  UserRepository get _userRepository =>
      widget.userRepository ?? UserRepository();

  late final Future<_SkillDetailsData?> _detailsFuture = _loadDetails();

  Future<_SkillDetailsData?> _loadDetails() async {
    final selectedSkill =
        widget.skill ??
        (widget.skillId.isNotEmpty
            ? await _skillRepository.getSkill(widget.skillId)
            : null);

    if (selectedSkill == null) return null;

    final teacher = await _userRepository.getUser(selectedSkill.ownerId);
    return _SkillDetailsData(skill: selectedSkill, teacher: teacher);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Skill Details')),
      body: SafeArea(
        child: FutureBuilder<_SkillDetailsData?>(
          future: _detailsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (snapshot.hasError) {
              return _DetailsMessage(message: snapshot.error.toString());
            }

            final details = snapshot.data;
            if (details == null) {
              return const _DetailsMessage(message: 'Skill not found.');
            }

            return _SkillDetailsContent(
              skill: details.skill,
              teacher: details.teacher,
            );
          },
        ),
      ),
    );
  }
}

class _SkillDetailsContent extends StatelessWidget {
  const _SkillDetailsContent({required this.skill, required this.teacher});

  final firestore_skill.Skill skill;
  final AppUser? teacher;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final uiSkill = uiSkillFromFirestore(skill);
    final teacherName = teacher?.fullName.isNotEmpty == true
        ? teacher!.fullName
        : skill.ownerName;
    final university = teacher?.university.isNotEmpty == true
        ? teacher!.university
        : skill.university;

    return ListView(
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
                                  'Offered by $teacherName',
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
                            label: levelLabel(uiSkill.level),
                            color: AppColors.warning,
                          ),
                          StatusChip(
                            label: skill.category.toUpperCase(),
                            color: AppColors.primaryGreen,
                          ),
                          StatusChip(
                            label: skill.type.toUpperCase(),
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
                _OwnerCard(skill: skill, teacher: teacher),
                const SizedBox(height: 18),
                _DetailsSection(
                  title: 'Skill information',
                  children: [
                    _DetailRow(
                      icon: Icons.category_outlined,
                      label: 'Category',
                      value: skill.category,
                    ),
                    _DetailRow(
                      icon: Icons.trending_up,
                      label: 'Level',
                      value: skill.level,
                    ),
                    _DetailRow(
                      icon: Icons.school_outlined,
                      label: 'University',
                      value: university.isEmpty ? 'Not shared yet' : university,
                    ),
                    _DetailRow(
                      icon: Icons.swap_horiz,
                      label: 'Exchange for',
                      value: skill.exchangeFor.isEmpty
                          ? 'Open to suggestions'
                          : skill.exchangeFor,
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                AppButton(
                  label: 'Request Swap',
                  icon: Icons.swap_horiz,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.requestSwap,
                    arguments: RequestSwapArguments(
                      selectedSkill: skill,
                      teacherId: skill.ownerId,
                      teacherName: teacherName,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _OwnerCard extends StatelessWidget {
  const _OwnerCard({required this.skill, required this.teacher});

  final firestore_skill.Skill skill;
  final AppUser? teacher;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final owner = studentFromSkillOwner(skill, user: teacher);
    final avatarLabel = owner.name.isEmpty ? '?' : owner.name.characters.first;

    return AppCard(
      padding: const EdgeInsets.all(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => Navigator.of(
          context,
        ).pushNamed(AppRoutes.publicProfile, arguments: skill.ownerId),
        child: Row(
          children: [
            CircleAvatar(
              radius: 28,
              backgroundColor: AppColors.tealTint,
              backgroundImage: teacher?.photoUrl.isNotEmpty == true
                  ? NetworkImage(teacher!.photoUrl)
                  : null,
              child: teacher?.photoUrl.isNotEmpty == true
                  ? null
                  : Text(
                      avatarLabel,
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
                    [
                      owner.school,
                      owner.year,
                    ].where((item) => item.trim().isNotEmpty).join(' - '),
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
                        label: '${owner.reviewCount} swaps',
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

class _DetailsMessage extends StatelessWidget {
  const _DetailsMessage({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        AppCard(
          child: Text(message, style: Theme.of(context).textTheme.bodyLarge),
        ),
      ],
    );
  }
}

class _SkillDetailsData {
  const _SkillDetailsData({required this.skill, required this.teacher});

  final firestore_skill.Skill skill;
  final AppUser? teacher;
}

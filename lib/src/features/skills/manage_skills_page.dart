import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';
import 'package:skill_swap/src/features/skills/skill_form_page.dart';

class ManageSkillsPage extends StatelessWidget {
  const ManageSkillsPage({super.key, this.authService, this.skillRepository});

  final AuthService? authService;
  final SkillRepository? skillRepository;

  AuthService get _authService => authService ?? AuthService();
  SkillRepository get _skillRepository => skillRepository ?? SkillRepository();

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;

    return Scaffold(
      appBar: AppBar(title: const Text('Manage Skills')),
      body: SafeArea(
        child: currentUser == null
            ? const Center(child: Text('Please login to manage skills.'))
            : StreamBuilder<List<firestore_skill.Skill>>(
                stream: _skillRepository.watchCurrentUserSkills(
                  currentUser.uid,
                ),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: AppColors.primaryGreen,
                      ),
                    );
                  }

                  final skills = snapshot.data ?? [];
                  final offered = skills
                      .where((skill) => skill.type == 'offered')
                      .toList();
                  final wanted = skills
                      .where((skill) => skill.type == 'wanted')
                      .toList();

                  return ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    children: [
                      Center(
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 760),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      'Your skills',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.headlineMedium,
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: () => Navigator.of(
                                      context,
                                    ).pushNamed(AppRoutes.addSkill),
                                    icon: const Icon(Icons.add),
                                    tooltip: 'Add skill',
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              _SkillSection(
                                title: 'Skills I Teach',
                                skills: offered,
                                emptyText: 'No offered skills yet.',
                                skillRepository: _skillRepository,
                              ),
                              const SizedBox(height: 20),
                              _SkillSection(
                                title: 'Skills I Want to Learn',
                                skills: wanted,
                                emptyText: 'No wanted skills yet.',
                                skillRepository: _skillRepository,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
      ),
    );
  }
}

class _SkillSection extends StatelessWidget {
  const _SkillSection({
    required this.title,
    required this.skills,
    required this.emptyText,
    required this.skillRepository,
  });

  final String title;
  final List<firestore_skill.Skill> skills;
  final String emptyText;
  final SkillRepository skillRepository;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 10),
        if (skills.isEmpty)
          AppCard(
            child: Text(
              emptyText,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
            ),
          )
        else
          for (final skill in skills) ...[
            _ManageSkillCard(skill: skill, skillRepository: skillRepository),
            const SizedBox(height: 12),
          ],
      ],
    );
  }
}

class _ManageSkillCard extends StatefulWidget {
  const _ManageSkillCard({required this.skill, required this.skillRepository});

  final firestore_skill.Skill skill;
  final SkillRepository skillRepository;

  @override
  State<_ManageSkillCard> createState() => _ManageSkillCardState();
}

class _ManageSkillCardState extends State<_ManageSkillCard> {
  bool _isUpdating = false;

  Future<void> _toggleActive() async {
    setState(() => _isUpdating = true);
    try {
      await widget.skillRepository.updateSkill(widget.skill.id, {
        'isActive': !widget.skill.isActive,
      });
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  Future<void> _delete() async {
    setState(() => _isUpdating = true);
    try {
      await widget.skillRepository.deleteSkill(widget.skill.id);
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isUpdating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final skill = widget.skill;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  skill.title,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              StatusChip(
                label: skill.isActive ? 'Active' : 'Inactive',
                color: skill.isActive ? AppColors.success : AppColors.textGray,
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            '${skill.category} - ${skill.level}',
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: 12),
          Text(
            skill.description,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              AppButton(
                label: 'Edit',
                icon: Icons.edit_outlined,
                expand: false,
                variant: AppButtonVariant.secondary,
                onPressed: _isUpdating
                    ? null
                    : () => Navigator.of(context).pushNamed(
                        AppRoutes.editSkill,
                        arguments: SkillFormArguments(skill: skill),
                      ),
              ),
              AppButton(
                label: skill.isActive ? 'Deactivate' : 'Activate',
                icon: skill.isActive ? Icons.visibility_off : Icons.visibility,
                expand: false,
                variant: AppButtonVariant.secondary,
                onPressed: _isUpdating ? null : _toggleActive,
              ),
              AppButton(
                label: 'Delete',
                icon: Icons.delete_outline,
                expand: false,
                variant: AppButtonVariant.ghost,
                onPressed: _isUpdating ? null : _delete,
              ),
            ],
          ),
        ],
      ),
    );
  }
}

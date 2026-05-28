import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/app_user.dart';
import 'package:skill_swap/data/models/skill.dart' as firestore_skill;
import 'package:skill_swap/data/repositories/review_repository.dart';
import 'package:skill_swap/data/repositories/skill_repository.dart';
import 'package:skill_swap/data/repositories/user_repository.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/features/reviews/review_widgets.dart';

class PublicStudentProfilePage extends StatelessWidget {
  const PublicStudentProfilePage({
    required this.uid,
    super.key,
    this.userRepository,
    this.skillRepository,
    this.reviewRepository,
  });

  final String uid;
  final UserRepository? userRepository;
  final SkillRepository? skillRepository;
  final ReviewRepository? reviewRepository;

  @override
  Widget build(BuildContext context) {
    final users = userRepository ?? UserRepository();
    final skills = skillRepository ?? SkillRepository();
    final reviews = reviewRepository ?? ReviewRepository();

    return Scaffold(
      appBar: AppBar(title: const Text('Student Profile')),
      body: SafeArea(
        child: StreamBuilder<AppUser?>(
          stream: users.watchUser(uid),
          builder: (context, userSnapshot) {
            if (userSnapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(color: AppColors.primaryGreen),
              );
            }

            if (userSnapshot.hasError) {
              return _ProfileMessage(message: userSnapshot.error.toString());
            }

            final user = userSnapshot.data;
            if (user == null) {
              return const _ProfileMessage(
                message: 'Student profile not found.',
              );
            }

            return StreamBuilder<List<firestore_skill.Skill>>(
              stream: skills.watchCurrentUserSkills(uid),
              builder: (context, skillSnapshot) {
                final studentSkills = skillSnapshot.data ?? [];
                final offered = studentSkills
                    .where((skill) => skill.type == 'offered' && skill.isActive)
                    .toList();
                final wanted = studentSkills
                    .where((skill) => skill.type == 'wanted' && skill.isActive)
                    .toList();

                return _PublicProfileContent(
                  user: user,
                  offered: offered,
                  wanted: wanted,
                  reviewRepository: reviews,
                  skillError: skillSnapshot.error,
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _PublicProfileContent extends StatelessWidget {
  const _PublicProfileContent({
    required this.user,
    required this.offered,
    required this.wanted,
    required this.reviewRepository,
    required this.skillError,
  });

  final AppUser user;
  final List<firestore_skill.Skill> offered;
  final List<firestore_skill.Skill> wanted;
  final ReviewRepository reviewRepository;
  final Object? skillError;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final subtitle = [
      if (user.department.isNotEmpty) user.department,
      if (user.year.isNotEmpty) user.year,
      if (user.university.isNotEmpty) user.university,
    ].join(' - ');

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
                  child: Column(
                    children: [
                      _PublicAvatar(photoUrl: user.photoUrl),
                      const SizedBox(height: 12),
                      Text(user.fullName, style: textTheme.titleLarge),
                      if (subtitle.isNotEmpty)
                        Text(
                          subtitle,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                      if (user.campus.isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Text(
                          user.campus,
                          style: textTheme.labelLarge?.copyWith(
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ],
                      if (user.bio.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          user.bio,
                          textAlign: TextAlign.center,
                          style: textTheme.bodyMedium,
                        ),
                      ],
                      const SizedBox(height: 18),
                      Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          StatusChip(
                            label: '${user.rating.toStringAsFixed(1)} Rating',
                            color: AppColors.warning,
                            icon: Icons.star,
                          ),
                          StatusChip(
                            label: '${user.completedSwaps} Swaps',
                            color: AppColors.primaryGreen,
                            icon: Icons.swap_horiz,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                if (skillError != null) ...[
                  const SizedBox(height: 18),
                  AppCard(
                    child: Text(
                      skillError.toString(),
                      style: textTheme.bodyMedium,
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _SkillSection(title: 'Skills they teach', skills: offered),
                const SizedBox(height: 22),
                _SkillSection(
                  title: 'Skills they want to learn',
                  skills: wanted,
                ),
                const SizedBox(height: 22),
                ReviewsSection(
                  userId: user.uid,
                  reviewRepository: reviewRepository,
                  title: 'Student Reviews',
                ),
                const SizedBox(height: 26),
                AppButton(
                  label: 'Message ${_firstName(user.fullName)}',
                  icon: Icons.chat_bubble_outline,
                  onPressed: () => Navigator.of(context).pushNamed(
                    AppRoutes.chat,
                    arguments: ChatArguments(
                      otherUserId: user.uid,
                      otherUserName: user.fullName,
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

class _SkillSection extends StatelessWidget {
  const _SkillSection({required this.title, required this.skills});

  final String title;
  final List<firestore_skill.Skill> skills;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 12),
          if (skills.isEmpty)
            Text(
              'No skills added yet.',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
            )
          else
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                for (final skill in skills) SkillChip(label: skill.title),
              ],
            ),
        ],
      ),
    );
  }
}

class _PublicAvatar extends StatelessWidget {
  const _PublicAvatar({required this.photoUrl});

  final String photoUrl;

  @override
  Widget build(BuildContext context) {
    if (photoUrl.isEmpty) {
      return const CircleAvatar(
        radius: 38,
        backgroundColor: AppColors.tealTint,
        child: Icon(Icons.person, color: AppColors.primaryDark, size: 34),
      );
    }

    return CircleAvatar(
      radius: 38,
      backgroundColor: AppColors.tealTint,
      backgroundImage: NetworkImage(photoUrl),
    );
  }
}

class _ProfileMessage extends StatelessWidget {
  const _ProfileMessage({required this.message});

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

String _firstName(String name) {
  final trimmedName = name.trim();
  if (trimmedName.isEmpty) return 'Student';

  return trimmedName.split(' ').first;
}

import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/data/mock/mock_home.dart';
import 'package:skill_swap/src/data/mock/mock_students.dart';
import 'package:skill_swap/src/data/models/student.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isWide = constraints.maxWidth >= 720;

          return ListView(
            padding: EdgeInsets.fromLTRB(
              isWide ? 32 : 16,
              12,
              isWide ? 32 : 16,
              96,
            ),
            children: [
              Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 920),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const _HomeHeader(),
                      const SizedBox(height: 26),
                      _Greeting(summary: mockHomeSummary),
                      const SizedBox(height: 16),
                      const _SearchField(),
                      const SizedBox(height: 24),
                      _MatchSummary(summary: mockHomeSummary),
                      const SizedBox(height: 24),
                      const _CategoryRail(),
                      const SizedBox(height: 28),
                      _SectionHeader(
                        title: 'Best matches for you',
                        actionLabel: 'See all',
                        onAction: () {},
                      ),
                      const SizedBox(height: 12),
                      _ResponsiveMatchGrid(
                        students: mockStudents.take(isWide ? 3 : 2).toList(),
                        isWide: isWide,
                      ),
                      const SizedBox(height: 28),
                      if (isWide)
                        const Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(child: _UpcomingSessionCard()),
                            SizedBox(width: 18),
                            Expanded(child: _RecentActivityList()),
                          ],
                        )
                      else ...[
                        Text(
                          'Upcoming session',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: 12),
                        const _UpcomingSessionCard(),
                        const SizedBox(height: 26),
                        const _RecentActivityList(),
                      ],
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class _HomeHeader extends StatelessWidget {
  const _HomeHeader();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Row(
      children: [
        const CircleAvatar(
          radius: 22,
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
    );
  }
}

class _Greeting extends StatelessWidget {
  const _Greeting({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Hi, ${summary.studentName}',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 6),
              Text(
                'Find a student who can learn from you and teach you something back.',
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        _MetricPill(
          value: summary.activeSwapCount.toString(),
          label: 'Active',
          color: AppColors.primaryGreen,
        ),
      ],
    );
  }
}

class _SearchField extends StatelessWidget {
  const _SearchField();

  @override
  Widget build(BuildContext context) {
    return TextField(
      textInputAction: TextInputAction.search,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.search),
        hintText: 'Search skills or students',
        suffixIcon: IconButton(
          onPressed: () {},
          icon: const Icon(Icons.tune),
          tooltip: 'Filters',
        ),
      ),
    );
  }
}

class _MatchSummary extends StatelessWidget {
  const _MatchSummary({required this.summary});

  final HomeSummary summary;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      backgroundColor: AppColors.primaryGreen,
      borderColor: AppColors.primaryGreen,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.cardWhite.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.accentGold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  'You have ${summary.potentialSwapCount} new potential swaps',
                  style: textTheme.titleLarge?.copyWith(
                    color: AppColors.cardWhite,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'These students match what you can teach and what you want to learn.',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.cardWhite),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton(
                onPressed: () {},
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.cardWhite,
                  foregroundColor: AppColors.primaryDark,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 22,
                    vertical: 12,
                  ),
                ),
                child: const Text('View matches'),
              ),
              _SummaryChip(
                label: '${summary.completedSessionCount} sessions completed',
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _CategoryRail extends StatelessWidget {
  const _CategoryRail();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (final category in mockSkillCategories) ...[
            SkillChip(
              label: category,
              selected: category == mockSkillCategories.first,
            ),
            const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _ResponsiveMatchGrid extends StatelessWidget {
  const _ResponsiveMatchGrid({required this.students, required this.isWide});

  final List<Student> students;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    if (!isWide) {
      return Column(
        children: [
          for (final student in students) ...[
            _HomeMatchCard(student: student),
            const SizedBox(height: 14),
          ],
        ],
      );
    }

    return GridView.builder(
      itemCount: students.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 14,
        mainAxisSpacing: 14,
        mainAxisExtent: 318,
      ),
      itemBuilder: (context, index) => _HomeMatchCard(student: students[index]),
    );
  }
}

class _HomeMatchCard extends StatelessWidget {
  const _HomeMatchCard({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: AppColors.tealTint,
                    child: Text(
                      student.name.characters.first,
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
                          student.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.titleMedium,
                        ),
                        Text(
                          student.school,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: textTheme.bodyMedium?.copyWith(
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Align(
                alignment: Alignment.centerLeft,
                child: StatusChip(
                  label: '${student.matchPercent}% Match',
                  color: AppColors.warning,
                  icon: Icons.star_border_rounded,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _SkillExchangePanel(student: student),
          const SizedBox(height: 16),
          AppButton(
            label: 'Request Swap',
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.requestSwap),
          ),
        ],
      ),
    );
  }
}

class _SkillExchangePanel extends StatelessWidget {
  const _SkillExchangePanel({required this.student});

  final Student student;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          Expanded(
            child: _SkillPair(
              label: 'Teaches',
              value: student.teaches.first,
              icon: Icons.school_outlined,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: _SkillPair(
              label: 'Wants',
              value: student.wantsToLearn.first,
              icon: Icons.code,
            ),
          ),
        ],
      ),
    );
  }
}

class _SkillPair extends StatelessWidget {
  const _SkillPair({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: AppColors.primaryDark,
            letterSpacing: 0.4,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Icon(icon, size: 16, color: AppColors.primaryGreen),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                value,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UpcomingSessionCard extends StatelessWidget {
  const _UpcomingSessionCard();

  @override
  Widget build(BuildContext context) {
    final session = mockUpcomingSession;
    final textTheme = Theme.of(context).textTheme;

    return AppCard(
      borderColor: AppColors.accentGold,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: AppColors.softGold,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(session.icon, color: AppColors.primaryDark),
              ),
              const Spacer(),
              StatusChip(
                label: session.dayLabel.toUpperCase(),
                color: AppColors.primaryGreen,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(session.title, style: textTheme.titleMedium),
          const SizedBox(height: 6),
          Text(
            '${session.partnerName} teaches ${session.skill}',
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: 14),
          _SessionDetail(icon: Icons.schedule, label: session.time),
          const SizedBox(height: 8),
          _SessionDetail(
            icon: Icons.videocam_outlined,
            label: session.location,
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'Session Details',
            variant: AppButtonVariant.secondary,
            onPressed: () {},
          ),
        ],
      ),
    );
  }
}

class _SessionDetail extends StatelessWidget {
  const _SessionDetail({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 17, color: AppColors.textDark),
        const SizedBox(width: 8),
        Expanded(
          child: Text(label, style: Theme.of(context).textTheme.bodyMedium),
        ),
      ],
    );
  }
}

class _RecentActivityList extends StatelessWidget {
  const _RecentActivityList();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Recent activity', style: textTheme.titleLarge),
        const SizedBox(height: 12),
        AppCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Column(
            children: [
              for (final activity in mockRecentActivities) ...[
                _ActivityTile(activity: activity),
                if (activity != mockRecentActivities.last)
                  const Divider(height: 1, color: AppColors.border),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _ActivityTile extends StatelessWidget {
  const _ActivityTile({required this.activity});

  final RecentActivity activity;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: activity.tint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(activity.icon, size: 20, color: AppColors.primaryDark),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.title,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 2),
                Text(
                  activity.subtitle,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onAction,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onAction;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(title, style: Theme.of(context).textTheme.titleLarge),
        ),
        TextButton(onPressed: onAction, child: Text(actionLabel)),
      ],
    );
  }
}

class _MetricPill extends StatelessWidget {
  const _MetricPill({
    required this.value,
    required this.label,
    required this.color,
  });

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(color: color),
          ),
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: color),
          ),
        ],
      ),
    );
  }
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: AppColors.cardWhite.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.cardWhite.withValues(alpha: 0.22)),
      ),
      child: Text(
        label,
        style: Theme.of(
          context,
        ).textTheme.labelLarge?.copyWith(color: AppColors.cardWhite),
      ),
    );
  }
}

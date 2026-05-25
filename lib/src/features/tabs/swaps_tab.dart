import 'package:flutter/material.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/data/mock/mock_students.dart';
import 'package:skill_swap/src/data/mock/mock_swaps.dart';
import 'package:skill_swap/src/data/models/swap_request.dart';

class SwapsTab extends StatelessWidget {
  const SwapsTab({super.key});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(16, 18, 16, 96),
        children: [
          Text('My Swaps', style: textTheme.headlineLarge),
          const SizedBox(height: 6),
          Text(
            'Track active, pending, and completed skill exchanges.',
            style: textTheme.bodyLarge?.copyWith(color: AppColors.textGray),
          ),
          const SizedBox(height: 18),
          AppButton(
            label: 'New Swap Request',
            icon: Icons.add,
            onPressed: () =>
                Navigator.of(context).pushNamed(AppRoutes.requestSwap),
          ),
          const SizedBox(height: 24),
          for (final swap in mockSwaps) ...[
            _SwapCard(swap: swap),
            const SizedBox(height: 14),
          ],
        ],
      ),
    );
  }
}

class _SwapCard extends StatelessWidget {
  const _SwapCard({required this.swap});

  final SwapRequest swap;

  @override
  Widget build(BuildContext context) {
    final student = mockStudents.firstWhere(
      (item) => item.id == swap.studentId,
    );
    final statusColor = switch (swap.status) {
      SwapStatus.pending => AppColors.warning,
      SwapStatus.accepted => AppColors.success,
      SwapStatus.completed => AppColors.primaryGreen,
      SwapStatus.declined => AppColors.danger,
    };

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: swap.status.name.toUpperCase(),
                color: statusColor,
              ),
              const Spacer(),
              Text(
                swap.sessionTime,
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              CircleAvatar(
                backgroundColor: AppColors.tealTint,
                child: Text(student.name[0]),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      student.name,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    Text(
                      '${student.school} - ${student.year}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _SwapSkillLine(
            label: 'They teach',
            value: swap.theyTeach,
            icon: Icons.north_east,
          ),
          const SizedBox(height: 10),
          _SwapSkillLine(
            label: 'You teach',
            value: swap.youTeach,
            icon: Icons.south_west,
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: AppButton(
                  label: swap.status == SwapStatus.pending
                      ? 'Accept'
                      : 'Message',
                  icon: swap.status == SwapStatus.pending
                      ? Icons.check
                      : Icons.mail_outline,
                  onPressed: () =>
                      Navigator.of(context).pushNamed(AppRoutes.chat),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: AppButton(
                  label: swap.status == SwapStatus.pending
                      ? 'Decline'
                      : 'Details',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {},
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SwapSkillLine extends StatelessWidget {
  const _SwapSkillLine({
    required this.label,
    required this.value,
    required this.icon,
  });

  final String label;
  final String value;
  final IconData icon;

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
          Icon(icon, color: AppColors.primaryGreen),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label.toUpperCase(),
                  style: Theme.of(context).textTheme.labelMedium,
                ),
                Text(value, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

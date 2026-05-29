import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/review.dart';
import 'package:skill_swap/data/repositories/review_repository.dart';
import 'package:skill_swap/core/theme/app_colors.dart';
import 'package:skill_swap/core/widgets/app_card.dart';
import 'package:skill_swap/core/widgets/app_chip.dart';

class ReviewsSection extends StatelessWidget {
  const ReviewsSection({
    required this.userId,
    required this.reviewRepository,
    this.title = 'Reviews',
    super.key,
  });

  final String userId;
  final ReviewRepository reviewRepository;
  final String title;

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<List<Review>>(
      stream: reviewRepository.watchReviewsForUser(userId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting &&
            !snapshot.hasData) {
          return const Center(
            child: Padding(
              padding: EdgeInsets.all(18),
              child: CircularProgressIndicator(color: AppColors.primaryGreen),
            ),
          );
        }

        if (snapshot.hasError) {
          return AppCard(
            child: Text(
              snapshot.error.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          );
        }

        final reviews = List<Review>.from(snapshot.data ?? const <Review>[])
          ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
        final average = _averageRating(reviews);

        return AppCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  StatusChip(
                    label: reviews.isEmpty
                        ? 'No rating'
                        : '${average.toStringAsFixed(1)} Avg',
                    color: AppColors.warning,
                    icon: Icons.star,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              if (reviews.isEmpty)
                Text(
                  'No reviews yet.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: AppColors.textGray),
                )
              else
                for (final review in reviews) ...[
                  _ReviewCard(review: review),
                  if (review != reviews.last) const SizedBox(height: 12),
                ],
            ],
          ),
        );
      },
    );
  }
}

class _ReviewCard extends StatelessWidget {
  const _ReviewCard({required this.review});

  final Review review;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.softBlue,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              StatusChip(
                label: review.rating.toStringAsFixed(1),
                color: AppColors.warning,
                icon: Icons.star,
              ),
              const SizedBox(width: 10),
              Text(
                _dateLabel(review.createdAt),
                style: Theme.of(context).textTheme.labelMedium,
              ),
            ],
          ),
          if (review.tags.isNotEmpty) ...[
            const SizedBox(height: 10),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final tag in review.tags)
                  StatusChip(label: tag, color: AppColors.primaryGreen),
              ],
            ),
          ],
          if (review.comment.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(review.comment, style: Theme.of(context).textTheme.bodyMedium),
          ],
        ],
      ),
    );
  }
}

double _averageRating(List<Review> reviews) {
  if (reviews.isEmpty) return 0;

  final total = reviews.fold<double>(0, (sum, review) => sum + review.rating);
  return total / reviews.length;
}

String _dateLabel(DateTime date) {
  return '${date.month}/${date.day}/${date.year}';
}

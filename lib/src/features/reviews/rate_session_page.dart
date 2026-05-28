import 'package:flutter/material.dart';
import 'package:skill_swap/data/models/review.dart';
import 'package:skill_swap/data/models/swap_request.dart';
import 'package:skill_swap/data/repositories/review_repository.dart';
import 'package:skill_swap/data/services/auth_service.dart';
import 'package:skill_swap/src/app.dart';
import 'package:skill_swap/src/core/theme/app_colors.dart';
import 'package:skill_swap/src/core/widgets/app_button.dart';
import 'package:skill_swap/src/core/widgets/app_card.dart';
import 'package:skill_swap/src/core/widgets/app_chip.dart';
import 'package:skill_swap/src/features/auth/auth_helpers.dart';

class RateSessionPage extends StatefulWidget {
  const RateSessionPage({
    required this.arguments,
    super.key,
    this.authService,
    this.reviewRepository,
  });

  final ReviewSessionArguments? arguments;
  final AuthService? authService;
  final ReviewRepository? reviewRepository;

  @override
  State<RateSessionPage> createState() => _RateSessionPageState();
}

class _RateSessionPageState extends State<RateSessionPage> {
  final _commentController = TextEditingController();
  final Set<String> _selectedTags = {};

  double _rating = 5;
  bool _isSaving = false;

  AuthService get _authService => widget.authService ?? AuthService();
  ReviewRepository get _reviewRepository =>
      widget.reviewRepository ?? ReviewRepository();

  static const _tags = ['Helpful', 'Clear', 'Prepared', 'Friendly', 'On time'];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _saveReview(SwapRequest request, String currentUserId) async {
    final revieweeId = request.fromUserId == currentUserId
        ? request.toUserId
        : request.fromUserId;

    setState(() => _isSaving = true);
    try {
      final hasReview = await _reviewRepository.hasReviewForSession(
        request.id,
        currentUserId,
      );
      if (hasReview) {
        throw Exception('You already reviewed this session.');
      }

      await _reviewRepository.createReview(
        Review(
          id: reviewDocumentId(request.id, currentUserId),
          sessionId: request.id,
          reviewerId: currentUserId,
          revieweeId: revieweeId,
          rating: _rating,
          tags: _selectedTags.toList(),
          comment: _commentController.text.trim(),
          createdAt: DateTime.now(),
        ),
      );

      if (!mounted) return;
      showAuthMessage(context, 'Review saved.');
      Navigator.of(context).pop();
    } catch (error) {
      if (!mounted) return;
      showAuthMessage(context, error.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentUser = _authService.currentUser;
    final request = widget.arguments?.request;

    return Scaffold(
      appBar: AppBar(title: const Text('Rate Session')),
      body: SafeArea(
        child: Builder(
          builder: (context) {
            if (currentUser == null) {
              return const _RateMessage(
                message: 'Please login before reviewing a session.',
              );
            }

            if (request == null || request.status != 'completed') {
              return const _RateMessage(
                message: 'Complete a swap before leaving a review.',
              );
            }

            final revieweeName = request.fromUserId == currentUser.uid
                ? request.toUserName
                : request.fromUserName;

            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
              children: [
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 680),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Review $revieweeName',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                '${request.offeredSkillTitle} <-> ${request.wantedSkillTitle}',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: AppColors.textGray),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Rating',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              Slider(
                                min: 1,
                                max: 5,
                                divisions: 4,
                                label: _rating.toStringAsFixed(0),
                                value: _rating,
                                onChanged: (value) {
                                  setState(() => _rating = value);
                                },
                              ),
                              Center(
                                child: StatusChip(
                                  label: '${_rating.toStringAsFixed(0)} Stars',
                                  color: AppColors.warning,
                                  icon: Icons.star,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tags',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: [
                                  for (final tag in _tags)
                                    CategoryChip(
                                      label: tag,
                                      selected: _selectedTags.contains(tag),
                                      icon: Icons.check_circle_outline,
                                      onTap: () {
                                        setState(() {
                                          if (_selectedTags.contains(tag)) {
                                            _selectedTags.remove(tag);
                                          } else {
                                            _selectedTags.add(tag);
                                          }
                                        });
                                      },
                                    ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 18),
                        AppCard(
                          padding: const EdgeInsets.all(18),
                          child: TextField(
                            controller: _commentController,
                            maxLines: 4,
                            decoration: const InputDecoration(
                              labelText: 'Comment',
                              hintText: 'Share what went well...',
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        AppButton(
                          label: _isSaving ? 'Saving...' : 'Save Review',
                          icon: Icons.star_border_rounded,
                          onPressed: _isSaving
                              ? null
                              : () => _saveReview(request, currentUser.uid),
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

class _RateMessage extends StatelessWidget {
  const _RateMessage({required this.message});

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
